# Capão Entregador 0.2.1: autenticação e autorização (preparação)

Status: **preparação isolada, não implantada**. Branch: `fix/entregador-auth-021`, baseada em `feat/ze-entregador-mvp`.

## Diagnóstico confirmado em 18/11/2026
- `DriverGate` inicia com `status == null`, mostra o formulário e só exibe `CONSULTAR SITUAÇÃO` depois de um envio.
- A função `get_driver_application_status(p_email,p_cpf)` retorna status a quem souber esses dados. Isso **não autentica** o entregador.
- O banco tinha um cadastro `approved` e nenhum `driver_applications.user_id` vinculado.
- `get_ready_delivery_offer`, `driver_accept_delivery` e `driver_advance_delivery` são `SECURITY DEFINER` e executáveis por `anon`. Não verificam aprovação/posse da entrega; risco de acesso indevido a dados e alterações.
- A tela `HomePage` usa nome livre, não uma identidade validada.

## Implementação planejada (requer validação antes de aplicar em produção)
1. Autenticar por Supabase Auth e-mail OTP de **seis dígitos**, confirmando template de e-mail, envio e verificação no projeto. Usar `signInWithOtp(email: ..., shouldCreateUser: true)` e `verifyOTP(..., type: OtpType.email)`; confirmar API exata com SDK/versão do projeto. Persistência de sessão via `supabase_flutter`.
2. Após login, chamar RPC de vinculação, que só vincula cadastro aprovado **cujo e-mail normalizado coincide com `auth.jwt()->>'email'`**, e apenas quando `user_id is null` ou já é `auth.uid()`. Não permitir reivindicar cadastro de outro usuário. A função não deve retornar CPF, Pix ou demais dados privados.
3. Criar RPC de status autenticado que consulta **somente** cadastro do `auth.uid()`. Mostrar estados pendente, bloqueado, aprovado. Incluir botão `Já sou entregador` na tela inicial.
4. Todas as RPCs de entrega devem exigir `auth.uid() is not null` e existência de cadastro `approved` com `user_id = auth.uid()`. Restringir leitura de ofertas aos aprovados. Aceite deve ser atômico e não sobrescrever atribuição existente; avanço deve exigir `delivery_assignments.driver_id = auth.uid()`. Usar transações e tratamento de concorrência.
5. Revogar `EXECUTE` de `PUBLIC` e `anon` nas RPCs de entrega; conceder apenas a `authenticated` depois de validar autorizações internas. Revisar outras RPCs, policies e grants; executar Supabase Security Advisor.
6. Não alterar `driver_applications.status` na migração. Não criar usuário com senha conhecida, nem expor CPF ou tokens em logs.
7. Compilar versão `0.2.1+3` com o mesmo pacote `com.zecapao.ze_entregador` e a mesma chave de assinatura; alterar workflow para buscar **esta branch de teste**, sem afetar a versão 0.2.0.
8. Testes obrigatórios: cadastro aprovado antigo sem user_id; login OTP; retomada de sessão; pendente/bloqueado; conta diferente tentando reivindicar cadastro; acesso anônimo a ofertas/aceites; entregador A tentando avançar entrega de B; concorrência de dois aceites; app aberto após reinício.

**Não liberar nova versão na Google Play antes de os testes e a migração de segurança serem aprovados.**
