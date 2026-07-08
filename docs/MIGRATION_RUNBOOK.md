# Luure Migration Runbook

Orquestração da migração sovereignID → luure-* (Vercel + GitHub).

## Repositórios luure-*

| Repo | Deploy | Domínio |
|------|--------|---------|
| [luure-site](https://github.com/klyff/luure-site) | Vercel `sovereignid-home` | `luure.com.br` |
| [luure-frontends](https://github.com/klyff/luure-frontends) | Vercel `frontend` + `sovereignid-*` | `*.luure.com.br` |
| [luure-agent](https://github.com/klyff/luure-agent) | Vercel `sovereignid-agent` | `agent.luure.com.br` |
| [luure-wallet](https://github.com/klyff/luure-wallet) | Expo | app stores |
| [luure-ledger](https://github.com/klyff/luure-ledger) | VM GCP | `ledger.smartecm.io` |
| [luure-infra](https://github.com/klyff/luure-infra) | Terraform/scripts | ops |

## Scripts

| Script | Uso |
|--------|-----|
| `scripts/deploy-luure-all.sh` | Build + deploy site, agent, todas as PoCs |
| `scripts/add-luure-poc-domains.sh` | Anexa `*.luure.com.br` aos projetos Vercel |
| `scripts/validate-luure-migration.sh` | Health check completo |
| `scripts/loop-validate-luure.sh` | Loop 15 min (validação contínua) |
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

# 3. Atualizar DNS smartecm.io portais: A 34.39.174.212 → 76.76.21.21 (Vercel)
#    Manter ledger.smartecm.io e api.smartecm.io no IP da VM
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
