# DNS luure.com.br — Registro.br

Configure estes registros em [Registro.br](https://registro.br) → **Meus Domínios** → `luure.com.br` → **Editar Zona**.

## Opção A — Delegar DNS à Vercel (recomendado, mais rápido)

No Registro.br → **Meus Domínios** → `luure.com.br` → **Alterar Servidores DNS**:

- `ns1.vercel-dns.com`
- `ns2.vercel-dns.com`

A Vercel já possui wildcard `*` configurado para todos os subdomínios das PoCs. **Um único passo no Registro.br libera todos os subdomínios** (`licencas`, `efolha`, `cidadao`, etc.).

Automatizar verificação e provisionamento (com credenciais Registro.br):

```bash
# Verifica DNS + HTTPS + domínios na Vercel
./scripts/provision-luure-dns.sh

# Após NS propagar, emitir certificados SSL (se browser der ERR_CONNECTION_CLOSED)
./scripts/issue-luure-certs.sh

# Com login Registro.br (Puppeteer — adiciona CNAME faltantes)
REGISTROBR_USER=... REGISTROBR_PASS=... ./scripts/provision-luure-dns.sh
```

## Opção B — Manter DNS no Registro.br

| Nome / Host | Tipo  | Valor                  | TTL  |
|-------------|-------|------------------------|------|
| `@` (vazio) | `A`   | `76.76.21.21`          | 3600 |
| `www`       | `CNAME` | `cname.vercel-dns.com` | 3600 |

### Subdomínios das PoCs (após Fase 1 validada)

| Nome / Host   | Tipo    | Valor                  |
|---------------|---------|------------------------|
| `sou`         | `CNAME` | `cname.vercel-dns.com` |
| `voce`        | `CNAME` | `cname.vercel-dns.com` (legado → redirect para `sou`) |
| `efolha`      | `CNAME` | `cname.vercel-dns.com` |
| `gestao`      | `CNAME` | `cname.vercel-dns.com` |
| `wallet`      | `CNAME` | `cname.vercel-dns.com` |
| `licencas`    | `CNAME` | `cname.vercel-dns.com` |
| `conselhos`   | `CNAME` | `cname.vercel-dns.com` |
| `licitacoes`  | `CNAME` | `cname.vercel-dns.com` |
| `cidadao`     | `CNAME` | `cname.vercel-dns.com` |
| `cras`        | `CNAME` | `cname.vercel-dns.com` |
| `esocial`     | `CNAME` | `cname.vercel-dns.com` |
| `rh`          | `CNAME` | `cname.vercel-dns.com` |
| `agent`       | `CNAME` | `cname.vercel-dns.com` |
| `ledger`      | `A`     | `34.39.174.212` (VM GCP — nginx Indy) |
| `api`         | `A`     | `34.39.174.212` (VM GCP — FastAPI) |

## Verificação

```bash
dig +short luure.com.br A
dig +short www.luure.com.br CNAME
dig +short sou.luure.com.br CNAME
dig +short voce.luure.com.br CNAME

dig +short ledger.luure.com.br A
dig +short api.luure.com.br A

curl -I https://luure.com.br/
curl -I https://www.luure.com.br/
```

Aguarde propagação (até 48h). No painel Vercel, o domínio deve aparecer como **Verified** com SSL ativo.

## Projeto Vercel

- **Site institucional:** `sovereignid-home` (mesmo conteúdo de `sovereignid.cloud`)
- **Domínios:** `luure.com.br`, `www.luure.com.br`
