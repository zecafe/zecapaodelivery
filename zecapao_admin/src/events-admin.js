import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://yovjbqtazkreruvxoawf.supabase.co',
  'sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor'
)

const esc=(v='')=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))
const slugify=s=>String(s||'').normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')
const dateInput=v=>v?new Date(v).toISOString().slice(0,16):''

async function uploadEventImage(id,file){
  if(!file) return null
  if(file.size>15*1024*1024) throw new Error('A imagem deve ter no máximo 15 MB.')
  const safe=file.name.toLowerCase().replace(/[^a-z0-9._-]+/g,'-')
  const path=`eventos/${id}/${Date.now()}-${safe}`
  const {error}=await supabase.storage.from('zecapao-media').upload(path,file)
  if(error) throw error
  return supabase.storage.from('zecapao-media').getPublicUrl(path).data.publicUrl
}

function formHtml(x={}){
  const isNew=!x.id
  return `<article class="editor-card event-form" data-event-form="${x.id||'new'}">
    <div class="row"><div><b>${isNew?'Novo evento':esc(x.title)}</b><small>Capa recomendada: 1200 × 675 px · 16:9 · JPG/PNG/WebP</small></div>${!isNew?`<span class="badge">${x.is_active?'ATIVO':'OFF'}</span>`:''}</div>
    <div class="event-media-grid">
      <div class="media-preview" style="aspect-ratio:16/9">${x.image_url?`<img src="${esc(x.image_url)}" alt="Capa">`:`<div class="preview-empty"><b>SEM CAPA</b><small>1200 × 675 px</small></div>`}</div>
      <div>
        <label class="upload-button event-upload">＋ ${x.image_url?'Substituir capa':'Adicionar capa'}<input hidden type="file" accept="image/jpeg,image/png,image/webp" data-event-file></label>
        <div class="form-grid">
          <label>Título<input data-ef="title" value="${esc(x.title||'')}"></label>
          <label>Subtítulo<input data-ef="subtitle" value="${esc(x.subtitle||'')}"></label>
          <label>Início<input type="datetime-local" data-ef="starts_at" value="${dateInput(x.starts_at)}"></label>
          <label>Fim<input type="datetime-local" data-ef="ends_at" value="${dateInput(x.ends_at)}"></label>
          <label>Local / espaço<input data-ef="venue" value="${esc(x.venue||'')}"></label>
          <label>Localização<input data-ef="location_text" value="${esc(x.location_text||'')}"></label>
          <label>Texto do botão<input data-ef="cta_label" value="${esc(x.cta_label||'VER EVENTO')}"></label>
          <label>Link do botão<input data-ef="target_url" value="${esc(x.target_url||'')}"></label>
          <label>Ordem<input type="number" data-ef="sort_order" value="${Number(x.sort_order||0)}"></label>
          <label>Destaque<select data-ef="is_featured"><option value="false" ${!x.is_featured?'selected':''}>Não</option><option value="true" ${x.is_featured?'selected':''}>Sim</option></select></label>
          <label>Status<select data-ef="is_active"><option value="true" ${x.is_active!==false?'selected':''}>Ativo</option><option value="false" ${x.is_active===false?'selected':''}>Desativado</option></select></label>
          <label class="wide">Descrição<textarea data-ef="description" rows="4">${esc(x.description||'')}</textarea></label>
        </div>
        <div class="row event-actions"><button class="save" data-save-event>${isNew?'CRIAR EVENTO':'SALVAR EVENTO'}</button>${!isNew?`<button class="danger" data-disable-event>Desativar</button>`:''}</div>
        <div class="upload-progress" data-event-status></div>
      </div>
    </div>
  </article>`
}

async function renderEventsPanel(panel){
  if(panel.dataset.eventsEnhanced==='loading'||panel.dataset.eventsEnhanced==='true') return
  panel.dataset.eventsEnhanced='loading'
  const {data:events,error}=await supabase.from('events').select('*').order('sort_order').order('starts_at',{ascending:true})
  if(error){panel.dataset.eventsEnhanced='';return}
  panel.innerHTML=`<div class="panel-head"><div><h2>Eventos</h2><p class="muted">Cadastre a agenda do Vale e publique a capa diretamente no app.</p></div><button class="save" id="toggleNewEvent">＋ Novo evento</button></div><div id="newEventArea" class="hidden">${formHtml()}</div><div class="events-admin-list">${events?.length?events.map(formHtml).join(''):'<div class="empty">Nenhum evento cadastrado. Clique em “Novo evento”.</div>'}</div>`
  panel.dataset.eventsEnhanced='true'
  panel.querySelector('#toggleNewEvent')?.addEventListener('click',()=>panel.querySelector('#newEventArea')?.classList.toggle('hidden'))
  panel.querySelectorAll('[data-event-form]').forEach(bindForm)
}

function val(form,field){return form.querySelector(`[data-ef="${field}"]`)?.value??''}
function bindForm(form){
  form.querySelector('[data-save-event]')?.addEventListener('click',async()=>{
    const status=form.querySelector('[data-event-status]')
    const title=val(form,'title').trim()
    if(!title){status.textContent='Informe o título do evento.';return}
    status.textContent='Salvando…'
    const payload={
      title,
      slug:slugify(title),
      subtitle:val(form,'subtitle')||null,
      description:val(form,'description')||null,
      starts_at:val(form,'starts_at')?new Date(val(form,'starts_at')).toISOString():null,
      ends_at:val(form,'ends_at')?new Date(val(form,'ends_at')).toISOString():null,
      venue:val(form,'venue')||null,
      location_text:val(form,'location_text')||null,
      cta_label:val(form,'cta_label')||null,
      target_url:val(form,'target_url')||null,
      sort_order:Number(val(form,'sort_order')||0),
      is_featured:val(form,'is_featured')==='true',
      is_active:val(form,'is_active')!=='false',
      updated_at:new Date().toISOString()
    }
    try{
      let id=form.dataset.eventForm
      if(id==='new'){
        const {data,error}=await supabase.from('events').insert(payload).select('id').single()
        if(error) throw error
        id=data.id
      }else{
        const {error}=await supabase.from('events').update(payload).eq('id',id)
        if(error) throw error
      }
      const file=form.querySelector('[data-event-file]')?.files?.[0]
      if(file){
        status.textContent='Enviando capa…'
        const image_url=await uploadEventImage(id,file)
        const {error}=await supabase.from('events').update({image_url,updated_at:new Date().toISOString()}).eq('id',id)
        if(error) throw error
      }
      status.textContent='Evento salvo ✓'
      setTimeout(()=>{const p=findEventsPanel();if(p){p.dataset.eventsEnhanced='';renderEventsPanel(p)}},600)
    }catch(e){status.textContent=e.message||'Erro ao salvar evento.'}
  })
  form.querySelector('[data-disable-event]')?.addEventListener('click',async()=>{
    if(!confirm('Desativar este evento?')) return
    const {error}=await supabase.from('events').update({is_active:false,updated_at:new Date().toISOString()}).eq('id',form.dataset.eventForm)
    if(!error){const p=findEventsPanel();p.dataset.eventsEnhanced='';renderEventsPanel(p)}
  })
}

function findEventsPanel(){
  return [...document.querySelectorAll('.panel')].find(p=>p.querySelector('h2')?.textContent?.trim()==='Eventos')
}
function scan(){const p=findEventsPanel();if(p)renderEventsPanel(p)}
new MutationObserver(()=>scan()).observe(document.body,{childList:true,subtree:true})
scan()
