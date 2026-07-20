#!/usr/bin/env bash
# Adiciona subdomínios luure.com.br aos projetos Vercel das PoCs.
# Pré-requisito: registros CNAME no Registro.br (ver docs/DNS_LUURE.md).
set -eo pipefail

added=0
skipped=0

add_domain() {
  local sub="$1"
  local project="$2"
  local domain="${sub}.luure.com.br"
  local linkdir output
  linkdir=$(mktemp -d)
  output=$(
    cd "$linkdir"
    vercel link --project "$project" --yes >/dev/null 2>&1
    NODE_NO_WARNINGS=1 vercel domains add "$domain" 2>&1
  ) || true

  if echo "$output" | grep -Eiq 'already assigned|already exists|Added'; then
    echo "✓ ${domain} → ${project} (já configurado)"
    skipped=$((skipped + 1))
  elif echo "$output" | grep -Eiq 'added|success'; then
    echo "+ ${domain} → ${project}"
    added=$((added + 1))
  else
    echo "? ${domain} → ${project}"
    echo "$output" | grep -Ev 'ExperimentalWarning|trace-warnings' | head -2 | sed 's/^/  /'
  fi
  rm -rf "$linkdir"
}

add_domain sou sovereignid-sou
add_domain voce sovereignid-sou
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
add_domain agent sovereignid-agent

echo ""
echo "Vercel: ${added} adicionados, ${skipped} já existiam."
