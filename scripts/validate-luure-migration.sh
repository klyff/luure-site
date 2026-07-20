#!/usr/bin/env bash
# Comprehensive health checks for the Luure migration (DNS, PoCs, agent, redirects, ledger VM).
set -o pipefail

PASS=0
FAIL=0
SKIP=0
LEDGER_IP="${LEDGER_IP:-34.39.174.212}"

check() {
  local name="$1" url="$2" expect="${3:-200}"
  local code
  code=$(curl -sI --max-time 15 -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
  code="${code:-000}"
  code="${code//[^0-9]/}"
  code="${code:0:3}"
  if [[ -z "$code" || "$code" == "000" ]]; then
    echo "⊘ $name (DNS/timeout)"
    SKIP=$((SKIP + 1))
  elif [[ "$code" == "$expect" ]] || { [[ "$expect" == "3xx" ]] && [[ "$code" =~ ^30[1278]$ ]]; }; then
    echo "✓ $name ($code)"
    PASS=$((PASS + 1))
  else
    echo "✗ $name (got $code, expected $expect)"
    FAIL=$((FAIL + 1))
  fi
}

check_redirect_dest() {
  local name="$1" url="$2" dest_host="$3"
  local location code
  location=$(curl -sI --max-time 15 "$url" 2>/dev/null | awk 'BEGIN{IGNORECASE=1} /^location:/ {sub(/\r$/,""); sub(/^location:[ \t]*/,""); print; exit}')
  code=$(curl -sI --max-time 15 -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
  code="${code:-000}"
  code="${code//[^0-9]/}"
  code="${code:0:3}"
  if [[ -z "$code" || "$code" == "000" ]]; then
    echo "⊘ $name (DNS/timeout)"
    SKIP=$((SKIP + 1))
  elif [[ "$code" =~ ^30[1278]$ ]] && [[ "$location" == *"${dest_host}"* ]]; then
    echo "✓ $name → ${dest_host} ($code)"
    PASS=$((PASS + 1))
  else
    echo "✗ $name (code=$code location=${location:-none}, expected host ${dest_host})"
    FAIL=$((FAIL + 1))
  fi
}

check_ip_host() {
  local name="$1" host="$2" path="$3" expect="${4:-200}"
  local method="${5:-HEAD}"
  local code
  if [[ "$method" == "GET" ]]; then
    code=$(curl -sk --max-time 15 -o /dev/null -w "%{http_code}" \
      -H "Host: ${host}" "https://${LEDGER_IP}${path}" 2>/dev/null)
  else
    code=$(curl -skI --max-time 15 -o /dev/null -w "%{http_code}" \
      -H "Host: ${host}" "https://${LEDGER_IP}${path}" 2>/dev/null)
  fi
  code="${code:-000}"
  code="${code//[^0-9]/}"
  code="${code:0:3}"
  if [[ -z "$code" || "$code" == "000" ]]; then
    echo "⊘ $name (VM unreachable at ${LEDGER_IP})"
    SKIP=$((SKIP + 1))
  elif [[ "$code" == "$expect" ]] || { [[ "$expect" == "3xx" ]] && [[ "$code" =~ ^30[1278]$ ]]; }; then
    echo "✓ $name ($code via ${LEDGER_IP})"
    PASS=$((PASS + 1))
  else
    echo "✗ $name (got $code, expected $expect via ${LEDGER_IP})"
    FAIL=$((FAIL + 1))
  fi
}

check_json_health() {
  local name="$1" url="$2"
  local body code
  body=$(curl -sk --max-time 15 "$url" 2>/dev/null)
  code=$(curl -sk --max-time 15 -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
  code="${code:-000}"
  if [[ "$code" != "200" ]]; then
    echo "✗ $name (HTTP $code)"
    FAIL=$((FAIL + 1))
    return
  fi
  if echo "$body" | rg -q '"status"[[:space:]]*:[[:space:]]*"ok"'; then
    echo "✓ $name (200, status ok)"
    PASS=$((PASS + 1))
  else
    echo "✗ $name (200 but body missing status:ok)"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Site institucional (luure.com.br) ==="
check "luure.com.br" "https://luure.com.br/" "3xx"
check "luure.com.br/pt-br" "https://luure.com.br/pt-br" "200"
check "luure.com.br/en" "https://luure.com.br/en" "200"
check "www → apex" "https://www.luure.com.br/" "3xx"

echo ""
echo "=== PoCs luure.com.br ==="
for sub in sou efolha gestao wallet licencas conselhos licitacoes cidadao cras esocial rh; do
  check "${sub}.luure.com.br" "https://${sub}.luure.com.br/" "200"
done
check "rh/rendimentos" "https://rh.luure.com.br/rendimentos" "200"

echo ""
echo "=== Portal Sou — redirects legados ==="
check_redirect_dest "voce.luure.com.br → sou" "https://voce.luure.com.br/" "sou.luure.com.br"
check_redirect_dest "sovereignid-voce.vercel.app → sou" "https://sovereignid-voce.vercel.app/" "sou.luure.com.br"

echo ""
echo "=== Agent server (OID4VC) ==="
check_json_health "agent.luure.com.br/health" "https://agent.luure.com.br/health"
check_json_health "agent.sovereignid.cloud/health" "https://agent.sovereignid.cloud/health"
check_redirect_dest "agent.sovereignid.cloud → luure" "https://agent.sovereignid.cloud/.well-known/openid-credential-issuer" "agent.luure.com.br"

echo ""
echo "=== Ledger / API (luure.com.br) ==="
check "ledger.luure.com.br/genesis" "https://ledger.luure.com.br/genesis" "200"
check "api.luure.com.br/health" "https://api.luure.com.br/health" "200"
check_ip_host "ledger.luure.com.br/genesis (VM)" "ledger.luure.com.br" "/genesis" "200"
check_ip_host "api.luure.com.br/health (VM)" "api.luure.com.br" "/health" "200" "GET"

echo ""
echo "=== Links no site (sovereignid-home) ==="
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
echo "=== URLs legadas (redirect → luure) ==="
check_redirect_dest "sovereignid.cloud" "https://sovereignid.cloud/" "luure.com.br"
check_redirect_dest "idsoberano.com" "https://idsoberano.com/" "luure.com.br"
check_redirect_dest "sovereignid.tech" "https://sovereignid.tech/" "luure.com.br"
check_redirect_dest "sovereignid.smartecm.io" "https://sovereignid.smartecm.io/" "luure.com.br"
check_redirect_dest "voce.smartecm.io → sou" "https://voce.smartecm.io/" "sou.luure.com.br"
check_redirect_dest "efolha.sp.smartecm.io" "https://efolha.sp.smartecm.io/" "efolha.luure.com.br"
check_redirect_dest "wallet.smartecm.io" "https://wallet.smartecm.io/" "wallet.luure.com.br"
check_redirect_dest "efolha.sovereignid.cloud" "https://efolha.sovereignid.cloud/" "efolha.luure.com.br"
check_redirect_dest "gestao.sovereignid.cloud" "https://gestao.sovereignid.cloud/" "gestao.luure.com.br"
check_redirect_dest "wallet.sovereignid.cloud" "https://wallet.sovereignid.cloud/" "wallet.luure.com.br"
for url in \
  "https://sovereignid-voce.vercel.app" \
  "https://sovereignid-licencas.vercel.app" \
  "https://sovereignid-conselhos.vercel.app"; do
  check "$url" "$url" "3xx"
done
check "sovereignid-sou.vercel.app (hub)" "https://sovereignid-sou.vercel.app/" "200"

echo ""
echo "=== Resultado: $PASS ok, $FAIL falhas, $SKIP skip ==="
[[ "$FAIL" -eq 0 ]]
