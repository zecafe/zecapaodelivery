const INITIAL_ADMIN_EMAIL='carlosright@gmail.com';

const signupBtn=document.getElementById('signupBtn');
if(signupBtn){
  signupBtn.addEventListener('click',async()=>{
    const email=document.getElementById('email').value.trim().toLowerCase();
    const password=document.getElementById('password').value;
    const errorEl=document.getElementById('loginError');
    errorEl.textContent='';

    if(email!==INITIAL_ADMIN_EMAIL){
      errorEl.textContent='O primeiro acesso administrativo está reservado ao e-mail autorizado.';
      return;
    }
    if(password.length<6){
      errorEl.textContent='Crie uma senha com pelo menos 6 caracteres.';
      return;
    }

    signupBtn.disabled=true;
    signupBtn.textContent='Criando acesso...';
    const {data,error}=await sb.auth.signUp({
      email,
      password,
      options:{data:{full_name:'Carlos',role:'admin'}}
    });
    signupBtn.disabled=false;
    signupBtn.textContent='Criar meu primeiro acesso';

    if(error){
      if((error.message||'').toLowerCase().includes('already registered')){
        errorEl.textContent='Esse e-mail já possui cadastro. Use “Entrar no painel”.';
      }else{
        errorEl.textContent=error.message||'Não foi possível criar o acesso.';
      }
      return;
    }

    if(data.session){
      const admin=await getAdminProfile().catch(()=>null);
      if(admin){
        showAdmin(admin.user.email);
        await loadAll();
        toast('Acesso administrativo criado.');
        return;
      }
    }
    errorEl.style.color='#1F5E3A';
    errorEl.textContent='Acesso criado. Confira seu e-mail para confirmar a conta e depois entre no painel.';
  });
}
