# DNS luure.com.br — Registro.br

Configure estes registros em [Registro.br](https://registro.br) → **Meus Domínios** → `luure.com.br` → **Editar Zona**.

## Opção A — Delegar DNS à Vercel (recomendado, mais rápido)

No Registro.br → **Meus Domínios** → `luure.com.br` → **Alterar Servidores DNS**:

- `ns1.vercel-dns.com`
- `ns2.vercel-dns.com`

A Vercel já possui wildcard `*` configurado para todos os subdomínios das PoCs.

## Opção B — Manter DNS no Registro.br

| Nome / Host | Tipo  | Valor                  | TTL  |
|-------------|-------|------------------------|------|
| `@` (vazio) | `A`   | `76.76.21.21`          | 3600 |
| `www`       | `CNAME` | `cname.vercel-dns.com` | 3600 |

### Subdomínios das PoCs (após Fase 1 validada)

| Nome / Host   | Tipo    | Valor                  |
|---------------|---------|------------------------|
| `voce`        | `CNAME` | `cname.vercel-dns.com` |
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
## Verificação

```bash
dig +short luure.com.br A
dig +short www.luure.com.br CNAME
dig +short voce.luure.com.br CNAME

curl -I https://luure.com.br/
curl -I https://www.luure.com.br/
```

Aguarde propagação (até 48h). No painel Vercel, o domínio deve aparecer como **Verified** com SSL ativo.

## Projeto Vercel

- **Site institucional:** `sovereignid-home` (mesmo conteúdo de `sovereignid.cloud`)
- **Domínios:** `luure.com.br`, `www.luure.com.br`
