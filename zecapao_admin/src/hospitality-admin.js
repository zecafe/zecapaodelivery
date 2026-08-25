import { createClient } from '@supabase/supabase-js'

const supabase=createClient('https://yovjbqtazkreruvxoawf.supabase.co','sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor')
const esc=(v='')=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))
let busy=false

async function fetchStore(id){
  const {data}=await supabase.from('stores').select('id,name,category_id,partner_type,cta_label,cta_url,booking_whatsapp,price_range,amenities,gallery_urls,hospitality_highlights').eq('id',id).maybeSingle()
  return data
}

function listText(v){return Array.isArray(v)?v.join(', '):''}
function highlightsText(v){try{return JSON.stringify(v||[],null,2)}catch(_){return '[]'}}

async function enhance(){
  if(busy)return;busy=true
  try{
    const buttons=[...document.querySelectorAll('[data-save-table="stores"]')]
    for(const button of buttons){
      const card=button.closest('.editor-card');if(!card||card.querySelector('[data-hospitality-root]'))continue
      const store=await fetchStore(button.dataset.id);if(!store)continue
      const root=document.createElement('div');root.dataset.hospitalityRoot=store.id;root.className='hospitality-admin'
      root.innerHTML=`<div class="hospitality-head"><div><b>Perfil do parceiro</b><small>Use Hospedagem para pousadas, hotéis, hostels, chalés e similares.</small></div></div>
      <div class="form-grid"><label>Tipo de parceiro<select data-h-type><option value="commerce" ${store.partner_type!=='hospitality'?'selected':''}>Comércio / serviço</option><option value="hospitality" ${store.partner_type==='hospitality'?'selected':''}>Hospedagem</option></select></label></div>
      <div data-h-fields class="${store.partner_type==='hospitality'?'':'hidden'}">
        <div class="form-grid">
          <label>Texto do CTA<input data-h-cta-label value="${esc(store.cta_label||'FAZER RESERVA')}"></label>
          <label>URL de reserva<input data-h-cta-url value="${esc(store.cta_url||'')}" placeholder="Booking, site próprio..."></label>
          <label>WhatsApp de reserva<input data-h-whatsapp value="${esc(store.booking_whatsapp||'')}" placeholder="5575..."></label>
          <label>Faixa de preço<input data-h-price value="${esc(store.price_range||'')}" placeholder="Ex.: Diárias a partir de R$ 380"></label>
          <label class="wide">Comodidades<input data-h-amenities value="${esc(listText(store.amenities))}" placeholder="Wi-Fi, café da manhã, piscina, estacionamento"></label>
          <label class="wide">Galeria (URLs separadas por vírgula)<textarea data-h-gallery rows="3">${esc(listText(store.gallery_urls))}</textarea></label>
          <label class="wide">Experiências / quartos (JSON)<textarea data-h-highlights rows="6" placeholder='[{"title":"Suíte Jardim","subtitle":"Acorde cercado de verde."}]'>${esc(highlightsText(store.hospitality_highlights))}</textarea></label>
        </div>
        <p class="muted">Esses dados alimentam a apresentação premium da hospedagem no app.</p>
      </div>
      <small data-h-status class="hospitality-status"></small>`
      const actionRow=button.closest('.row');if(actionRow)actionRow.before(root);else card.appendChild(root)
      const type=root.querySelector('[data-h-type]');type.onchange=()=>root.querySelector('[data-h-fields]').classList.toggle('hidden',type.value!=='hospitality')
      button.addEventListener('click',async()=>{
        let highlights=[]
        const raw=root.querySelector('[data-h-highlights]')?.value.trim()||'[]'
        if(type.value==='hospitality'){try{highlights=JSON.parse(raw)}catch(_){root.querySelector('[data-h-status]').textContent='JSON de experiências inválido';return}}
        const payload={partner_type:type.value,updated_at:new Date().toISOString()}
        if(type.value==='hospitality')Object.assign(payload,{cta_label:root.querySelector('[data-h-cta-label]').value.trim(),cta_url:root.querySelector('[data-h-cta-url]').value.trim(),booking_whatsapp:root.querySelector('[data-h-whatsapp]').value.trim(),price_range:root.querySelector('[data-h-price]').value.trim(),amenities:root.querySelector('[data-h-amenities]').value.split(',').map(x=>x.trim()).filter(Boolean),gallery_urls:root.querySelector('[data-h-gallery]').value.split(',').map(x=>x.trim()).filter(Boolean),hospitality_highlights:highlights})
        const {error}=await supabase.from('stores').update(payload).eq('id',store.id)
        const status=root.querySelector('[data-h-status]');status.textContent=error?error.message:'Perfil premium salvo ✓';if(!error)setTimeout(()=>status.textContent='',2200)
      })
    }
  }finally{busy=false}
}

const style=document.createElement('style');style.textContent=`.hospitality-admin{margin:18px 0;padding:16px;border:1px solid #d9e7df;border-radius:16px;background:#f7fbf8}.hospitality-head{margin-bottom:12px}.hospitality-head small{display:block;color:#77747a;margin-top:3px}.hospitality-admin textarea{width:100%;resize:vertical}.hospitality-status{display:block;margin-top:8px;color:#24824b;font-weight:800}.hospitality-admin .hidden{display:none!important}`;document.head.appendChild(style)
new MutationObserver(()=>enhance()).observe(document.body,{childList:true,subtree:true})
setTimeout(enhance,500)
