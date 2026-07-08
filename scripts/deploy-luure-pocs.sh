#!/usr/bin/env bash
# Build e deploy das PoCs do monorepo sovereignid para os projetos Vercel.
# Requer: clone de github.com/klyff/sovereignid e vercel CLI autenticado.
set -eo pipefail

REPO_ROOT="${REPO_ROOT:-/tmp/sovereignid-monorepo}"
FRONTEND="${REPO_ROOT}/frontend"

deploy_package() {
  local project="$1"
  local pkg_dir="$2"
  local build_cmd="$3"
  local vercel_json="$4"
  local workdir
  workdir=$(mktemp -d)
  echo "=== Deploy ${project} (${pkg_dir}) ==="
  (
    cd "${FRONTEND}"
    eval "$build_cmd"
    cp -R "${FRONTEND}/dist/${pkg_dir}/"* "${workdir}/" 2>/dev/null || cp -R "${FRONTEND}/dist/${pkg_dir}/." "${workdir}/"
    cp "$vercel_json" "${workdir}/vercel.json"
    cd "${workdir}"
    vercel link --project "$project" --yes >/dev/null 2>&1
    vercel --prod --yes
  )
  rm -rf "$workdir"
}

# PoC 1 — projeto frontend (3 apps num deploy)
deploy_frontend_poc1() {
  local workdir
  workdir=$(mktemp -d)
  echo "=== Deploy frontend (efolha, gestao, wallet) ==="
  (
    cd "${FRONTEND}"
    npm run build:efolha
    npm run build:gestao
    npm run build:wallet
    cp -R dist/efolha dist/gestao dist/wallet "${workdir}/"
    cp vercel.json "${workdir}/"
    cd "${workdir}"
    vercel link --project frontend --yes >/dev/null 2>&1
    vercel --prod --yes
  )
  rm -rf "$workdir"
}

make_redirect_json() {
  local old_host="$1"
  local new_url="$2"
  cat <<EOF
{
  "installCommand": "",
  "buildCommand": "",
  "framework": null,
  "redirects": [
    {
      "source": "/:path(.*)",
      "has": [{ "type": "host", "value": "${old_host}" }],
      "destination": "https://${new_url}/:path",
      "permanent": true
    }
  ]
}
EOF
}

make_dual_redirect_json() {
  local old1="$1" old2="$2" new_url="$3"
  cat <<EOF
{
  "installCommand": "",
  "buildCommand": "",
  "framework": null,
  "redirects": [
    {
      "source": "/:path(.*)",
      "has": [{ "type": "host", "value": "${old1}" }],
      "destination": "https://${new_url}/:path",
      "permanent": true
    },
    {
      "source": "/:path(.*)",
      "has": [{ "type": "host", "value": "${old2}" }],
      "destination": "https://${new_url}/:path",
      "permanent": true
    }
  ]
}
EOF
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
      make_redirect_json "$old_vercel_host" "$new_host" > "${workdir}/vercel.json"
    fi
    cd "${workdir}"
    vercel link --project "$project" --yes >/dev/null 2>&1
    vercel --prod --yes
  )
  rm -rf "$workdir"
}

if [[ ! -d "$FRONTEND" ]]; then
  echo "Clone o monorepo: gh repo clone klyff/sovereignid ${REPO_ROOT}"
  exit 1
fi

cd "$FRONTEND"
npm ci

deploy_frontend_poc1
deploy_single sovereignid-voce build:voce voce sovereignid-voce.vercel.app voce.luure.com.br
deploy_single sovereignid-licencas build:licencas licencas sovereignid-licencas.vercel.app licencas.luure.com.br
deploy_single sovereignid-conselhos build:conselhos conselhos sovereignid-conselhos.vercel.app conselhos.luure.com.br
deploy_single sovereignid-licitacoes build:licitacoes licitacoes sovereignid-licitacoes.vercel.app licitacoes.luure.com.br
deploy_single sovereignid-cidadao build:cidadao cidadao sovereignid-cidadao.vercel.app cidadao.luure.com.br
deploy_single sovereignid-cras build:cras cras sovereignid-cras.vercel.app cras.luure.com.br
deploy_single sovereignid-esocial build:esocial esocial sovereignid-esocial.vercel.app esocial.luure.com.br
deploy_single sovereignid-rh build:rh rh sovereignid-rh.vercel.app rh.luure.com.br

echo "Deploy concluído."
