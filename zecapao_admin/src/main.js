import { createClient } from '@supabase/supabase-js'
import './styles.css'

const supabase = createClient(
  'https://yovjbqtazkreruvxoawf.supabase.co',
  'sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor'
)

const state = { session:null, tab:'dashboard', data:{} }
const app = document.querySelector('#app')

const esc = (v='') => String(v ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))
const money = v => `R$ ${Number(v||0).toFixed(2).replace('.',',')}`

async function loadAll(){
  const queries = await Promise.all([
    supabase.from('app_entry_config').select('*').order('sort_order'),
    supabase.from('home_sections').select('*').order('sort_order'),
    supabase.from('stores').select('*').order('name'),
    supabase.from('products').select('*').order('sort_order'),
    supabase.from('orders').select('*').order('created_at',{ascending:false}).limit(30),
    supabase.from('events').select('*').order('starts_at',{ascending:true}),
    supabase.from('campaign_banners').select('*').order('sort_order')
  ])
  const keys=['entry','home','stores','products','orders','events','banners']
  queries.forEach((r,i)=> state.data[keys[i]]=r.data||[])
}

function loginView(message=''){
  app.innerHTML = `<main class="login"><section class="login-card">
    <div class="brand-mark">ZÉ<br><b>CAPÃO</b></div>
    <p class="eyebrow">ADMIN v0.1</p><h1>O painel que controla o Vale.</h1>
    <p class="muted">Entre com uma conta administrativa do Supabase.</p>
    <form id="loginForm"><label>E-mail<input name="email" type="email" required></label><label>Senha<input name="password" type="password" required></label>
    ${message?`<div class="error">${esc(message)}</div>`:''}<button>ENTRAR</button></form>
  </section></main>`
  document.querySelector('#loginForm').onsubmit = async e => {
    e.preventDefault(); const fd=new FormData(e.currentTarget)
    const {error}=await supabase.auth.signInWithPassword({email:fd.get('email'),password:fd.get('password')})
    if(error) loginView(error.message)
  }
}

const menu = [
  ['dashboard','Dashboard','◫'],['entry','Tela de Entrada','◉'],['home','Home','⌂'],['stores','Parceiros','◆'],['products','Produtos','▦'],['orders','Pedidos','≡'],['events','Eventos','★'],['media','Mídias','▣']
]

function shell(content){
  app.innerHTML = `<div class="layout"><aside><div class="logo">Zé Capão <span>ADMIN</span></div><nav>${menu.map(([id,label,icon])=>`<button data-tab="${id}" class="${state.tab===id?'active':''}"><i>${icon}</i>${label}</button>`).join('')}</nav><button id="logout" class="logout">Sair</button></aside><main><header><div><p class="eyebrow">ZÉ CAPÃO ADMIN</p><h1>${menu.find(x=>x[0]===state.tab)?.[1]||''}</h1></div><div class="status">● online</div></header>${content}</main></div>`
  document.querySelectorAll('[data-tab]').forEach(b=>b.onclick=()=>{state.tab=b.dataset.tab;render()})
  document.querySelector('#logout').onclick=()=>supabase.auth.signOut()
}

function dashboard(){
  const d=state.data
  return `<section class="grid stats">
    <article><span>Parceiros</span><b>${d.stores.length}</b></article><article><span>Produtos</span><b>${d.products.length}</b></article><article><span>Pedidos recentes</span><b>${d.orders.length}</b></article><article><span>Eventos</span><b>${d.events.length}</b></article>
  </section><section class="panel"><h2>Central editorial</h2><p class="muted">A partir daqui, o conteúdo do app deixa de depender de uma nova APK. O Admin passa a comandar entrada, Home, parceiros, produtos e campanhas.</p></section>`
}

function entry(){
  const rows=state.data.entry
  return `<section class="panel"><div class="panel-head"><div><h2>Tela de Entrada</h2><p class="muted">Defina se a abertura será login, campanha ou mídia.</p></div></div>${rows.map(x=>`<article class="editor-card"><div class="row"><div><b>${esc(x.name)}</b><small>${esc(x.mode)}</small></div><label class="switch"><input type="checkbox" data-entry-active="${x.id}" ${x.is_active?'checked':''}><span></span></label></div><div class="form-grid"><label>Título<input data-field="title" data-id="${x.id}" value="${esc(x.title)}"></label><label>Modo<select data-field="mode" data-id="${x.id}">${['login','login_campaign','media_fullscreen','media_then_login'].map(m=>`<option ${x.mode===m?'selected':''}>${m}</option>`).join('')}</select></label><label>URL da mídia<input data-field="media_url" data-id="${x.id}" value="${esc(x.media_url)}" placeholder="https://..."></label><label>Duração (s)<input type="number" min="1" max="30" data-field="media_duration_seconds" data-id="${x.id}" value="${x.media_duration_seconds}"></label></div><button class="save" data-save-entry="${x.id}">Salvar alterações</button></article>`).join('')}</section>`
}

function home(){
  return `<section class="panel"><div class="panel-head"><div><h2>Seções da Home</h2><p class="muted">Ordem e visibilidade do app.</p></div></div><div class="list">${state.data.home.map(x=>`<article class="list-row"><div class="order">${x.sort_order}</div><div class="grow"><b>${esc(x.title)}</b><small>${esc(x.section_type)}</small></div><label class="switch"><input type="checkbox" data-home-active="${x.id}" ${x.is_active?'checked':''}><span></span></label></article>`).join('')}</div><h2 class="space">Banners</h2><div class="list">${state.data.banners.map(x=>`<article class="list-row"><div class="grow"><b>${esc(x.title)}</b><small>${esc(x.cta_label)} · ${esc(x.target_type)}</small></div><span class="badge">${x.is_active?'ATIVO':'OFF'}</span></article>`).join('')}</div></section>`
}

function stores(){ return `<section class="panel"><h2>Parceiros</h2><div class="cards">${state.data.stores.map(x=>`<article class="store"><div class="avatar">${esc(x.name).slice(0,2).toUpperCase()}</div><div><b>${esc(x.name)}</b><small>${esc(x.slug)} · ${x.is_open?'aberto':'fechado'}</small></div><span class="badge">${x.is_active?'ATIVO':'OFF'}</span></article>`).join('')}</div></section>` }
function products(){ return `<section class="panel"><h2>Produtos</h2><table><thead><tr><th>Produto</th><th>Categoria</th><th>Preço</th><th>Status</th></tr></thead><tbody>${state.data.products.map(x=>`<tr><td><b>${esc(x.name)}</b></td><td>${esc(x.category)}</td><td>${money(x.price)}</td><td>${x.is_available?'Disponível':'Pausado'}</td></tr>`).join('')}</tbody></table></section>` }
function orders(){ return `<section class="panel"><h2>Pedidos recentes</h2><table><thead><tr><th>Cliente</th><th>Status</th><th>Total</th><th>Pagamento</th></tr></thead><tbody>${state.data.orders.map(x=>`<tr><td><b>${esc(x.customer_name||'Cliente')}</b><small>${esc(x.customer_phone||'')}</small></td><td><span class="badge">${esc(x.status)}</span></td><td>${money(x.total)}</td><td>${esc(x.payment_method)}</td></tr>`).join('')}</tbody></table></section>` }
function events(){ return `<section class="panel"><h2>Eventos</h2><p class="muted">O módulo já está pronto no banco para receber Capão Reggae Vale, Jazz e próximos eventos.</p>${state.data.events.length?state.data.events.map(x=>`<article class="list-row"><div class="grow"><b>${esc(x.title)}</b><small>${esc(x.location)}</small></div></article>`).join(''):'<div class="empty">Nenhum evento cadastrado ainda.</div>'}</section>` }
function media(){ return `<section class="panel"><h2>Biblioteca de Mídia</h2><p class="muted">Bucket ativo: <b>zecapao-media</b>. Upload visual entra na próxima iteração do painel.</p><div class="drop">▣<br><b>Logos, banners, capas, fotos e vídeos</b><br><small>Storage do Supabase pronto para receber arquivos.</small></div></section>` }

async function bindActions(){
  document.querySelectorAll('[data-home-active]').forEach(el=>el.onchange=async()=>{await supabase.from('home_sections').update({is_active:el.checked,updated_at:new Date().toISOString()}).eq('id',el.dataset.homeActive);await refresh()})
  document.querySelectorAll('[data-entry-active]').forEach(el=>el.onchange=async()=>{await supabase.from('app_entry_config').update({is_active:el.checked,updated_at:new Date().toISOString()}).eq('id',el.dataset.entryActive);await refresh()})
  document.querySelectorAll('[data-save-entry]').forEach(btn=>btn.onclick=async()=>{
    const id=btn.dataset.saveEntry; const fields=[...document.querySelectorAll(`[data-id="${id}"]`)]; const payload={updated_at:new Date().toISOString()}
    fields.forEach(f=>payload[f.dataset.field]=f.type==='number'?Number(f.value):f.value)
    const {error}=await supabase.from('app_entry_config').update(payload).eq('id',id)
    btn.textContent=error?'Erro ao salvar':'Salvo ✓'; setTimeout(()=>btn.textContent='Salvar alterações',1400)
  })
}

async function refresh(){ await loadAll(); render() }
function render(){
  if(!state.session) return loginView()
  const views={dashboard,entry,home,stores,products,orders,events,media}
  shell((views[state.tab]||dashboard)()); bindActions()
}

supabase.auth.onAuthStateChange(async(_,session)=>{state.session=session;if(session)await loadAll();render()})
const {data:{session}}=await supabase.auth.getSession();state.session=session;if(session)await loadAll();render()
