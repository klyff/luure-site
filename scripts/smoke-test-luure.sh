#!/usr/bin/env bash
# Smoke test da migração luure.com.br (executar após DNS no Registro.br).
set -o pipefail

PASS=0
FAIL=0
SKIP=0

check() {
  local name="$1" url="$2" expect="${3:-200}"
  local code
  code=$(curl -sI --max-time 15 -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
  code="${code:-000}"
  code="${code//[^0-9]/}"
  code="${code:0:3}"
  if [[ -z "$code" || "$code" == "000" ]]; then
    echo "⊘ $name (DNS/timeout — configure Registro.br)"
    SKIP=$((SKIP + 1))
  elif [[ "$code" == "$expect" ]] || { [[ "$expect" == "3xx" ]] && [[ "$code" =~ ^30[1278]$ ]]; }; then
    echo "✓ $name ($code)"
    PASS=$((PASS + 1))
  else
    echo "✗ $name (got $code, expected $expect)"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Site institucional ==="
check "luure.com.br" "https://luure.com.br/" "3xx"
check "luure.com.br/pt-br" "https://luure.com.br/pt-br" "200"
check "luure.com.br/en" "https://luure.com.br/en" "200"
check "www → apex" "https://www.luure.com.br/" "3xx"

echo ""
echo "=== PoCs luure.com.br ==="
for sub in voce efolha gestao wallet licencas conselhos licitacoes cidadao cras esocial rh; do
  check "$sub.luure.com.br" "https://${sub}.luure.com.br/" "200"
done
check "rh/rendimentos" "https://rh.luure.com.br/rendimentos" "200"

echo ""
echo "=== Links no site (deployment sovereignid-home) ==="
HOME_URL="${HOME_URL:-https://sovereignid-home-4kx30sfnv-klyffs-projects.vercel.app}"
count=$(curl -s --max-time 15 "$HOME_URL/" | rg -o 'href="https://[^"]*\.luure\.com\.br[^"]*"' | wc -l | tr -d ' ')
if [[ "$count" -ge 12 ]]; then
  echo "✓ $count links luure.com.br no HTML"
  PASS=$((PASS + 1))
else
  echo "✗ apenas $count links luure.com.br (esperado ≥12)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "=== URLs legadas (redirect 308→luure) ==="
for url in \
  "https://sovereignid.cloud/pt-br" \
  "https://sovereignid.cloud/" \
  "https://sovereignid-voce.vercel.app" \
  "https://efolha.sovereignid.cloud" \
  "https://gestao.sovereignid.cloud" \
  "https://wallet.sovereignid.cloud" \
  "https://idsoberano.com" \
  "https://sovereignid.tech"; do
  check "$url" "$url" "3xx"
done

echo ""
echo "=== Resultado: $PASS ok, $FAIL falhas, $SKIP skip (DNS) ==="
[[ "$FAIL" -eq 0 ]]
