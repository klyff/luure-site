#!/usr/bin/env bash
# Build e deploy das PoCs do monorepo luure-frontends para os projetos Vercel.
# Requer: clone de github.com/klyff/luure-frontends e vercel CLI autenticado.
set -eo pipefail

REPO_ROOT="${REPO_ROOT:-/Users/klyff/git/luure-migration-work/luure-frontends-fresh}"
FRONTEND="${FRONTEND:-${REPO_ROOT}}"
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

deploy_frontend_poc1() {
  local workdir vercel_json
  workdir=$(mktemp -d)
  vercel_json="${FRONTEND}/config/vercel-poc1.json"
  [[ -f "$vercel_json" ]] || vercel_json="${SITE}/config/vercel-frontend-poc1.json"
  echo "=== Deploy frontend (efolha, gestao, wallet) ==="
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

deploy_single() {
  local project="$1"
  local build_script="$2"
  local out_subdir="$3"
  local old_vercel_host="$4"
  local new_host="$5"
  local workdir
  workdir=$(mktemp -d)
  echo "=== Deploy ${project} ==="
  (
    cd "${FRONTEND}"
    npm run "$build_script"
    cp -R "dist/${out_subdir}/"* "${workdir}/"
    if [[ -n "$old_vercel_host" ]]; then
      make_spa_vercel_json "$old_vercel_host" "$new_host" > "${workdir}/vercel.json"
    else
      cp "${FRONTEND}/config/vercel-spa.json" "${workdir}/vercel.json"
    fi
    cd "${workdir}"
    vercel link --project "$project" --yes >/dev/null 2>&1
    vercel --prod --yes
  )
  rm -rf "$workdir"
}

if [[ ! -d "$FRONTEND" ]]; then
  echo "Clone o monorepo: gh repo clone klyff/luure-frontends ${REPO_ROOT}"
  exit 1
fi

cd "$FRONTEND"
npm ci

deploy_frontend_poc1
deploy_sou
deploy_single sovereignid-licencas build:licencas licencas sovereignid-licencas.vercel.app licencas.luure.com.br
deploy_single sovereignid-conselhos build:conselhos conselhos sovereignid-conselhos.vercel.app conselhos.luure.com.br
deploy_single sovereignid-licitacoes build:licitacoes licitacoes sovereignid-licitacoes.vercel.app licitacoes.luure.com.br
deploy_single sovereignid-cidadao build:cidadao cidadao sovereignid-cidadao.vercel.app cidadao.luure.com.br
deploy_single sovereignid-cras build:cras cras sovereignid-cras.vercel.app cras.luure.com.br
deploy_single sovereignid-esocial build:esocial esocial sovereignid-esocial.vercel.app esocial.luure.com.br
deploy_single sovereignid-rh build:rh rh sovereignid-rh.vercel.app rh.luure.com.br

echo "Deploy concluído."
