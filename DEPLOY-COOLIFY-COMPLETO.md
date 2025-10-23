# 🚀 Deploy no Coolify - Guia Completo

Este guia explica como configurar o Krayin CRM no Coolify usando as variáveis de ambiente corretas.

## 📋 Variáveis necessárias no Coolify

Copie e cole estas variáveis na seção **Environment Variables** do Coolify:

### ✅ Configuração completa para produção

```bash
# Identificação do cliente
CLIENTE=cabana

# Aplicação
APP_NAME=Cabana
APP_URL=https://crm.cabana.deltaai.solutions
APP_KEY=base64:9bBmZyO+PfFN0WJArNjuWObYl9gkStEjWjmQIz9JUXc
APP_CURRENCY=BRL
ASSET_URL=https://crm.cabana.deltaai.solutions
USER=user_crm_cabana

# Banco de Dados
DB_CONNECTION=mysql
DB_HOST=krayin-mysql
DB_PORT=3306
DB_DATABASE=crm_cabana
DB_USERNAME=krayin_user
DB_PASSWORD=R9k7lPqE4sWvF

# Segurança
SANCTUM_STATEFUL_DOMAINS=https://crm.cabana.deltaai.solutions
SESSION_SECURE_COOKIE=true

# E-mail (SMTP)
MAIL_MAILER=smtp
MAIL_HOST=mail.cabanaecoresort.com.br
MAIL_PORT=465
MAIL_USERNAME=reservas@cabanaecoresort.com.br
MAIL_PASSWORD=ReservaCabana!1
MAIL_ENCRYPTION=ssl
MAIL_FROM_ADDRESS=reservas@cabanaecoresort.com.br
MAIL_FROM_NAME=Cabana Eco Resort
MAIL_REPLY_TO_ADDRESS=reservas@cabanaecoresort.com.br
MAIL_REPLY_TO_NAME=Cabana Eco Resort
```

## 🔍 O que foi ajustado no docker-compose.yml

### ✅ Variáveis adicionadas:

1. **Configurações da aplicação:**
   - `APP_NAME` - Nome da aplicação
   - `APP_URL` - URL principal
   - `APP_KEY` - Chave de criptografia do Laravel
   - `APP_CURRENCY` - Moeda padrão
   - `ASSET_URL` - URL dos assets (CSS, JS, imagens)

2. **Banco de dados:**
   - Todas as variáveis já estavam presentes (`DB_*`)

3. **Redis (Cache e Sessão):**
   - `CACHE_DRIVER=redis` - Usa Redis para cache
   - `SESSION_DRIVER=redis` - Usa Redis para sessões
   - `QUEUE_CONNECTION=sync` - Filas síncronas
   - `REDIS_HOST=krayin-redis` - Aponta para o container Redis

4. **Segurança:**
   - `SANCTUM_STATEFUL_DOMAINS` - Domínios permitidos para autenticação
   - `SESSION_SECURE_COOKIE` - Cookies seguros (HTTPS)

5. **E-mail:**
   - `MAIL_REPLY_TO_ADDRESS` - E-mail de resposta
   - `MAIL_REPLY_TO_NAME` - Nome do remetente de resposta

## 📦 Variáveis do Coolify (automáticas)

O Coolify cria automaticamente estas variáveis, **NÃO precisa adicioná-las manualmente**:

```bash
SERVICE_FQDN_KRAYIN_PHP_APACHE=crm.cabana.deltaai.solutions
SERVICE_URL_KRAYIN_PHP_APACHE=https://crm.cabana.deltaai.solutions
```

Estas são usadas internamente pelo Coolify para roteamento e proxy reverso.

## 🎯 Diferenças importantes

### No Coolify vs Docker Compose local:

| Aspecto           | Coolify                             | Local                  |
| ----------------- | ----------------------------------- | ---------------------- |
| **Proxy reverso** | Coolify gerencia automaticamente    | Traefik/Nginx manual   |
| **SSL/HTTPS**     | Automático (Let's Encrypt)          | Configuração manual    |
| **Domínio**       | `SERVICE_FQDN_*` automático         | Configurar manualmente |
| **Redes**         | Coolify cria `proxy-public-network` | Criar manualmente      |

## ⚙️ Passos de deploy no Coolify

### 1. Criar o projeto no Coolify
- Adicione o repositório Git
- Escolha "Docker Compose" como tipo

### 2. Configurar variáveis de ambiente
- Copie todas as variáveis acima
- Cole na seção "Environment Variables"
- **IMPORTANTE:** Não adicione `SERVICE_FQDN_*` ou `SERVICE_URL_*` (Coolify cria automaticamente)

### 3. Configurar domínio
- Em "Domains", adicione: `crm.cabana.deltaai.solutions`
- Coolify vai gerar SSL automaticamente

### 4. Deploy
- Clique em "Deploy"
- Aguarde a build e inicialização dos containers

### 5. Verificar health checks
- MySQL deve estar "healthy" antes do PHP-Apache subir
- Isso já está configurado no `docker-compose.yml` com `depends_on`

## 🔐 Segurança no Coolify

### Boas práticas:

1. **Senhas fortes:**
   - `DB_PASSWORD` - Senha do banco
   - `MAIL_PASSWORD` - Senha do e-mail
   - `APP_KEY` - Gere com `php artisan key:generate`

2. **HTTPS obrigatório:**
   - `SESSION_SECURE_COOKIE=true` - Só permite cookies em HTTPS
   - Coolify gerencia SSL automaticamente

3. **Domínios permitidos:**
   - `SANCTUM_STATEFUL_DOMAINS` - Apenas domínios confiáveis
   - Use HTTPS no valor

## 🧪 Testar após deploy

### 1. Verificar se os containers subiram:
```bash
docker ps --filter "name=cabana"
```

### 2. Verificar logs:
```bash
docker logs -f krayin-php-apache-cabana
```

### 3. Testar conexão com banco:
```bash
docker exec -it krayin-mysql-cabana mysql -u krayin_user -p
```

### 4. Testar envio de e-mail:
- Acesse o CRM
- Tente enviar um e-mail de teste
- Verifique os logs se houver erro

## 🐛 Troubleshooting

### Problema: Container não sobe
**Solução:** Verifique se a variável `CLIENTE` está definida

### Problema: Erro de conexão com banco
**Solução:** 
- Verifique se `DB_HOST=krayin-mysql` (nome do serviço, não do container)
- Confirme que `DB_PASSWORD` está correto

### Problema: Redis não conecta
**Solução:** 
- Verifique se o container `krayin-redis-cabana` está rodando
- Confirme que `REDIS_HOST=krayin-redis` (nome do serviço)

### Problema: E-mail não envia
**Solução:**
- Verifique credenciais SMTP
- Teste porta 465 (SSL) ou 587 (TLS)
- Verifique logs: `docker logs krayin-php-apache-cabana`

## 📊 Recursos criados no Coolify

Com `CLIENTE=cabana`, o Coolify criará:

- **Containers:**
  - `krayin-php-apache-cabana`
  - `krayin-mysql-cabana`
  - `krayin-redis-cabana`
  - `krayin-phpmyadmin-cabana`
  - `krayin-mailhog-cabana` (opcional)

- **Volumes:**
  - `krayin-storage-cabana`
  - `.configs/mysql-data/` (persistência do banco)
  - `.configs/redis-data/` (persistência do Redis)

- **Redes:**
  - `krayin-network-cabana` (rede interna isolada)
  - `proxy-public-network` (rede pública do Coolify)

## 🎓 Próximos passos

1. ✅ Fazer backup regular do volume `krayin-storage-cabana`
2. ✅ Configurar backup automático do banco MySQL
3. ✅ Monitorar logs de erro
4. ✅ Testar recuperação de desastre
5. ✅ Documentar credenciais em local seguro (não no Git!)

---

**Dúvidas?** Verifique os logs dos containers e a documentação do Krayin CRM.
