# Zecapão Build 0.1 — Sprint 01

Primeiro pacote de implementação do Zecapão como destino SaaS, derivado da base 9.1 sem incluir credenciais, chaves de assinatura ou arquivos secretos do projeto original.

## Entregue neste sprint
- Brand tokens do app em Flutter.
- Catálogo inicial com 14 parceiros reais enviados para o projeto.
- Sete macro-categorias do destino.
- Capão Reggae Vale como primeiro evento/mídia do destino.
- Widget de Home Flutter para integração/validação visual.
- Migration de `destination_events` e seeder inicial do Vale do Capão.
- Protótipo HTML responsivo para revisão rápida da hierarquia visual.

## Integração recomendada na base 9.1
1. Copiar `flutter/lib/zecapao` para `app/lib/zecapao`.
2. Copiar os assets para `app/assets/zecapao/...` e adicioná-los ao `pubspec.yaml`.
3. Trocar em `AppConstants`: `appName`, `fontFamily`, `webHostedUrl`, `baseUrl`, `yourScheme` e `yourHost` somente quando os domínios/ambientes Zecapão estiverem definidos.
4. Substituir a paleta de `light_theme.dart` e `dark_theme.dart` pelos tokens do Brand Kit.
5. Integrar `ZecapaoHomePreview` por partes na Home existente, preservando controllers e repositórios do StackFood.
6. Aplicar a camada SaaS Core 0.1 antes da migration de eventos.
7. Depois do cadastro real no banco, remover o catálogo local temporário e consumir `/api/v1/destinations/{slug}/home`.

## Segurança
Não reutilizar `google-services.json`, `.jks`, `key.properties`, credenciais OAuth, segredos `.env` ou chaves do pacote original sem rotação/validação. Esses arquivos não foram copiados para este patch.
