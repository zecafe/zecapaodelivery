(() => {
  const roleLabels={owner:'Proprietário',manager:'Gerente',staff:'Equipe'};
  let invites=[];

  function ensureUi(){
    const nav=document.querySelector('.sidebar nav');
    if(nav && !document.getElementById('partnersNav')){
      const b=document.createElement('button');
      b.id='partnersNav'; b.className='nav-item'; b.textContent='Acessos parceiros';
      b.addEventListener('click',()=>{
        document.querySelectorAll('.nav-item').forEach(x=>x.classList.remove('active')); b.classList.add('active');
        document.querySelectorAll('.section-view').forEach(x=>x.classList.add('hidden'));
        document.getElementById('partnersSection').classList.remove('hidden');
        document.getElementById('pageTitle').textContent='Acessos parceiros';
        loadInvites();
      });
      nav.appendChild(b);
    }

    const main=document.querySelector('main.content');
    if(main && !document.getElementById('partnersSection')){
      const section=document.createElement('section');
      section.id='partnersSection'; section.className='section-view hidden';
      section.innerHTML=`<div class="section-actions"><div><strong>Acessos de lojistas</strong><p class="muted">Convide o responsável e vincule-o a uma loja.</p></div><button id="newPartnerBtn" class="primary">+ Convidar parceiro</button></div><div id="partnersWrap" class="panel table-wrap"></div>`;
      main.appendChild(section);
      document.getElementById('newPartnerBtn').addEventListener('click',openInvite);
    }

    if(!document.getElementById('partnerDialog')){
      const d=document.createElement('dialog'); d.id='partnerDialog';
      d.innerHTML=`<form method="dialog" id="partnerForm" class="modal-form"><div class="modal-head"><div><p class="eyebrow">ACESSO PARCEIRO</p><h3>Convidar lojista</h3></div><button type="button" class="icon-btn" id="closePartnerDialog">×</button></div><div class="form-grid"><label>Nome completo<input id="partnerName" required /></label><label>E-mail<input id="partnerEmail" type="email" required /></label><label class="span-2">Estabelecimento<select id="partnerStore" required></select></label><label class="span-2">Permissão<select id="partnerRole"><option value="owner">Proprietário</option><option value="manager" selected>Gerente</option><option value="staff">Equipe</option></select></label></div><p class="muted">O lojista cria a própria senha em <strong>/parceiro/</strong> usando este mesmo e-mail.</p><div class="modal-actions"><button type="button" class="ghost" id="cancelPartnerDialog">Cancelar</button><button class="primary" type="submit">Criar convite</button></div><p id="partnerFormError" class="error"></p></form>`;
      document.body.appendChild(d);
      document.getElementById('closePartnerDialog').onclick=()=>d.close();
      document.getElementById('cancelPartnerDialog').onclick=()=>d.close();
      document.getElementById('partnerForm').addEventListener('submit',saveInvite);
    }
  }

  function openInvite(){
    const select=document.getElementById('partnerStore');
    select.innerHTML=(stores||[]).map(s=>`<option value="${s.id}">${esc(s.name)}</option>`).join('');
    document.getElementById('partnerForm').reset();
    document.getElementById('partnerFormError').textContent='';
    document.getElementById('partnerDialog').showModal();
  }

  async function saveInvite(e){
    e.preventDefault();
    const errorEl=document.getElementById('partnerFormError'); errorEl.textContent='';
    const {error}=await sb.rpc('admin_invite_partner',{p_email:document.getElementById('partnerEmail').value.trim().toLowerCase(),p_full_name:document.getElementById('partnerName').value.trim(),p_store_id:document.getElementById('partnerStore').value,p_role:document.getElementById('partnerRole').value});
    if(error){errorEl.textContent=error.message;return}
    document.getElementById('partnerDialog').close(); toast('Convite de parceiro criado'); await loadInvites();
  }

  async function loadInvites(){
    const wrap=document.getElementById('partnersWrap'); if(!wrap)return;
    wrap.innerHTML='<div style="padding:18px">Carregando...</div>';
    const {data,error}=await sb.from('partner_invites').select('*').order('created_at',{ascending:false});
    if(error){wrap.innerHTML='<div style="padding:18px">Erro ao carregar convites.</div>';return}
    invites=data||[];
    const storeMap=Object.fromEntries((stores||[]).map(s=>[s.id,s.name]));
    wrap.innerHTML=`<table class="data-table"><thead><tr><th>Responsável</th><th>Loja</th><th>Permissão</th><th>Status</th><th>Criado</th></tr></thead><tbody>${invites.map(i=>`<tr><td><strong>${esc(i.full_name||'')}</strong><br><span class="muted">${esc(i.email)}</span></td><td>${esc(storeMap[i.store_id]||'')}</td><td>${roleLabels[i.role]||i.role}</td><td><span class="pill ${i.accepted_at?'ok':'off'}">${i.accepted_at?'Ativo':'Aguardando cadastro'}</span></td><td>${new Date(i.created_at).toLocaleDateString('pt-BR')}</td></tr>`).join('')}</tbody></table>`;
  }

  const wait=setInterval(()=>{
    if(window.sb && document.querySelector('.sidebar nav')){clearInterval(wait);ensureUi();}
  },100);
})();