#!/usr/bin/env bash
# Build e deploy de todos os projetos luure-* na Vercel.
# Usa klyff/luure-frontends (monorepo) e mapeia para projetos Vercel existentes ou luure-*.
set -eo pipefail

FRONTEND="${FRONTEND:-/Users/klyff/git/luure-migration-work/luure-frontends-fresh}"
AGENT="${AGENT:-/Users/klyff/git/luure-migration-work/luure-agent}"
SITE="${SITE:-/Users/klyff/git/sovereignID.io}"

make_spa_vercel_json() {
  local old_host="$1"
  local new_host="$2"
  if [[ -x "${FRONTEND}/scripts/make-vercel-spa.sh" ]]; then
    "${FRONTEND}/scripts/make-vercel-spa.sh" "$old_host" "$new_host"
  else
    cat <<EOF
{
  "installCommand": "",
  "buildCommand": "",
  "framework": null,
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ],
  "redirects": [
    {
      "source": "/:path*",
      "has": [{ "type": "host", "value": "${old_host}" }],
      "destination": "https://${new_host}/:path*",
      "permanent": true
    }
  ]
}
EOF
  fi
}

deploy_static() {
  local project="$1" build_script="$2" out_subdir="$3" old_host="$4" new_host="$5"
  local workdir
  workdir=$(mktemp -d)
  echo "=== Deploy ${project} (${out_subdir}) ==="
  (
    cd "${FRONTEND}"
    npm run "$build_script"
    cp -R "dist/${out_subdir}/"* "${workdir}/"
    if [[ -n "$old_host" ]]; then
      make_spa_vercel_json "$old_host" "$new_host" > "${workdir}/vercel.json"
    else
      cp "${FRONTEND}/config/vercel-spa.json" "${workdir}/vercel.json"
    fi
    cd "${workdir}"
    vercel link --project "$project" --yes >/dev/null 2>&1
    vercel --prod --yes
  )
  rm -rf "$workdir"
}

deploy_sou() {
  local workdir vercel_json
  workdir=$(mktemp -d)
  vercel_json="${FRONTEND}/config/vercel-sou.json"
  [[ -f "$vercel_json" ]] || vercel_json="${SITE}/config/vercel-sou-redirects.json"
  echo "=== Deploy sovereignid-sou (Portal Sou) ==="
  (
    cd "${FRONTEND}"
    npm run build:sou
    cp -R "dist/sou/"* "${workdir}/"
    cp "$vercel_json" "${workdir}/vercel.json"
    cd "${workdir}"
    vercel link --project sovereignid-sou --yes >/dev/null 2>&1
    vercel --prod --yes
  )
  rm -rf "$workdir"
}

deploy_poc1() {
  local workdir vercel_json
  workdir=$(mktemp -d)
  vercel_json="${FRONTEND}/config/vercel-poc1.json"
  [[ -f "$vercel_json" ]] || vercel_json="${SITE}/config/vercel-frontend-poc1.json"
  echo "=== Deploy luure-poc1 (efolha, gestao, wallet) ==="
  (
    cd "${FRONTEND}"
    npm run build:efolha
    npm run build:gestao
    npm run build:wallet
    cp -R dist/efolha dist/gestao dist/wallet "${workdir}/"
    cp "$vercel_json" "${workdir}/vercel.json"
    cd "${workdir}"
    vercel link --project frontend --yes >/dev/null 2>&1
    vercel --prod --yes
  )
  rm -rf "$workdir"
}

deploy_agent() {
  echo "=== Deploy luure-agent ==="
  (
    cd "${AGENT}"
    vercel link --project sovereignid-agent --yes >/dev/null 2>&1
    vercel --prod --yes
  )
}

deploy_site() {
  echo "=== Deploy luure-site ==="
  (
    cd "${SITE}"
    vercel link --project sovereignid-home --yes >/dev/null 2>&1
    vercel --prod --yes
  )
}

[[ -d "$FRONTEND" ]] || { echo "Clone luure-frontends primeiro"; exit 1; }
cd "$FRONTEND"
npm ci

deploy_site
deploy_agent
deploy_poc1
deploy_sou
deploy_static sovereignid-licencas build:licencas licencas sovereignid-licencas.vercel.app licencas.luure.com.br
deploy_static sovereignid-conselhos build:conselhos conselhos sovereignid-conselhos.vercel.app conselhos.luure.com.br
deploy_static sovereignid-licitacoes build:licitacoes licitacoes sovereignid-licitacoes.vercel.app licitacoes.luure.com.br
deploy_static sovereignid-cidadao build:cidadao cidadao sovereignid-cidadao.vercel.app cidadao.luure.com.br
deploy_static sovereignid-cras build:cras cras sovereignid-cras.vercel.app cras.luure.com.br
deploy_static sovereignid-esocial build:esocial esocial sovereignid-esocial.vercel.app esocial.luure.com.br
deploy_static sovereignid-rh build:rh rh sovereignid-rh.vercel.app rh.luure.com.br

echo "Deploy luure concluído."
