#!/usr/bin/env bash
# Adiciona subdomínios luure.com.br aos projetos Vercel das PoCs.
# Pré-requisito: registros CNAME no Registro.br (ver docs/DNS_LUURE.md).
set -eo pipefail

CNAME_TARGET="cname.vercel-dns.com"

add_domain() {
  local sub="$1"
  local project="$2"
  local domain="${sub}.luure.com.br"
  local linkdir
  linkdir=$(mktemp -d)
  echo "→ ${domain} → ${project}"
  (
    cd "$linkdir"
    vercel link --project "$project" --yes >/dev/null 2>&1
    vercel domains add "$domain" 2>&1
  ) || echo "  (skip ou já existe: ${domain})"
  rm -rf "$linkdir"
}

add_domain voce sovereignid-voce
add_domain efolha frontend
add_domain gestao frontend
add_domain wallet frontend
add_domain licencas sovereignid-licencas
add_domain conselhos sovereignid-conselhos
add_domain licitacoes sovereignid-licitacoes
add_domain cidadao sovereignid-cidadao
add_domain cras sovereignid-cras
add_domain esocial sovereignid-esocial
add_domain rh sovereignid-rh

echo ""
echo "Concluído. Configure CNAME no Registro.br para cada subdomínio → ${CNAME_TARGET}"
