(() => {
  const nav = document.querySelector('.sidebar nav');
  const main = document.querySelector('main.content');
  if (!nav || !main) return;

  const navBtn = document.createElement('button');
  navBtn.className = 'nav-item';
  navBtn.textContent = 'Mídia & Campanhas';
  nav.appendChild(navBtn);

  const section = document.createElement('section');
  section.id = 'commercialSection';
  section.className = 'section-view hidden';
  section.innerHTML = `
    <div class="panel" style="margin-bottom:18px">
      <div class="panel-head"><div><p class="eyebrow">HOME COMERCIAL</p><h3>Banners e campanhas</h3></div><button id="newBannerBtn" class="primary">+ Nova campanha</button></div>
      <div id="bannerList" class="cards-grid"></div>
    </div>
    <div class="panel" style="margin-bottom:18px">
      <div class="panel-head"><div><p class="eyebrow">ESTABELECIMENTOS</p><h3>Logo e capa reais</h3></div></div>
      <div class="form-grid">
        <label class="span-2">Estabelecimento<select id="mediaStore"></select></label>
        <label class="span-2">URL da logo<input id="mediaStoreLogo" placeholder="https://..." /></label>
        <label class="span-2">URL da foto de capa<input id="mediaStoreCover" placeholder="https://..." /></label>
      </div>
      <div class="modal-actions"><button id="saveStoreMedia" class="primary">Salvar mídia da loja</button></div>
      <div id="storeMediaPreview" style="margin-top:12px"></div>
    </div>
    <div class="panel">
      <div class="panel-head"><div><p class="eyebrow">CATÁLOGO</p><h3>Foto real do produto</h3></div></div>
      <div class="form-grid">
        <label>Estabelecimento<select id="mediaProductStore"></select></label>
        <label>Produto<select id="mediaProduct"></select></label>
        <label class="span-2">URL da foto<input id="mediaProductImage" placeholder="https://..." /></label>
        <label>Destaque<select id="mediaProductFeatured"><option value="false">Não</option><option value="true">Sim</option></select></label>
        <label>Selo / badge<input id="mediaProductBadge" placeholder="Mais pedido, Novidade..." /></label>
      </div>
      <div class="modal-actions"><button id="saveProductMedia" class="primary">Salvar foto do produto</button></div>
      <div id="productMediaPreview" style="margin-top:12px"></div>
    </div>`;
  main.appendChild(section);

  const dialog = document.createElement('dialog');
  dialog.id = 'bannerDialog';
  dialog.innerHTML = `<form method="dialog" id="bannerForm" class="modal-form">
    <div class="modal-head"><div><p class="eyebrow">CAMPANHA</p><h3 id="bannerDialogTitle">Nova campanha</h3></div><button type="button" class="icon-btn" id="closeBannerDialog">×</button></div>
    <input type="hidden" id="bannerId" />
    <div class="form-grid">
      <label class="span-2">Título<input id="bannerTitle" required /></label>
      <label class="span-2">Subtítulo<textarea id="bannerSubtitle" rows="2"></textarea></label>
      <label class="span-2">URL da imagem<input id="bannerImage" placeholder="https://..." /></label>
      <label>Cor de fundo<input id="bannerBg" value="#E2231A" /></label>
      <label>Cor do texto<input id="bannerText" value="#FFFFFF" /></label>
      <label>Chamada<input id="bannerCta" placeholder="Peça agora" /></label>
      <label>Ordem<input id="bannerOrder" type="number" value="0" /></label>
      <label class="switch-row"><input id="bannerActive" type="checkbox" checked /> Campanha ativa</label>
    </div>
    <div class="modal-actions"><button type="button" class="ghost" id="cancelBanner">Cancelar</button><button class="primary" type="submit">Salvar campanha</button></div>
    <p id="bannerError" class="error"></p>
  </form>`;
  document.body.appendChild(dialog);

  let banners = [];
  const q = s => document.querySelector(s);
  const escapeHtml = v => String(v || '').replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[m]));

  navBtn.addEventListener('click', async () => {
    document.querySelectorAll('.nav-item').forEach(x => x.classList.toggle('active', x === navBtn));
    document.querySelectorAll('.section-view').forEach(x => x.classList.add('hidden'));
    section.classList.remove('hidden');
    q('#pageTitle').textContent = 'Mídia & Campanhas';
    await loadCommercial();
  });

  async function loadCommercial() {
    const {data, error} = await sb.from('campaign_banners').select('*').order('sort_order');
    if (error) return toast('Erro ao carregar campanhas');
    banners = data || [];
    fillSelectors();
    renderBanners();
    loadStoreMedia();
    loadProductOptions();
  }

  function fillSelectors() {
    const opts = stores.map(s => `<option value="${s.id}">${escapeHtml(s.name)}</option>`).join('');
    q('#mediaStore').innerHTML = opts;
    q('#mediaProductStore').innerHTML = opts;
  }

  function renderBanners() {
    q('#bannerList').innerHTML = banners.map(b => `
      <article class="store-card">
        <div style="height:110px;border-radius:16px;overflow:hidden;background:${escapeHtml(b.background_hex || '#E2231A')};position:relative;margin-bottom:12px">
          ${b.image_url ? `<img src="${escapeHtml(b.image_url)}" style="width:100%;height:100%;object-fit:cover"/>` : ''}
        </div>
        <div class="status">${b.is_active ? 'ATIVA' : 'PAUSADA'} • ordem ${b.sort_order || 0}</div>
        <h3>${escapeHtml(b.title)}</h3><p class="muted">${escapeHtml(b.subtitle)}</p>
        <div class="card-actions"><button class="ghost" data-edit-banner="${b.id}">Editar</button><button class="ghost" data-toggle-banner="${b.id}">${b.is_active ? 'Pausar' : 'Ativar'}</button></div>
      </article>`).join('') || '<p class="muted">Nenhuma campanha cadastrada.</p>';
    q('#bannerList').querySelectorAll('[data-edit-banner]').forEach(btn => btn.onclick = () => editBanner(btn.dataset.editBanner));
    q('#bannerList').querySelectorAll('[data-toggle-banner]').forEach(btn => btn.onclick = () => toggleBanner(btn.dataset.toggleBanner));
  }

  q('#newBannerBtn').onclick = () => {
    q('#bannerForm').reset(); q('#bannerId').value=''; q('#bannerBg').value='#E2231A'; q('#bannerText').value='#FFFFFF'; q('#bannerActive').checked=true; q('#bannerDialogTitle').textContent='Nova campanha'; q('#bannerError').textContent=''; dialog.showModal();
  };
  q('#closeBannerDialog').onclick = q('#cancelBanner').onclick = () => dialog.close();

  function editBanner(id) {
    const b = banners.find(x => x.id === id); if (!b) return;
    q('#bannerId').value=b.id; q('#bannerTitle').value=b.title||''; q('#bannerSubtitle').value=b.subtitle||''; q('#bannerImage').value=b.image_url||''; q('#bannerBg').value=b.background_hex||'#E2231A'; q('#bannerText').value=b.text_hex||'#FFFFFF'; q('#bannerCta').value=b.cta_label||''; q('#bannerOrder').value=b.sort_order||0; q('#bannerActive').checked=!!b.is_active; q('#bannerDialogTitle').textContent='Editar campanha'; q('#bannerError').textContent=''; dialog.showModal();
  }

  async function toggleBanner(id) {
    const b=banners.find(x=>x.id===id); if(!b)return;
    const {error}=await sb.from('campaign_banners').update({is_active:!b.is_active,updated_at:new Date().toISOString()}).eq('id',id);
    if(error)return toast('Erro ao alterar campanha'); toast(!b.is_active?'Campanha ativada':'Campanha pausada'); await loadCommercial();
  }

  q('#bannerForm').addEventListener('submit', async e => {
    e.preventDefault(); const id=q('#bannerId').value;
    const payload={title:q('#bannerTitle').value.trim(),subtitle:q('#bannerSubtitle').value.trim()||null,image_url:q('#bannerImage').value.trim()||null,background_hex:q('#bannerBg').value.trim()||'#E2231A',text_hex:q('#bannerText').value.trim()||'#FFFFFF',cta_label:q('#bannerCta').value.trim()||null,sort_order:Number(q('#bannerOrder').value||0),is_active:q('#bannerActive').checked,updated_at:new Date().toISOString()};
    const req=id?sb.from('campaign_banners').update(payload).eq('id',id):sb.from('campaign_banners').insert(payload);
    const {error}=await req; if(error){q('#bannerError').textContent=error.message;return;} dialog.close(); toast(id?'Campanha atualizada':'Campanha criada'); await loadCommercial();
  });

  q('#mediaStore').addEventListener('change', loadStoreMedia);
  function loadStoreMedia() {
    const s=stores.find(x=>x.id===q('#mediaStore').value); if(!s)return;
    q('#mediaStoreLogo').value=s.logo_url||''; q('#mediaStoreCover').value=s.cover_url||'';
    q('#storeMediaPreview').innerHTML=`${s.cover_url?`<img src="${escapeHtml(s.cover_url)}" style="width:100%;max-height:190px;object-fit:cover;border-radius:16px;margin-bottom:8px">`:''}${s.logo_url?`<img src="${escapeHtml(s.logo_url)}" style="width:90px;height:90px;object-fit:contain;border-radius:14px;background:white">`:''}`;
  }
  q('#saveStoreMedia').onclick=async()=>{const id=q('#mediaStore').value;if(!id)return;const {error}=await sb.from('stores').update({logo_url:q('#mediaStoreLogo').value.trim()||null,cover_url:q('#mediaStoreCover').value.trim()||null,updated_at:new Date().toISOString()}).eq('id',id);if(error)return toast('Erro ao salvar mídia');toast('Mídia da loja atualizada');await loadAll();await loadCommercial();};

  q('#mediaProductStore').addEventListener('change',loadProductOptions);
  q('#mediaProduct').addEventListener('change',loadProductMedia);
  function loadProductOptions(){const list=products.filter(p=>p.store_id===q('#mediaProductStore').value);q('#mediaProduct').innerHTML=list.map(p=>`<option value="${p.id}">${escapeHtml(p.name)}</option>`).join('');loadProductMedia();}
  function loadProductMedia(){const p=products.find(x=>x.id===q('#mediaProduct').value);if(!p){q('#productMediaPreview').innerHTML='';return;}q('#mediaProductImage').value=p.image_url||'';q('#mediaProductFeatured').value=String(!!p.featured);q('#mediaProductBadge').value=p.badge||'';q('#productMediaPreview').innerHTML=p.image_url?`<img src="${escapeHtml(p.image_url)}" style="width:180px;height:130px;object-fit:cover;border-radius:16px">`:'';}
  q('#saveProductMedia').onclick=async()=>{const id=q('#mediaProduct').value;if(!id)return;const {error}=await sb.from('products').update({image_url:q('#mediaProductImage').value.trim()||null,featured:q('#mediaProductFeatured').value==='true',badge:q('#mediaProductBadge').value.trim()||null,updated_at:new Date().toISOString()}).eq('id',id);if(error)return toast('Erro ao salvar foto');toast('Foto do produto atualizada');await loadAll();await loadCommercial();};
})();