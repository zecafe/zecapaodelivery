(() => {
  const btn=document.createElement('button');
  btn.type='button';
  btn.id='forgotPasswordBtn';
  btn.className='ghost full';
  btn.textContent='Esqueci minha senha';

  const signupBtn=document.getElementById('signupBtn');
  if(signupBtn?.parentNode) signupBtn.parentNode.insertBefore(btn, signupBtn.nextSibling);

  btn.addEventListener('click',async()=>{
    const email=document.getElementById('email')?.value.trim().toLowerCase();
    const errorEl=document.getElementById('loginError');
    if(!email){errorEl.textContent='Informe seu e-mail primeiro.';return;}

    btn.disabled=true;
    btn.textContent='Enviando recuperação...';
    errorEl.textContent='';

    const redirectTo=new URL('recuperar-senha.html', window.location.href).toString();
    const {error}=await sb.auth.resetPasswordForEmail(email,{redirectTo});

    btn.disabled=false;
    btn.textContent='Esqueci minha senha';

    if(error){
      errorEl.textContent=error.message||'Não foi possível enviar o e-mail de recuperação.';
      return;
    }

    errorEl.style.color='#1F5E3A';
    errorEl.textContent='Enviamos um link de recuperação para seu e-mail. Abra a mensagem e defina uma nova senha.';
  });
})();