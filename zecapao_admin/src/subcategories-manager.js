import { createClient } from '@supabase/supabase-js'

const supabase=createClient('https://yovjbqtazkreruvxoawf.supabase.co','sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor')
const esc=(v='')=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))
const slugify=s=>String(s||'').normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')
let injected=false

async function uploadSubImage(id,file){
  if(!file)return null
  const safe=file.name.toLowerCase().replace(/[^a-z0-9._-]+/g,'-')
  const path=`subcategorias/${id}/${Date.now()}-${safe}`
  const {error}=await supabase.storage.from('zecapao-media').upload(path,file)
  if(error)throw error
  return supabase.storage.from('zecapao-media').getPublicUrl(path).data.publicUrl
}

async function renderManager(host){
  const [{data:cats},{data:subs}]=await Promise.all([
    supabase.from('categories').select('id,name,is_active,sort_order').order('sort_order'),
    supabase.from('subcategories').select('*').order('category_id').order('sort_order')
  ])
  host.innerHTML=`<section class="panel sub-manager"><div class="panel-head"><div><h2>Gerenciador de Subcategorias</h2><p class="muted">Crie, edite, ordene, personalize imagem/ícone e ative ou desative subcategorias.</p></div></div>
  <div class="editor-card"><div class="form-grid"><label>Categoria<select id="smCat">${(cats||[]).filter(c=>c.is_active!==false).map(c=>`<option value="${c.id}">${esc(c.name)}</option>`).join('')}</select></label><label>Nova subcategoria<input id="smName" placeholder="Ex.: Pizzas"></label><label>Ícone (chave)<input id="smIcon" placeholder="local_pizza"></label><label>Ordem<input id="smOrder" type="number" value="10"></label></div><button class="save" id="smCreate">＋ Adicionar subcategoria</button></div>
  <div id="smList"></div></section>`

  const list=host.querySelector('#smList')
  const draw=()=>{
    const catId=host.querySelector('#smCat').value
    const rows=(subs||[]).filter(s=>s.category_id===catId)
    list.innerHTML=rows.length?rows.map(s=>`<article class="editor-card sm-row" data-id="${s.id}">
      <div class="row"><div><b>${esc(s.name)}</b><small>${esc(s.slug)} · ${s.is_active!==false?'ativa':'desativada'}</small></div><label class="switch"><input type="checkbox" data-sm-active ${s.is_active!==false?'checked':''}><span></span></label></div>
      <div class="dual-media"><div><div class="media-preview" style="aspect-ratio:1/1">${s.image_url?`<img src="${esc(s.image_url)}" alt="${esc(s.name)}">`:'<div class="preview-empty"><b>SEM IMAGEM</b><small>Usará o ícone</small></div>'}</div><label class="upload-button">＋ Trocar imagem<input hidden type="file" accept="image/jpeg,image/png,image/webp,image/gif" data-sm-file></label></div>
      <div class="form-grid"><label>Nome<input data-sm-name value="${esc(s.name)}"></label><label>Ícone<input data-sm-icon value="${esc(s.icon||'')}"></label><label>Ordem<input data-sm-order type="number" value="${s.sort_order??0}"></label></div></div>
      <div class="row"><button class="save" data-sm-save>Salvar</button><button class="danger" data-sm-delete>Excluir</button></div></article>`).join(''):'<div class="editor-card"><p class="muted">Nenhuma subcategoria nesta categoria.</p></div>'
    bindRows()
  }
  const reload=async()=>renderManager(host)
  const bindRows=()=>{
    list.querySelectorAll('.sm-row').forEach(row=>{
      const id=row.dataset.id
      row.querySelector('[data-sm-save]').onclick=async()=>{
        const payload={name:row.querySelector('[data-sm-name]').value.trim(),icon:row.querySelector('[data-sm-icon]').value.trim(),sort_order:Number(row.querySelector('[data-sm-order]').value)||0,is_active:row.querySelector('[data-sm-active]').checked}
        if(!payload.name)return
        payload.slug=slugify(payload.name)
        const file=row.querySelector('[data-sm-file]').files?.[0]
        if(file)payload.image_url=await uploadSubImage(id,file)
        const {error}=await supabase.from('subcategories').update(payload).eq('id',id)
        if(error)return alert(error.message)
        await reload()
      }
      row.querySelector('[data-sm-active]').onchange=async e=>{await supabase.from('subcategories').update({is_active:e.target.checked}).eq('id',id)}
      row.querySelector('[data-sm-delete]').onclick=async()=>{
        if(!confirm('Excluir esta subcategoria? Parceiros vinculados perderão este vínculo.'))return
        await supabase.from('store_subcategories').delete().eq('subcategory_id',id)
        const {error}=await supabase.from('subcategories').delete().eq('id',id)
        if(error)return alert(error.message)
        await reload()
      }
    })
  }
  host.querySelector('#smCat').onchange=draw
  host.querySelector('#smCreate').onclick=async()=>{
    const name=host.querySelector('#smName').value.trim();if(!name)return
    const payload={category_id:host.querySelector('#smCat').value,name,slug:slugify(name),icon:host.querySelector('#smIcon').value.trim(),sort_order:Number(host.querySelector('#smOrder').value)||0,is_active:true}
    const {error}=await supabase.from('subcategories').insert(payload)
    if(error)return alert(error.message)
    await reload()
  }
  draw()
}

async function enhance(){
  const header=[...document.querySelectorAll('main header h1')].find(x=>x.textContent.trim()==='Home')
  if(!header)return
  const main=header.closest('main');if(!main||main.querySelector('[data-submanager-host]'))return
  const host=document.createElement('div');host.dataset.submanagerHost='1'
  const panels=[...main.querySelectorAll(':scope > section.panel')]
  if(panels.length)panels[panels.length-1].after(host);else main.appendChild(host)
  await renderManager(host)
}

const style=document.createElement('style');style.textContent=`.sub-manager{margin-top:22px}.sm-row{margin-top:14px}.sm-row .upload-button{display:inline-flex;margin-top:10px}.sm-row .dual-media{align-items:start}`;document.head.appendChild(style)
new MutationObserver(()=>enhance()).observe(document.body,{childList:true,subtree:true})
setTimeout(enhance,500)
