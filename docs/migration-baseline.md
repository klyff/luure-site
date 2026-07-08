# Migration Baseline — luure-* (2026-07-08)

## GCP

| Item | Valor |
|------|-------|
| Projeto | `sp-identity-trust` |
| VM | `voce-br-vm` |
| Zona | `southamerica-east1-b` |
| IP | `34.39.174.212` |
| Tipo (doc) | `e2-standard-2` |
| Status HTTP | nginx ativo (404 na raiz) |
| Acesso gcloud | **Bloqueado** — `klyff.harlley@gmail.com` sem permissão; `klyff@predix.global` requer reauth interativa |

## Vercel (klyffs-projects)

| Projeto | URL produção | Domínio alvo |
|---------|--------------|--------------|
| sovereignid-home | luure.com.br | luure.com.br |
| sovereignid-io | sovereignid.smartecm.io | redirect |
| frontend | efolha.luure.com.br | efolha/gestao/wallet |
| sovereignid-voce | voce.luure.com.br | voce |
| sovereignid-licencas | licencas.luure.com.br | licencas |
| sovereignid-conselhos | conselhos.luure.com.br | conselhos |
| sovereignid-licitacoes | licitacoes.luure.com.br | licitacoes |
| sovereignid-cidadao | cidadao.luure.com.br | cidadao |
| sovereignid-cras | cras.luure.com.br | cras |
| sovereignid-esocial | esocial.luure.com.br | esocial |
| sovereignid-rh | rh.luure.com.br | rh |
| sovereignid-agent | sovereignid-agent.vercel.app | agent.luure.com.br (pendente) |
| sovereignid-efolha | efolha.sovereignid.cloud | **duplicata — remover** |
| sovereignid-gestao | gestao.sovereignid.cloud | **duplicata — remover** |
| sovereignid-api-proxy | — | legado |

## DNS (local resolver)

- `luure.com.br` — sem resposta (Registro.br pendente)
- `*.luure.com.br` — sem resposta
- `sovereignid.cloud` → Vercel (64.29.17.x)
- `agent.sovereignid.cloud` → Vercel (216.198.79.x)
- `ledger.smartecm.io` — sem resposta local

## Smoke test (2026-07-08)

- 9 redirects legados OK (308)
- 12 links luure.com.br no HTML do site
- 16 skips DNS (luure.com.br não resolve localmente)
- Agent `/health` → `{"status":"ok"}`

## Repositórios GitHub atuais

- `klyff/sovereignID.io` — site institucional
- `klyff/sovereignid` — monorepo (frontend + backend + ledger + infra)
- Local: `sovereignid-agent-server`, `sovereignid-wallet`

## Destino (luure-*)

- `luure-site`, `luure-frontends`, `luure-agent`, `luure-wallet`, `luure-ledger`, `luure-infra`
