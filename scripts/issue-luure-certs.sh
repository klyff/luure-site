#!/usr/bin/env bash
# Emite certificados SSL Let's Encrypt na Vercel para subdomínios luure.com.br.
# Necessário após delegar NS à Vercel — a Vercel nem sempre emite automaticamente.
set -eo pipefail

SUBDOMAINS=(
  sou efolha gestao wallet licencas conselhos licitacoes
  cidadao cras esocial rh agent voce
)

issued=0
skipped=0
failed=0

check_https() {
  local fqdn="$1"
  local code
  code=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 15 "https://${fqdn}/" 2>/dev/null || echo "000")
  [[ "$code" == "200" || "$code" == "301" || "$code" == "302" || "$code" == "308" ]]
}

issue_cert() {
  local sub="$1"
  local fqdn="${sub}.luure.com.br"
  local output

  if check_https "$fqdn"; then
    echo "✓ ${fqdn} (HTTPS OK)"
    skipped=$((skipped + 1))
    return 0
  fi

  echo "→ emitindo certificado ${fqdn}…"
  output=$(NODE_NO_WARNINGS=1 vercel certs issue "$fqdn" 2>&1) || true
  if echo "$output" | grep -q "Success"; then
    echo "✓ ${fqdn} certificado emitido"
    issued=$((issued + 1))
  elif echo "$output" | grep -Eiq 'already|exists'; then
    echo "✓ ${fqdn} (certificado já existe)"
    skipped=$((skipped + 1))
  else
    echo "✗ ${fqdn} falhou"
    echo "$output" | grep -Ev 'ExperimentalWarning|trace-warnings' | tail -2 | sed 's/^/  /'
    failed=$((failed + 1))
  fi
}

echo "=== Certificados SSL luure.com.br ==="
for sub in "${SUBDOMAINS[@]}"; do
  issue_cert "$sub"
done

echo ""
echo "Emitidos: ${issued} | OK: ${skipped} | Falhas: ${failed}"

if [[ "$failed" -gt 0 ]]; then
  exit 1
fi

echo ""
echo "Verificação HTTPS:"
for sub in "${SUBDOMAINS[@]}"; do
  fqdn="${sub}.luure.com.br"
  if check_https "$fqdn"; then
    echo "✓ https://${fqdn}/"
  else
    echo "✗ https://${fqdn}/ (aguarde propagação do certificado)"
  fi
done
