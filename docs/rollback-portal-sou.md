# Rollback — Portal Sou (voce → sou)

Se a migração falhar após deploy:

## 1. Reverter deploy Vercel

No dashboard Vercel → projeto `sovereignid-sou` → Deployments → **Promote** o deployment anterior.

Para o legado `sovereignid-voce`, promover deployment que servia conteúdo em `voce.luure.com.br`.

## 2. Reverter site institucional

```bash
cd sovereignID.io
git revert caaf7d6   # ou checkout branch anterior
vercel link --project sovereignid-home --yes
vercel --prod --yes
```

## 3. DNS

- `sou.luure.com.br` pode permanecer; remova o CNAME se quiser desativar.
- `voce.luure.com.br` continua no projeto `sovereignid-voce` até migrar domínio manualmente.

## 4. Redirect legado temporário

Enquanto `voce.luure.com.br` estiver em `sovereignid-voce`:

```bash
./scripts/deploy-voce-legacy-redirect.sh
```

Isso envia tráfego de `voce.luure.com.br` e `sovereignid-voce.vercel.app` para `sou.luure.com.br`.

## 5. Monorepo frontends

```bash
cd luure-frontends
git checkout main
git revert 4ebab0f
```

Ou manter código `@luure/*` e só reverter URLs no site.
