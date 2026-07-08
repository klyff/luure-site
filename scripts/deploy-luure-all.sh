#!/usr/bin/env bash
# Build e deploy de todos os projetos luure-* na Vercel.
# Usa klyff/luure-frontends (monorepo) e mapeia para projetos Vercel existentes ou luure-*.
set -eo pipefail

FRONTEND="${FRONTEND:-/Users/klyff/git/luure-migration-work/luure-frontends-fresh}"
AGENT="${AGENT:-/Users/klyff/git/luure-migration-work/luure-agent}"
SITE="${SITE:-/Users/klyff/git/luure-migration-work/luure-site}"

make_redirect_json() {
  local old_host="$1" new_url="$2"
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
      make_redirect_json "$old_host" "$new_host" > "${workdir}/vercel.json"
    fi
    cd "${workdir}"
    vercel link --project "$project" --yes >/dev/null 2>&1
    vercel --prod --yes
  )
  rm -rf "$workdir"
}

deploy_poc1() {
  local workdir
  workdir=$(mktemp -d)
  echo "=== Deploy luure-poc1 (efolha, gestao, wallet) ==="
  (
    cd "${FRONTEND}"
    npm run build:efolha
    npm run build:gestao
    npm run build:wallet
    cp -R dist/efolha dist/gestao dist/wallet "${workdir}/"
    cp "${SITE}/../config/vercel-frontend-poc1.json" "${workdir}/vercel.json" 2>/dev/null \
      || cp "${FRONTEND}/vercel.json" "${workdir}/vercel.json" 2>/dev/null \
      || cat > "${workdir}/vercel.json" <<'VJ'
{
  "installCommand": "",
  "buildCommand": "",
  "framework": null,
  "rewrites": [
    { "source": "/(.*)", "has": [{ "type": "host", "value": "efolha.luure.com.br" }], "destination": "/efolha/$1" },
    { "source": "/(.*)", "has": [{ "type": "host", "value": "gestao.luure.com.br" }], "destination": "/gestao/$1" },
    { "source": "/(.*)", "has": [{ "type": "host", "value": "wallet.luure.com.br" }], "destination": "/wallet/$1" }
  ],
  "redirects": [
    { "source": "/:path(.*)", "has": [{ "type": "host", "value": "efolha.sovereignid.cloud" }], "destination": "https://efolha.luure.com.br/:path", "permanent": true },
    { "source": "/:path(.*)", "has": [{ "type": "host", "value": "gestao.sovereignid.cloud" }], "destination": "https://gestao.luure.com.br/:path", "permanent": true },
    { "source": "/:path(.*)", "has": [{ "type": "host", "value": "wallet.sovereignid.cloud" }], "destination": "https://wallet.luure.com.br/:path", "permanent": true }
  ]
}
VJ
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
deploy_static sovereignid-voce build:voce voce sovereignid-voce.vercel.app voce.luure.com.br
deploy_static sovereignid-licencas build:licencas licencas sovereignid-licencas.vercel.app licencas.luure.com.br
deploy_static sovereignid-conselhos build:conselhos conselhos sovereignid-conselhos.vercel.app conselhos.luure.com.br
deploy_static sovereignid-licitacoes build:licitacoes licitacoes sovereignid-licitacoes.vercel.app licitacoes.luure.com.br
deploy_static sovereignid-cidadao build:cidadao cidadao sovereignid-cidadao.vercel.app cidadao.luure.com.br
deploy_static sovereignid-cras build:cras cras sovereignid-cras.vercel.app cras.luure.com.br
deploy_static sovereignid-esocial build:esocial esocial sovereignid-esocial.vercel.app esocial.luure.com.br
deploy_static sovereignid-rh build:rh rh sovereignid-rh.vercel.app rh.luure.com.br

echo "Deploy luure concluído."
