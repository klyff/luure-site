#!/usr/bin/env bash
# Verifica DNS das PoCs luure.com.br e provisiona CNAME no Registro.br quando possível.
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CNAME_TARGET="cname.vercel-dns.com"
VERCEL_A="76.76.21.21"
VERCEL_NS1="ns1.vercel-dns.com"
VERCEL_NS2="ns2.vercel-dns.com"

SUBDOMAINS=(
  sou efolha gestao wallet licencas conselhos licitacoes
  cidadao cras esocial rh agent voce
)

missing=()
ok=()
vercel_ok=()

resolve_public() {
  local fqdn="$1"
  local cname a
  cname=$(dig +short "$fqdn" CNAME 2>/dev/null | head -1)
  a=$(dig +short "$fqdn" A 2>/dev/null | head -1)
  if [[ -n "$cname" || "$a" == "$VERCEL_A" || "$a" == 64.* || "$a" == 216.* ]]; then
    return 0
  fi
  return 1
}

resolve_vercel_ns() {
  local fqdn="$1"
  local a
  a=$(dig +short "$fqdn" "@${VERCEL_NS1}" 2>/dev/null | head -1)
  [[ -n "$a" ]]
}

contains_vercel_ns() {
  [[ "$1" == *vercel-dns.com* ]]
}

public_ns=$(dig +short luure.com.br NS 2>/dev/null | tr '\n' ' ')
vercel_ns=$(dig +short luure.com.br NS "@${VERCEL_NS1}" 2>/dev/null | tr '\n' ' ')
ns_on_vercel=false
contains_vercel_ns "$public_ns" && ns_on_vercel=true

echo "=== Nameservers luure.com.br ==="
echo "Público:     ${public_ns:-desconhecido}"
echo "Vercel DNS:  ${vercel_ns:-desconhecido}"

if $ns_on_vercel; then
  echo "Status: ✓ NS delegados à Vercel (propagação concluída ou em curso na sua rede)"
elif contains_vercel_ns "$vercel_ns"; then
  echo "Status: ⏳ Transição em andamento — Vercel já responde, registradores públicos ainda no Registro.br"
  echo "        Aguarde a propagação (~2h após alterar NS no Registro.br)."
else
  echo "Status: ✗ NS ainda no Registro.br — delegue à Vercel ou adicione CNAMEs manualmente"
fi

echo ""
echo "=== DNS luure.com.br (PoCs) — resolvers públicos ==="
for sub in "${SUBDOMAINS[@]}"; do
  fqdn="${sub}.luure.com.br"
  if resolve_public "$fqdn"; then
    cname=$(dig +short "$fqdn" CNAME 2>/dev/null | head -1)
    a=$(dig +short "$fqdn" A 2>/dev/null | head -1)
    echo "✓ $fqdn → ${cname:-A $a}"
    ok+=("$fqdn")
  else
    echo "✗ $fqdn (sem registro DNS público)"
    missing+=("$sub")
  fi
done

echo ""
echo "=== Prévia na Vercel DNS (@${VERCEL_NS1}) ==="
for sub in "${SUBDOMAINS[@]}"; do
  fqdn="${sub}.luure.com.br"
  if resolve_vercel_ns "$fqdn"; then
    a=$(dig +short "$fqdn" "@${VERCEL_NS1}" 2>/dev/null | head -1)
    echo "✓ $fqdn → A $a"
    vercel_ok+=("$fqdn")
  else
    echo "✗ $fqdn (não resolve na Vercel)"
  fi
done

echo ""
echo "Público: ${#ok[@]}/${#SUBDOMAINS[@]} | Vercel DNS: ${#vercel_ok[@]}/${#SUBDOMAINS[@]}"

if [[ ${#missing[@]} -eq 0 ]]; then
  echo ""
  echo "=== HTTPS (certificados SSL) ==="
  ssl_missing=()
  for sub in "${SUBDOMAINS[@]}"; do
    fqdn="${sub}.luure.com.br"
    code=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 15 "https://${fqdn}/" 2>/dev/null || echo "000")
    if [[ "$code" == "200" || "$code" == "301" || "$code" == "302" || "$code" == "308" ]]; then
      echo "✓ https://${fqdn}/ → ${code}"
    else
      echo "✗ https://${fqdn}/ → ${code} (certificado SSL pendente)"
      ssl_missing+=("$sub")
    fi
  done

  if [[ ${#ssl_missing[@]} -eq 0 ]]; then
    echo ""
    echo "DNS e HTTPS OK em todos os subdomínios."
    exit 0
  fi

  echo ""
  echo "=== Emitir certificados SSL ==="
  echo "DNS OK, mas ${#ssl_missing[@]} subdomínio(s) sem HTTPS."
  echo "Execute: ${SCRIPT_DIR}/issue-luure-certs.sh"
  if [[ "${AUTO_ISSUE_CERTS:-}" == "1" ]]; then
    "${SCRIPT_DIR}/issue-luure-certs.sh"
  fi
  exit 1
fi

echo ""
echo "=== Vercel: domínios nos projetos ==="
"${SCRIPT_DIR}/add-luure-poc-domains.sh" 2>/dev/null || true

if [[ ${#vercel_ok[@]} -ge $((${#SUBDOMAINS[@]} - 1)) && ${#missing[@]} -gt 0 ]]; then
  echo ""
  echo "=== Diagnóstico ==="
  echo "Deploy e domínios Vercel estão OK. O bloqueio é só propagação de NS."
  echo "Quando 'dig +short luure.com.br NS' retornar ns1/ns2.vercel-dns.com, todos os PoCs sobem."
  echo ""
  echo "Verificar propagação:"
  echo "  dig +short luure.com.br NS @8.8.8.8"
  echo "  dig +short licencas.luure.com.br @8.8.8.8"
  exit 1
fi

if [[ -n "${REGISTROBR_USER:-}" && -n "${REGISTROBR_PASS:-}" ]]; then
  echo ""
  echo "=== Registro.br: provisionando CNAME via Puppeteer ==="
  (
    cd "$ROOT"
    if [[ ! -d node_modules/puppeteer ]]; then
      npm install --no-save puppeteer >/dev/null
    fi
    node scripts/provision-luure-dns-registrobr.mjs
  )
  exit 0
fi

echo ""
echo "=== Ação manual no Registro.br (escolha uma) ==="
echo ""
echo "Opção A — mais rápida (recomendada): delegar DNS à Vercel"
echo "  Registro.br → luure.com.br → Alterar Servidores DNS:"
echo "    ${VERCEL_NS1}"
echo "    ${VERCEL_NS2}"
echo "  (A Vercel já tem wildcard * configurado na zona luure.com.br)"
echo ""
echo "Opção B — manter DNS no Registro.br: adicionar CNAME para cada host → ${CNAME_TARGET}"
for sub in "${missing[@]}"; do
  echo "  - ${sub}  CNAME  ${CNAME_TARGET}"
done
echo ""
echo "Opção C — automática: exporte credenciais e reexecute este script"
echo "  REGISTROBR_USER=... REGISTROBR_PASS=... ${SCRIPT_DIR}/provision-luure-dns.sh"
echo ""
exit 1
