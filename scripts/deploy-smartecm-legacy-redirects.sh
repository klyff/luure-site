#!/usr/bin/env bash
# Deploy redirects legados *.smartecm.io → *.luure.com.br no projeto sovereignid-io.
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
workdir=$(mktemp -d)

echo "=== Deploy sovereignid-io (legacy smartecm.io redirects) ==="
cp "${ROOT}/config/vercel-smartecm-portal-redirects.json" "${workdir}/vercel.json"
echo '<!doctype html><meta http-equiv="refresh" content="0;url=https://luure.com.br">' > "${workdir}/index.html"

(
  cd "${workdir}"
  vercel link --project sovereignid-io --yes >/dev/null 2>&1
  vercel --prod --yes
)
rm -rf "$workdir"
echo "Legacy smartecm redirects deploy concluído."
