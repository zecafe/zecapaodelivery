import { createClient } from '@supabase/supabase-js'

const supabase=createClient('https://yovjbqtazkreruvxoawf.supabase.co','sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor')

let cache=null
let running=false

const esc=(v='')=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))

async function loadTaxonomy(){
  const [cats,subs,links]=await Promise.all([
    supabase.from('categories').select('id,name,slug,is_active,sort_order').order('sort_order'),
    supabase.from('subcategories').select('id,category_id,name,slug,is_active,sort_order').eq('is_active',true).order('sort_order'),
    supabase.from('store_subcategories').select('store_id,subcategory_id')
  ])
  cache={
    categories:cats.data||[],
    subcategories:subs.data||[],
    links:links.data||[]
  }
  return cache
}

function selectedFor(storeId){
  if(!cache)return new Set()
  return new Set(cache.links.filter(x=>x.store_id===storeId).map(x=>x.subcategory_id))
}

function subOptions(categoryId,selected){
  const list=(cache?.subcategories||[]).filter(x=>x.category_id===categoryId)
  if(!categoryId)return '<p class="muted taxonomy-empty">Escolha primeiro uma categoria.</p>'
  if(!list.length)return '<p class="muted taxonomy-empty">Nenhuma subcategoria ativa nesta categoria.</p>'
  return `<div class="taxonomy-chips">${list.map(s=>`<label class="taxonomy-chip"><input type="checkbox" data-tax-sub="${s.id}" ${selected.has(s.id)?'checked':''}><span>${esc(s.name)}</span></label>`).join('')}</div>`
}

function categoryOptions(current){
  return `<option value="">Sem categoria</option>${(cache?.categories||[]).filter(c=>c.is_active!==false).map(c=>`<option value="${c.id}" ${c.id===current?'selected':''}>${esc(c.name)}</option>`).join('')}`
}

async function storeById(id){
  const {data}=await supabase.from('stores').select('id,category_id').eq('id',id).maybeSingle()
  return data||null
}

async function saveTaxonomy(storeId,root){
  const categoryId=root.querySelector('[data-tax-category]')?.value||null
  const subIds=[...root.querySelectorAll('[data-tax-sub]:checked')].map(x=>x.dataset.taxSub)
  const validSubIds=new Set((cache?.subcategories||[]).filter(s=>s.category_id===categoryId).map(s=>s.id))
  const filtered=subIds.filter(id=>validSubIds.has(id))

  const {error:storeError}=await supabase.from('stores').update({category_id:categoryId,updated_at:new Date().toISOString()}).eq('id',storeId)
  if(storeError){console.error(storeError);return}
  const {error:deleteError}=await supabase.from('store_subcategories').delete().eq('store_id',storeId)
  if(deleteError){console.error(deleteError);return}
  if(filtered.length){
    const {error:insertError}=await supabase.from('store_subcategories').insert(filtered.map(subcategory_id=>({store_id:storeId,subcategory_id})))
    if(insertError){console.error(insertError);return}
  }
  await loadTaxonomy()
  const status=root.querySelector('[data-tax-status]')
  if(status){status.textContent='Categoria e subcategorias salvas ✓';setTimeout(()=>status.textContent='',2200)}
}

async function enhanceStoreCards(){
  if(running)return
  running=true
  try{
    if(!cache)await loadTaxonomy()
    const buttons=[...document.querySelectorAll('[data-save-table="stores"]')]
    for(const button of buttons){
      const storeId=button.dataset.id
      const card=button.closest('.editor-card')
      if(!card||card.querySelector('[data-taxonomy-root]'))continue
      const store=await storeById(storeId)
      if(!store)continue
      const selected=selectedFor(storeId)
      const root=document.createElement('div')
      root.dataset.taxonomyRoot=storeId
      root.className='taxonomy-admin'
      root.innerHTML=`
        <div class="taxonomy-head">
          <div><b>Classificação no Zé Capão</b><small>Define onde este parceiro aparece no app e no buscador.</small></div>
        </div>
        <div class="form-grid taxonomy-grid">
          <label>Categoria
            <select data-tax-category>${categoryOptions(store.category_id)}</select>
          </label>
          <div class="wide">
            <label>Subcategorias</label>
            <div data-tax-subs>${subOptions(store.category_id,selected)}</div>
          </div>
        </div>
        <small class="taxonomy-status" data-tax-status></small>`
      const actionRow=button.closest('.row')
      if(actionRow)actionRow.before(root);else card.appendChild(root)
      const select=root.querySelector('[data-tax-category]')
      select.addEventListener('change',()=>{
        root.querySelector('[data-tax-subs]').innerHTML=subOptions(select.value,new Set())
      })
      button.addEventListener('click',()=>saveTaxonomy(storeId,root))
    }
  }finally{running=false}
}

function enhanceNewStore(){
  const form=document.querySelector('#newStoreForm')
  const category=document.querySelector('#nsCategory')
  if(!form||!category||form.querySelector('[data-new-taxonomy]')||!cache)return
  const box=document.createElement('div')
  box.dataset.newTaxonomy='1'
  box.className='taxonomy-admin'
  box.innerHTML=`<div class="wide"><label>Subcategorias</label><div data-new-tax-subs>${subOptions(category.value,new Set())}</div><small class="muted">Depois de criar o parceiro, você também poderá alterar estas opções no cartão dele.</small></div>`
  const create=form.querySelector('#createStoreBtn')
  if(create)create.before(box);else form.appendChild(box)
  category.addEventListener('change',()=>{box.querySelector('[data-new-tax-subs]').innerHTML=subOptions(category.value,new Set())})

  if(create){
    create.addEventListener('click',async()=>{
      const name=document.querySelector('#nsName')?.value.trim()
      const categoryId=category.value||null
      const picked=[...box.querySelectorAll('[data-tax-sub]:checked')].map(x=>x.dataset.taxSub)
      if(!name||!picked.length)return
      const slug=String(name).normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')
      setTimeout(async()=>{
        const {data}=await supabase.from('stores').select('id').eq('slug',slug).order('created_at',{ascending:false}).limit(1)
        const storeId=data?.[0]?.id
        if(!storeId)return
        await supabase.from('stores').update({category_id:categoryId}).eq('id',storeId)
        await supabase.from('store_subcategories').delete().eq('store_id',storeId)
        await supabase.from('store_subcategories').insert(picked.map(subcategory_id=>({store_id:storeId,subcategory_id})))
        await loadTaxonomy()
      },1200)
    })
  }
}

async function enhance(){
  if(!document.querySelector('[data-save-table="stores"]')&&!document.querySelector('#newStoreForm'))return
  if(!cache)await loadTaxonomy()
  await enhanceStoreCards()
  enhanceNewStore()
}

const style=document.createElement('style')
style.textContent=`
.taxonomy-admin{margin:18px 0;padding:16px;border:1px solid #ebe6dd;border-radius:16px;background:#fbfaf7}.taxonomy-head{display:flex;justify-content:space-between;margin-bottom:12px}.taxonomy-head small{display:block;color:#77747a;margin-top:3px}.taxonomy-grid{align-items:start}.taxonomy-chips{display:flex;flex-wrap:wrap;gap:8px;margin-top:7px}.taxonomy-chip input{display:none}.taxonomy-chip span{display:inline-block;padding:8px 11px;border-radius:999px;border:1px solid #ddd5c9;background:#fff;font-size:12px;font-weight:700;cursor:pointer}.taxonomy-chip input:checked+span{background:#242330;color:#fff;border-color:#242330}.taxonomy-empty{margin:8px 0}.taxonomy-status{display:block;color:#24824b;font-weight:800;margin-top:8px}.taxonomy-admin select{width:100%}
`
document.head.appendChild(style)

const observer=new MutationObserver(()=>enhance())
observer.observe(document.body,{childList:true,subtree:true})
setTimeout(()=>enhance(),300)
