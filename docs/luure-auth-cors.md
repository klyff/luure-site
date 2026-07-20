# CORS e OAuth — migração luure.com.br

## sovereignid-agent-server

- **CORS:** `origin: true` em `src/app.ts` — aceita qualquer origem, incluindo `*.luure.com.br`. Nenhuma alteração necessária.
- **OAuth redirect_uri:** allowlist fixa (`sovereignid://govbr/callback`, `http://localhost:8081/govbr/callback`). Apps web nas PoCs não usam este fluxo diretamente.
- **BASE_URL:** em produção, definir `BASE_URL=https://agent.sovereignid.cloud` (ou futuro `agent.luure.com.br` se migrar o agent).

## PoCs frontend (monorepo klyff/sovereignid)

- Apps estáticos Vite; sem callbacks OAuth hardcoded nos builds atuais.
- API proxy local em dev (`/api` → localhost:3001); produção usa hosts Vercel.

## Agent server (sovereignid-agent)

- Em produção na Vercel: `https://agent.sovereignid.cloud` (canônico atual).
- `agent.luure.com.br` **já está anexado** ao projeto `sovereignid-agent` — passa a responder assim que o DNS propagar.
- Domínios luure realinhados aos projetos com os portais OID4VP reais:
  `efolha.luure.com.br` → `sovereignid-efolha`, `gestao.luure.com.br` → `sovereignid-gestao`
  (antes apontavam ao projeto legado `frontend`).

## Ação pós-DNS

Quando `*.luure.com.br` estiver resolvendo:

1. Validar login/credencial em `efolha.luure.com.br` e `gestao.luure.com.br`
2. Tornar o agent canônico em luure: `vercel env` → `BASE_URL=https://agent.luure.com.br`
   e `ISSUER_ID=https://agent.luure.com.br` no projeto `sovereignid-agent` + redeploy.
   Atenção: credenciais emitidas com `iss`/status-list do domínio antigo continuam
   válidas apenas enquanto `agent.sovereignid.cloud` permanecer ativo — manter os
   dois domínios no projeto (re-emitir credenciais de demo após a troca é o mais simples).
3. Atualizar `PROD_BASE_URL` em `sovereignid-wallet/src/services/config.ts` para
   `https://agent.luure.com.br` e regenerar builds da wallet.
