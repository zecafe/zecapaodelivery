const SUPABASE_URL='https://yovjbqtazkreruvxoawf.supabase.co';
const SUPABASE_KEY='sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor';
const sb=window.supabase.createClient(SUPABASE_URL,SUPABASE_KEY);
const $=s=>document.querySelector(s);
let stores=[],currentStore=null,orders=[],products=[],channel=null;
const statusLabels={pending:'Aguardando',accepted:'Aceito',preparing:'Em preparo',ready:'Pronto',out_for_delivery:'Saiu p/ entrega',delivered:'Entregue',cancelled:'Cancelado'};
const statusOptions=['pending','accepted','preparing','ready','out_for_delivery','delivered','cancelled'];
const roleLabels={admin:'Administrador',owner:'Proprietário',manager:'Gerente',staff:'Equipe'};
function toast(msg){const e=$('#toast');e.textContent=msg;e.classList.remove('hidden');setTimeout(()=>e.classList.add('hidden'),2200)}
function money(v){return Number(v||0).toLocaleString('pt-BR',{style:'currency',currency:'BRL'})}
function esc(v=''){return String(v).replace(/[&<>'"]/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#039;','"':'&quot;'}[m]))}
function today(v){const d=new Date(v),n=new Date();return d.getFullYear()===n.getFullYear()&&d.getMonth()===n.getMonth()&&d.getDate()===n.getDate()}
function canManageCatalog(){return currentStore?._memberRole==='admin'||currentStore?._memberRole==='owner'||currentStore?._memberRole==='manager'}

async function access(){
  const {data:{user}}=await sb.auth.getUser(); if(!user)return null;
  const {data:profile}=await sb.from('profiles').select('role').eq('id',user.id).maybeSingle();
  if(profile?.role==='admin'){
    const {data,error}=await sb.from('stores').select('*').eq('is_active',true).order('name'); if(error)throw error;
    return {user,stores:(data||[]).map(s=>({...s,_memberRole:'admin'}))};
  }
  const {data,error}=await sb.from('store_members').select('store_id,role,stores(*)').eq('user_id',user.id); if(error)throw error;
  return {user,stores:(data||[]).map(x=>x.stores?({...x.stores,_memberRole:x.role}):null).filter(Boolean)};
}

async function boot(){
  try{
    const a=await access();
    if(!a||!a.stores.length){showLogin(a?'Sua conta ainda não está vinculada a uma loja. Use o primeiro acesso com o e-mail convidado.':'');return}
    stores=a.stores;showPanel();fillStores();await selectStore(stores[0].id);
  }catch(e){showLogin('Não foi possível carregar seu acesso.')}
}
function showLogin(msg=''){$('#login').classList.remove('hidden');$('#panel').classList.add('hidden');$('#error').textContent=msg}
function showPanel(){$('#login').classList.add('hidden');$('#panel').classList.remove('hidden')}

$('#loginForm').addEventListener('submit',async e=>{
  e.preventDefault();$('#error').textContent='';
  const {error}=await sb.auth.signInWithPassword({email:$('#email').value.trim(),password:$('#password').value});
  if(error){$('#error').textContent='E-mail ou senha inválidos.';return} await boot();
});
$('#logout').addEventListener('click',async()=>{if(channel)await sb.removeChannel(channel);await sb.auth.signOut();showLogin()});

function fillStores(){$('#storeSelect').innerHTML=stores.map(s=>`<option value="${s.id}">${esc(s.name)}</option>`).join('')}
$('#storeSelect').addEventListener('change',e=>selectStore(e.target.value));

async function selectStore(id){
  currentStore=stores.find(s=>s.id===id);if(!currentStore)return;
  $('#storeSelect').value=id;renderStore();await Promise.all([loadOrders(),loadProducts()]);subscribeOrders();
}
async function loadOrders(){
  const {data,error}=await sb.from('orders').select('*,order_items(*)').eq('store_id',currentStore.id).order('created_at',{ascending:false}).limit(100);
  if(error){toast('Erro ao carregar pedidos');return} orders=data||[];renderOrders();
}
async function loadProducts(){
  const {data,error}=await sb.from('products').select('*').eq('store_id',currentStore.id).order('sort_order').order('name');
  if(error){toast('Erro ao carregar produtos');return} products=data||[];renderProducts();
}
function subscribeOrders(){
  if(channel)sb.removeChannel(channel);
  channel=sb.channel(`partner-orders-${currentStore.id}`).on('postgres_changes',{event:'*',schema:'public',table:'orders',filter:`store_id=eq.${currentStore.id}`},()=>loadOrders()).subscribe();
}

function renderOrders(){
  $('#pendingCount').textContent=orders.filter(o=>o.status==='pending').length;
  $('#prepCount').textContent=orders.filter(o=>o.status==='preparing').length;
  $('#todayCount').textContent=orders.filter(o=>today(o.created_at)).length;
  $('#orders').innerHTML=orders.map(o=>`<article class="order">
    <div class="order-head"><div><h3>Pedido #${o.id.slice(0,8).toUpperCase()}</h3><div class="meta">${esc(o.customer_name||'Cliente')} • ${esc(o.customer_phone||'')} • ${new Date(o.created_at).toLocaleString('pt-BR')}</div></div><span class="pill">${statusLabels[o.status]||o.status}</span></div>
    <div class="items">${(o.order_items||[]).map(i=>`<div class="item"><span>${i.quantity}× ${esc(i.product_name)}</span><strong>${money(i.total)}</strong></div>`).join('')||'<span>Itens indisponíveis</span>'}</div>
    <div class="meta">📍 ${esc(o.delivery_address_text||'Sem endereço')} ${o.notes?`<br>📝 ${esc(o.notes)}`:''}<br>💳 ${esc(o.payment_method||'')}</div>
    <div class="order-foot"><strong>Total ${money(o.total)}</strong><select class="status-select" onchange="changeStatus('${o.id}',this.value)">${statusOptions.map(s=>`<option value="${s}" ${s===o.status?'selected':''}>${statusLabels[s]}</option>`).join('')}</select></div>
  </article>`).join('')||'<div class="card" style="padding:24px">Nenhum pedido recebido ainda.</div>';
}
window.changeStatus=async(id,status)=>{const {error}=await sb.from('orders').update({status,updated_at:new Date().toISOString()}).eq('id',id);if(error)return toast('Não foi possível mudar o status');toast(`Pedido: ${statusLabels[status]}`);await loadOrders()};

function renderProducts(){
  const manage=canManageCatalog();
  $('#products').innerHTML=`<table><thead><tr><th>Produto</th><th>Preço</th><th>Categoria</th><th>Status</th></tr></thead><tbody>${products.map(p=>`<tr><td><strong>${esc(p.name)}</strong><br><small>${esc(p.description||'')}</small></td><td>${money(p.price)}</td><td>${esc(p.category||'')}</td><td>${manage?`<button class="toggle ${p.is_available?'on':''}" onclick="toggleProduct('${p.id}',${!p.is_available})">${p.is_available?'Disponível':'Indisponível'}</button>`:`<span>${p.is_available?'Disponível':'Indisponível'}</span>`}</td></tr>`).join('')}</tbody></table>${manage?'':'<p class="meta" style="padding:14px">Seu perfil pode operar pedidos, mas não alterar o catálogo.</p>'}`;
}
window.toggleProduct=async(id,value)=>{if(!canManageCatalog())return toast('Seu perfil não pode alterar produtos');const {error}=await sb.from('products').update({is_available:value,updated_at:new Date().toISOString()}).eq('id',id);if(error)return toast('Erro ao alterar produto');toast(value?'Produto disponível':'Produto pausado');await loadProducts()};

function renderStore(){
  $('#storeName').textContent=currentStore.name;$('#storeDescription').textContent=currentStore.description||'';
  $('#deliveryFee').textContent=money(currentStore.delivery_fee);$('#estimatedMinutes').textContent=`${currentStore.estimated_minutes||40} min`;
  const b=$('#toggleOpen');b.textContent=currentStore.is_open?'LOJA ABERTA':'LOJA FECHADA';b.className=`toggle ${currentStore.is_open?'on':''}`;b.disabled=!canManageCatalog();b.title=canManageCatalog()?'':`Perfil: ${roleLabels[currentStore._memberRole]||currentStore._memberRole}`;
}
$('#toggleOpen').addEventListener('click',async()=>{if(!canManageCatalog())return toast('Seu perfil não pode abrir ou fechar a loja');const value=!currentStore.is_open;const {error}=await sb.from('stores').update({is_open:value,updated_at:new Date().toISOString()}).eq('id',currentStore.id);if(error)return toast('Erro ao alterar status da loja');currentStore.is_open=value;renderStore();toast(value?'Loja aberta':'Loja fechada')});

const titles={orders:'Pedidos',products:'Produtos',store:'Minha loja'};
document.querySelectorAll('.nav').forEach(b=>b.addEventListener('click',()=>{document.querySelectorAll('.nav').forEach(x=>x.classList.toggle('active',x===b));document.querySelectorAll('.view').forEach(v=>v.classList.add('hidden'));document.getElementById(`${b.dataset.view}View`).classList.remove('hidden');$('#title').textContent=titles[b.dataset.view]}));
boot();