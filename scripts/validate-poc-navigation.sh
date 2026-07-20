#!/usr/bin/env bash
# Validação de navegação das PoCs — rotas críticas em hosts canônicos e fallback vercel.app.
# Complementa scripts/validate-luure-migration.sh.
set -o pipefail

PASS=0
FAIL=0
SKIP=0
REPORT_FILE="${REPORT_FILE:-docs/poc-navigation-report.md}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GENERATED_AT="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

check_route() {
  local name="$1" url="$2" expect="${3:-200}"
  local code
  code=$(curl -sI --max-time 15 -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
  code="${code:-000}"
  code="${code//[^0-9]/}"
  code="${code:0:3}"
  if [[ -z "$code" || "$code" == "000" ]]; then
    echo "⊘ $name (DNS/timeout)"
    SKIP=$((SKIP + 1))
    REPORT_LINES+=("| $name | \`$url\` | SKIP | DNS/timeout |")
  elif [[ "$code" == "$expect" ]] || { [[ "$expect" == "3xx" ]] && [[ "$code" =~ ^30[1278]$ ]]; }; then
    echo "✓ $name ($code)"
    PASS=$((PASS + 1))
    REPORT_LINES+=("| $name | \`$url\` | PASS | HTTP $code |")
  else
    echo "✗ $name (got $code, expected $expect)"
    FAIL=$((FAIL + 1))
    REPORT_LINES+=("| $name | \`$url\` | FAIL | HTTP $code (expected $expect) |")
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
    REPORT_LINES+=("| $name | \`$url\` | FAIL | HTTP $code |")
    return
  fi
  if echo "$body" | rg -q '"status"[[:space:]]*:[[:space:]]*"ok"'; then
    echo "✓ $name (200, status ok)"
    PASS=$((PASS + 1))
    REPORT_LINES+=("| $name | \`$url\` | PASS | agent healthy |")
  else
    echo "✗ $name (200 but body missing status:ok)"
    FAIL=$((FAIL + 1))
    REPORT_LINES+=("| $name | \`$url\` | FAIL | missing status:ok |")
  fi
}

check_poc() {
  local app="$1" canonical="$2" fallback="$3"
  shift 3
  local routes=("$@")
  echo ""
  echo "=== $app ==="
  for route in "${routes[@]}"; do
    check_route "${app} canonical ${route}" "https://${canonical}${route}" "200"
    check_route "${app} fallback ${route}" "https://${fallback}${route}" "200"
  done
}

REPORT_LINES=()

echo "=== Agent / wallet integration ==="
check_json_health "agent.luure.com.br/health" "https://agent.luure.com.br/health"
check_json_health "agent.sovereignid.cloud/health" "https://agent.sovereignid.cloud/health"

check_poc "sou" "sou.luure.com.br" "sovereignid-sou.vercel.app" \
  "/" "/entrar" "/minha-carteira" "/privacidade" "/servicos" "/ajuda" "/como-funciona"

check_poc "efolha" "efolha.luure.com.br" "sovereignid-efolha.vercel.app" \
  "/" "/verificar" "/dashboard" "/servicos" "/como-funciona"

check_poc "gestao" "gestao.luure.com.br" "sovereignid-gestao.vercel.app" \
  "/" "/dashboard" "/funcionarios" "/emitir"

check_poc "wallet" "wallet.luure.com.br" "sovereignid-wallet.vercel.app" \
  "/" "/oferta" "/apresentar" "/historico"

check_poc "licencas" "licencas.luure.com.br" "sovereignid-licencas.vercel.app" \
  "/" "/dashboard" "/apresentar"

check_poc "licitacoes" "licitacoes.luure.com.br" "sovereignid-licitacoes.vercel.app" \
  "/" "/dashboard" "/verificar"

check_poc "cidadao" "cidadao.luure.com.br" "sovereignid-cidadao.vercel.app" \
  "/" "/dashboard" "/beneficios" "/comprovar"

check_poc "cras" "cras.luure.com.br" "sovereignid-cras.vercel.app" \
  "/" "/dashboard" "/verificar"

check_poc "esocial" "esocial.luure.com.br" "sovereignid-esocial.vercel.app" \
  "/" "/vinculos" "/apresentar"

check_poc "rh" "rh.luure.com.br" "sovereignid-rh.vercel.app" \
  "/minha-lotacao" "/rendimentos" "/verificar"

echo ""
echo "=== Verificadores (useVerification) ==="
check_route "efolha /verificar" "https://sovereignid-efolha.vercel.app/verificar" "200"
check_route "cras /verificar" "https://sovereignid-cras.vercel.app/verificar" "200"
check_route "licitacoes /verificar" "https://sovereignid-licitacoes.vercel.app/verificar" "200"

echo ""
echo "=== Resultado: $PASS ok, $FAIL falhas, $SKIP skip ==="

{
  echo "# PoC Navigation Report"
  echo ""
  echo "Gerado em: ${GENERATED_AT}"
  echo ""
  echo "**Resultado:** ${PASS} ok, ${FAIL} falhas, ${SKIP} skip (DNS)"
  echo ""
  echo "| Check | URL | Status | Detalhe |"
  echo "|-------|-----|--------|---------|"
  for line in "${REPORT_LINES[@]}"; do
    echo "$line"
  done
  echo ""
  echo "## Como interpretar"
  echo ""
  echo "- **SKIP** em hosts \`*.luure.com.br\`: DNS ainda não propagou — use \`*.vercel.app\` nas demos."
  echo "- **FAIL** em subpaths com 404: falta rewrite SPA no \`vercel.json\` do projeto."
  echo "- **FAIL** só no canônico: verificar domínio anexado ao projeto Vercel correto."
} > "${REPO_ROOT}/${REPORT_FILE}"

echo "Relatório: ${REPO_ROOT}/${REPORT_FILE}"
[[ "$FAIL" -eq 0 ]]
