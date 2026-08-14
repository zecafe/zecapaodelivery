const SUPABASE_URL='https://yovjbqtazkreruvxoawf.supabase.co';
const SUPABASE_KEY='sb_publishable_qOQlqYHbhc1005WoMOZS6g__52vXAor';
const sb=window.supabase.createClient(SUPABASE_URL,SUPABASE_KEY);
const form=document.getElementById('resetForm');
const msg=document.getElementById('message');

sb.auth.onAuthStateChange((event)=>{
  if(event==='PASSWORD_RECOVERY'){
    msg.style.color='#1F5E3A';
    msg.textContent='Link confirmado. Agora defina sua nova senha.';
  }
});

form.addEventListener('submit',async e=>{
  e.preventDefault();
  const p1=document.getElementById('newPassword').value;
  const p2=document.getElementById('confirmPassword').value;
  if(p1!==p2){msg.textContent='As senhas não coincidem.';return;}
  const btn=document.getElementById('saveBtn');
  btn.disabled=true;btn.textContent='Salvando...';msg.textContent='';
  const {error}=await sb.auth.updateUser({password:p1});
  btn.disabled=false;btn.textContent='Salvar nova senha';
  if(error){msg.textContent=error.message||'Não foi possível alterar a senha.';return;}
  msg.style.color='#1F5E3A';
  msg.textContent='Senha atualizada. Redirecionando para o painel...';
  setTimeout(()=>window.location.href='./',1300);
});