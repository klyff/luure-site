# CORS e OAuth — migração luure.com.br

## sovereignid-agent-server

- **CORS:** `origin: true` em `src/app.ts` — aceita qualquer origem, incluindo `*.luure.com.br`. Nenhuma alteração necessária.
- **OAuth redirect_uri:** allowlist fixa (`sovereignid://govbr/callback`, `http://localhost:8081/govbr/callback`). Apps web nas PoCs não usam este fluxo diretamente.
- **BASE_URL:** em produção, definir `BASE_URL=https://agent.sovereignid.cloud` (ou futuro `agent.luure.com.br` se migrar o agent).

## PoCs frontend (monorepo klyff/sovereignid)

- Apps estáticos Vite; sem callbacks OAuth hardcoded nos builds atuais.
- API proxy local em dev (`/api` → localhost:3001); produção usa hosts Vercel.

## Ação pós-DNS

Quando `*.luure.com.br` estiver resolvendo:

1. Validar login/credencial em `efolha.luure.com.br` e `wallet.luure.com.br`
2. Se o agent for migrado, adicionar `agent.luure.com.br` e atualizar `BASE_URL` / `ISSUER_ID`
