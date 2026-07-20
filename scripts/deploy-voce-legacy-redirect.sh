#!/usr/bin/env bash
# Deploy redirect-only config on sovereignid-voce (legado voce.luure.com.br + vercel.app).
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
workdir=$(mktemp -d)

echo "=== Deploy sovereignid-voce (legacy redirect → sou.luure.com.br) ==="
cp "${ROOT}/config/vercel-voce-legacy-redirect.json" "${workdir}/vercel.json"
echo '<!doctype html><meta http-equiv="refresh" content="0;url=https://sou.luure.com.br">' > "${workdir}/index.html"

(
  cd "${workdir}"
  vercel link --project sovereignid-voce --yes >/dev/null 2>&1
  vercel --prod --yes
)
rm -rf "$workdir"
echo "Legacy voce redirect deploy concluído."
