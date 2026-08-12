const SUPABASE_URL='https://yovjbqtazkreruvxoawf.supabase.co';
const SUPABASE_KEY='sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor';
const sb=window.supabase.createClient(SUPABASE_URL,SUPABASE_KEY);

const $=s=>document.querySelector(s);
let stores=[];
let products=[];

function toast(message){const el=$('#toast');el.textContent=message;el.classList.remove('hidden');setTimeout(()=>el.classList.add('hidden'),2200)}
function money(v){return Number(v||0).toLocaleString('pt-BR',{style:'currency',currency:'BRL'})}
function slugify(v){return v.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'')}

async function getAdminProfile(){
  const {data:{user}}=await sb.auth.getUser();
  if(!user) return null;
  const {data,error}=await sb.from('profiles').select('id,role,full_name').eq('id',user.id).maybeSingle();
  if(error) throw error;
  if(!data||data.role!=='admin') return null;
  return {user,profile:data};
}

async function boot(){
  const admin=await getAdminProfile().catch(()=>null);
  if(!admin){showLogin();return}
  showAdmin(admin.user.email);
  await loadAll();
}

function showLogin(){
  $('#loginView').classList.remove('hidden');
  $('#adminView').classList.add('hidden');
}
function showAdmin(email){
  $('#loginView').classList.add('hidden');
  $('#adminView').classList.remove('hidden');
  $('#adminEmail').textContent=email||'';
}

$('#loginForm').addEventListener('submit',async e=>{
  e.preventDefault();
  $('#loginError').textContent='';
  const {error}=await sb.auth.signInWithPassword({email:$('#email').value.trim(),password:$('#password').value});
  if(error){$('#loginError').textContent='E-mail ou senha inválidos.';return}
  const admin=await getAdminProfile();
  if(!admin){await sb.auth.signOut();$('#loginError').textContent='Este usuário não possui acesso administrativo.';return}
  showAdmin(admin.user.email);
  await loadAll();
});

$('#logoutBtn').addEventListener('click',async()=>{await sb.auth.signOut();showLogin()});
$('#refreshBtn').addEventListener('click',loadAll);

async function loadAll(){
  const [s,p]=await Promise.all([
    sb.from('stores').select('*').order('name'),
    sb.from('products').select('*').order('sort_order').order('name')
  ]);
  if(s.error) return toast('Erro ao carregar estabelecimentos');
  if(p.error) return toast('Erro ao carregar produtos');
  stores=s.data||[];products=p.data||[];
  renderAll();
}

function renderAll(){renderDashboard();renderStores();renderProducts();fillStoreSelectors()}

function renderDashboard(){
  $('#storeCount').textContent=stores.length;
  $('#productCount').textContent=products.length;
  $('#openCount').textContent=stores.filter(s=>s.is_open&&s.is_active).length;
  $('#availableCount').textContent=products.filter(p=>p.is_available).length;
  $('#dashboardList').innerHTML=stores.map(s=>{
    const count=products.filter(p=>p.store_id===s.id).length;
    return `<div class="dash-row"><div><strong>${escapeHtml(s.name)}</strong><div class="muted">${escapeHtml(s.description||'Sem descrição')}</div></div><div><span class="status"><span class="dot ${s.is_open?'open':'closed'}"></span>${s.is_open?'Aberta':'Fechada'}</span></div><div><strong>${count}</strong> produto(s)</div></div>`
  }).join('')||'<div class="dash-row">Nenhum estabelecimento cadastrado.</div>';
}

function renderStores(){
  $('#storesGrid').innerHTML=stores.map(s=>`<article class="store-card">
    <div class="status"><span class="dot ${s.is_open?'open':'closed'}"></span>${s.is_open?'Aberta':'Fechada'}</div>
    <h3>${escapeHtml(s.name)}</h3><p class="muted">${escapeHtml(s.description||'Sem descrição')}</p>
    <div class="store-meta"><div class="meta-box"><span>ENTREGA</span><strong>${money(s.delivery_fee)}</strong></div><div class="meta-box"><span>TEMPO</span><strong>${s.estimated_minutes||40} min</strong></div></div>
    <div class="card-actions"><button class="ghost" onclick="editStore('${s.id}')">Editar</button><button class="ghost" onclick="toggleStore('${s.id}',${!s.is_open})">${s.is_open?'Fechar':'Abrir'}</button><button class="ghost" onclick="filterProducts('${s.id}')">Produtos</button></div>
  </article>`).join('')||'<p class="muted">Nenhum estabelecimento cadastrado.</p>';
}

function renderProducts(){
  const filter=$('#storeFilter').value;
  const data=filter?products.filter(p=>p.store_id===filter):products;
  const storeMap=Object.fromEntries(stores.map(s=>[s.id,s.name]));
  $('#productsTableWrap').innerHTML=`<table class="data-table"><thead><tr><th>Produto</th><th>Loja</th><th>Preço</th><th>Categoria</th><th>Status</th><th></th></tr></thead><tbody>${data.map(p=>`<tr><td><strong>${escapeHtml(p.name)}</strong><br><span class="muted">${escapeHtml(p.description||'')}</span></td><td>${escapeHtml(storeMap[p.store_id]||'')}</td><td>${money(p.price)}</td><td>${escapeHtml(p.category||'')}</td><td><span class="pill ${p.is_available?'ok':'off'}">${p.is_available?'Disponível':'Indisponível'}</span></td><td><button class="ghost" onclick="editProduct('${p.id}')">Editar</button></td></tr>`).join('')}</tbody></table>`;
}

function fillStoreSelectors(){
  const filter=$('#storeFilter');
  const current=filter.value;
  filter.innerHTML='<option value="">Todas as lojas</option>'+stores.map(s=>`<option value="${s.id}">${escapeHtml(s.name)}</option>`).join('');
  filter.value=current;
  $('#productStore').innerHTML=stores.map(s=>`<option value="${s.id}">${escapeHtml(s.name)}</option>`).join('');
}

function escapeHtml(v=''){return String(v).replace(/[&<>'"]/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#039;','"':'&quot;'}[m]))}

function openDialog(id){document.getElementById(id).showModal()}
function closeDialog(id){document.getElementById(id).close()}
document.querySelectorAll('[data-close]').forEach(b=>b.addEventListener('click',()=>closeDialog(b.dataset.close)));

$('#newStoreBtn').addEventListener('click',()=>{
  $('#storeForm').reset();$('#storeId').value='';$('#storeOpen').checked=true;$('#storeActive').checked=true;$('#storeDialogTitle').textContent='Novo estabelecimento';$('#storeFormError').textContent='';openDialog('storeDialog');
});
$('#storeName').addEventListener('input',()=>{if(!$('#storeId').value)$('#storeSlug').value=slugify($('#storeName').value)});

window.editStore=id=>{
  const s=stores.find(x=>x.id===id);if(!s)return;
  $('#storeId').value=s.id;$('#storeName').value=s.name||'';$('#storeSlug').value=s.slug||'';$('#storeDescription').value=s.description||'';$('#storeFee').value=s.delivery_fee||0;$('#storeMin').value=s.min_order||0;$('#storeMinutes').value=s.estimated_minutes||40;$('#storePhone').value=s.phone||'';$('#storeAddress').value=s.address||'';$('#storeOpen').checked=!!s.is_open;$('#storeActive').checked=!!s.is_active;$('#storeDialogTitle').textContent='Editar estabelecimento';$('#storeFormError').textContent='';openDialog('storeDialog');
};

$('#storeForm').addEventListener('submit',async e=>{
  e.preventDefault();
  const id=$('#storeId').value;
  const payload={name:$('#storeName').value.trim(),slug:$('#storeSlug').value.trim(),description:$('#storeDescription').value.trim()||null,delivery_fee:Number($('#storeFee').value||0),min_order:Number($('#storeMin').value||0),estimated_minutes:Number($('#storeMinutes').value||40),phone:$('#storePhone').value.trim()||null,address:$('#storeAddress').value.trim()||null,is_open:$('#storeOpen').checked,is_active:$('#storeActive').checked,updated_at:new Date().toISOString()};
  const q=id?sb.from('stores').update(payload).eq('id',id):sb.from('stores').insert(payload);
  const {error}=await q;
  if(error){$('#storeFormError').textContent=error.message;return}
  closeDialog('storeDialog');toast(id?'Estabelecimento atualizado':'Estabelecimento criado');await loadAll();
});

window.toggleStore=async(id,value)=>{const {error}=await sb.from('stores').update({is_open:value,updated_at:new Date().toISOString()}).eq('id',id);if(error)return toast('Erro ao alterar loja');toast(value?'Loja aberta':'Loja fechada');await loadAll()};
window.filterProducts=id=>{$('[data-section="products"]').click();$('#storeFilter').value=id;renderProducts()};
$('#storeFilter').addEventListener('change',renderProducts);

$('#newProductBtn').addEventListener('click',()=>{
  if(!stores.length)return toast('Cadastre um estabelecimento primeiro');
  $('#productForm').reset();$('#productId').value='';$('#productAvailable').checked=true;$('#productDialogTitle').textContent='Novo produto';$('#productFormError').textContent='';openDialog('productDialog');
});
window.editProduct=id=>{
  const p=products.find(x=>x.id===id);if(!p)return;
  $('#productId').value=p.id;$('#productStore').value=p.store_id;$('#productName').value=p.name||'';$('#productPrice').value=p.price||0;$('#productDescription').value=p.description||'';$('#productCategory').value=p.category||'';$('#productOrder').value=p.sort_order||0;$('#productAvailable').checked=!!p.is_available;$('#productDialogTitle').textContent='Editar produto';$('#productFormError').textContent='';openDialog('productDialog');
};
$('#productForm').addEventListener('submit',async e=>{
  e.preventDefault();
  const id=$('#productId').value;
  const payload={store_id:$('#productStore').value,name:$('#productName').value.trim(),price:Number($('#productPrice').value),description:$('#productDescription').value.trim()||null,category:$('#productCategory').value.trim()||null,sort_order:Number($('#productOrder').value||0),is_available:$('#productAvailable').checked,updated_at:new Date().toISOString()};
  const q=id?sb.from('products').update(payload).eq('id',id):sb.from('products').insert(payload);
  const {error}=await q;
  if(error){$('#productFormError').textContent=error.message;return}
  closeDialog('productDialog');toast(id?'Produto atualizado':'Produto criado');await loadAll();
});

const titles={dashboard:'Visão geral',stores:'Estabelecimentos',products:'Produtos'};
document.querySelectorAll('.nav-item').forEach(btn=>btn.addEventListener('click',()=>{
  document.querySelectorAll('.nav-item').forEach(x=>x.classList.toggle('active',x===btn));
  document.querySelectorAll('.section-view').forEach(x=>x.classList.add('hidden'));
  document.getElementById(btn.dataset.section+'Section').classList.remove('hidden');
  $('#pageTitle').textContent=titles[btn.dataset.section];
}));

sb.auth.onAuthStateChange(()=>{});
boot();