# Luure Migration Runbook

Orquestração da migração sovereignID → luure-* (Vercel + GitHub).

## Repositórios luure-*

| Repo | Deploy | Domínio |
|------|--------|---------|
| [luure-site](https://github.com/klyff/luure-site) | Vercel `sovereignid-home` | `luure.com.br` |
| [luure-frontends](https://github.com/klyff/luure-frontends) | Vercel `frontend` + `sovereignid-*` | `*.luure.com.br` |
| [luure-agent](https://github.com/klyff/luure-agent) | Vercel `sovereignid-agent` | `agent.luure.com.br` |
| [luure-wallet](https://github.com/klyff/luure-wallet) | Expo | app stores |
| [luure-ledger](https://github.com/klyff/luure-ledger) | VM GCP | `ledger.luure.com.br` |
| [luure-infra](https://github.com/klyff/luure-infra) | Terraform/scripts | ops |

## Scripts

| Script | Uso |
|--------|-----|
| `scripts/deploy-luure-all.sh` | Build + deploy site, agent, todas as PoCs |
| `scripts/add-luure-poc-domains.sh` | Anexa `*.luure.com.br` aos projetos Vercel |
| `scripts/validate-luure-migration.sh` | Health check completo |
| `scripts/validate-poc-navigation.sh` | Validação de rotas internas das PoCs (canônico + vercel.app) |
| `scripts/loop-validate-luure.sh` | Loop 15 min (validação contínua) |
| `scripts/deploy-smartecm-legacy-redirects.sh` | Redirects `*.smartecm.io` → `*.luure.com.br` (sovereignid-io) |
| `scripts/smoke-test-luure.sh` | Smoke test rápido |

## DNS (Registro.br)

Ver [DNS_LUURE.md](DNS_LUURE.md). Sem DNS de `luure.com.br`, os redirects legados levam a destinos inacessíveis.

## GCP desidratação (manual)

Requer `gcloud auth login` com conta que tenha acesso a `sp-identity-trust`.

```bash
# 1. Desidratar VM (para nginx + portais)
GCP_PROJECT_ID=sp-identity-trust ZONE=southamerica-east1-b \
  gcloud compute ssh voce-br-vm --zone="$ZONE" --project="$GCP_PROJECT_ID" \
  --tunnel-through-iap --command 'sudo bash -s' \
  < luure-infra/scripts/dehydrate-vm.sh

# 2. Redimensionar para e2-small
bash luure-infra/scripts/resize-vm.sh

# 3. DNS luure.com.br: ledger + api → A 34.39.174.212 (VM); portais → Vercel (CNAME)
#    Manter redirects *.smartecm.io via projeto sovereignid-io até descomissionar
```

## Validação

```bash
./scripts/validate-luure-migration.sh
```

Critério de sucesso: 0 falhas (skips DNS são esperados até Registro.br propagar).

## Multi-agente (Cursor)

| Fase | Agente | Gate |
|------|--------|------|
| 0 | shell | baseline documentado |
| 1 | generalPurpose | 6 repos luure-* no GitHub |
| 2 | deployment-expert | deploys Vercel + redirects |
| 3 | shell | VM sem nginx/portais |
| 4 | shell | VM e2-small |
| 5 | generalPurpose | env vars + CORS |
| 6 | ci-investigator | loop 48h sem regressão |
