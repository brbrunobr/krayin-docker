# Manual de Instalação: Krayin CRM para Novo Cliente

Este manual permite criar uma nova instância do Krayin CRM para um novo cliente em aproximadamente **10 minutos**.

## Pré-requisitos

- Servidor Coolify configurado e funcionando
- Repositório GitHub com Dockerfile e docker-compose.yml já otimizados
- Domínio do cliente configurado para apontar para o IP do servidor

## Parte 1: Configuração do Domínio (2 minutos)

Antes de começar, certifique-se de que o DNS do domínio do novo cliente (ex: `crm.sorrisos.deltaai.solutions`) está apontando para o IP do seu servidor Coolify.

## Parte 2: Criação do Projeto no Coolify (5 minutos)

### Passo 2.1: Criar Novo Recurso

1. Acesse o painel do Coolify
2. Vá para seu projeto ou crie um novo projeto para organizar por cliente
3. Clique em **"Add Resource"** → **"Git Repository"**
4. Selecione o repositório GitHub que contém os arquivos Dockerfile e docker-compose.yml otimizados
5. Escolha o **"Build Pack"** como **"Docker Compose"**
6. Clique em **"Save"**

### Passo 2.2: Configurar Domínio e Variáveis de Ambiente

#### Configuração do Domínio

- Na aba **"General"**, na seção **"Domains"**
- Insira o domínio do seu novo cliente (ex: `https://crm.sorrisos.com`) no campo do serviço `krayin-php-apache`

#### Variáveis de Ambiente

Vá para a aba **"Environment Variables"** e adicione as seguintes variáveis:

**Exemplo para cliente "SORRISOS":**

| Chave (Name)            | Valor (Value) - EXEMPLO                               |
| ----------------------- | ----------------------------------------------------- |
| `USER`                  | `user_crm_sorrisos`                                   |
| `APP_NAME`              | `SORRISOS`                                            |
| `APP_ENV`               | `production`                                          |
| `APP_DEBUG`             | `false`                                               |
| `APP_URL`               | `https://crm.sorrisos.deltaai.solutions`              |
| `APP_KEY`               | `base64:FXySGW8l8R9UCfDvA1DDJcLoBTzeJSClZLypULBsaB8=` |
| `APP_CURRENCY`          | `BRL`                                                 |
| `DB_CONNECTION`         | `mysql`                                               |
| `DB_HOST`               | `krayin-mysql`                                        |
| `DB_PORT`               | `3306`                                                |
| `DB_DATABASE`           | `crm_sorrisos`                                        |
| `DB_USERNAME`           | `krayin_user`                                         |
| `DB_PASSWORD`           | `86ZNqzknm2te`                                        |
| `SESSION_SECURE_COOKIE` | `true`                                                |
| `REDE_INTERNA`          | `deltaai`                                             |

### 📋 Como Adaptar para Outros Clientes

Para cada novo cliente, personalize as seguintes variáveis:

| Variável       | Exemplo Cliente "ABC"               | Exemplo Cliente "XYZ"               |
| -------------- | ----------------------------------- | ----------------------------------- |
| `USER`         | `user_crm_abc`                      | `user_crm_xyz`                      |
| `APP_NAME`     | `ABC EMPRESA`                       | `XYZ CONSULTORIA`                   |
| `APP_URL`      | `https://crm.abc.deltaai.solutions` | `https://crm.xyz.deltaai.solutions` |
| `DB_DATABASE`  | `crm_abc`                           | `crm_xyz`                           |
| `DB_USERNAME`  | `abc_user`                          | `xyz_user`                          |
| `DB_PASSWORD`  | `senha_unica_abc123`                | `senha_unica_xyz456`                |
| `REDE_INTERNA` | `deltaai`                           | `deltaai`                           |

> **⚠️ IMPORTANTE:**
>
> - O `DB_PASSWORD` deve ser único para cada cliente por segurança
> - A `APP_KEY` pode ser reutilizada ou você pode gerar uma nova
> - Altere `USER`, `APP_NAME`, `APP_URL`, `DB_DATABASE`, `DB_USERNAME` e `DB_PASSWORD` para os valores específicos do cliente
> - `APP_CURRENCY` define a moeda padrão (BRL para Real brasileiro)
> - `REDE_INTERNA` deve ser a mesma para todos os clientes que compartilham o mesmo ambiente (ex: `deltaai`)
> - **ATUALIZAÇÃO:** O docker-compose.yml agora usa variáveis de ambiente, permitindo total personalização por cliente

7. Clique em **"Save"**

### Passo 2.3: Fazer o Deploy

1. Clique no botão **"Deploy"**
2. O Coolify irá construir a imagem e iniciar os contêineres
3. Aguarde a conclusão do processo (aproximadamente 3-5 minutos)

## Parte 3: Comandos Finais no Terminal (2 minutos)

Após o deploy ser concluído com sucesso:

1. Vá para a aba **"Terminal"** do contêiner `krayin-php-apache`
2. Execute os seguintes comandos:

```bash
# 1. Mude para o diretório da aplicação
cd /var/www/html

# 2. Crie as tabelas no banco de dados
php artisan migrate --force

# 3. Crie o arquivo que impede o redirecionamento para /install
touch storage/installed

# 4. O COMANDO MÁGICO: Cria o elo simbólico.
# Ele conectará 'public/storage' -> 'storage/app/public'
php artisan storage:link

echo "Instalação finalizada! O CRM está pronto."
```

## Credenciais de Acesso Padrão

- **URL de Login:** `https://crm.sorrisos.com/admin/login`
- **Usuário:** `admin@example.com`
- **Senha:** `admin123`

> **🔒 SEGURANÇA:** Altere a senha do administrador imediatamente após o primeiro login!

## Parte 4: Integração com n8n (Opcional)

Se você possui uma instância do n8n e deseja integrá-la com o Krayin CRM para automações, siga estas configurações:

### Configuração do n8n para Comunicação com Krayin

Para que o n8n possa se comunicar com o Krayin CRM, ambos precisam estar na mesma rede Docker.

#### Passo 4.1: Configurar Variáveis de Ambiente do n8n

No arquivo de configuração do seu n8n, adicione a variável `REDE_INTERNA`:

```env
# Suas outras configurações do n8n...
DB_POSTGRESDB_PASSWORD=$SERVICE_PASSWORD_POSTGRES
DB_POSTGRESDB_USER=$SERVICE_USER_POSTGRES
GENERIC_TIMEZONE=America/Sao_Paulo
# ... outras variáveis ...

# ⭐ NOVA VARIÁVEL PARA INTEGRAÇÃO COM KRAYIN
REDE_INTERNA=deltaai
```

#### Passo 4.2: Atualizar docker-compose.yml do n8n

Adicione a configuração de rede ao seu docker-compose.yml do n8n:

```yaml
services:
  n8n:
    # ... suas configurações existentes ...
    networks:
      - krayin-network

  postgresql:
    # ... suas configurações existentes ...
    networks:
      - krayin-network

# Adicione esta seção no final do arquivo
networks:
  krayin-network:
    external: true
    name: krayin-network-${CLIENTE}
```

#### Passo 4.3: Comunicação entre Serviços

Com essa configuração, o n8n poderá acessar os serviços do Krayin usando os nomes dos containers:

- **Krayin CRM:** `krayin-php-apache`
- **Banco MySQL:** `krayin-mysql`
- **Redis:** `krayin-redis`
- **phpMyAdmin:** `krayin-phpmyadmin`
- **MailHog:** `krayin-mailhog`

**Exemplo de webhook no n8n:**

```
http://krayin-php-apache/api/webhook
```

#### Benefícios da Integração

- 🔗 **Automações:** Criar workflows que respondem a eventos do CRM
- 📊 **Sincronização:** Integrar com outras ferramentas via n8n
- 🚀 **Escalabilidade:** Processar grandes volumes de dados
- 🔔 **Notificações:** Enviar alertas baseados em ações do CRM

## Copiando o Projeto para Múltiplos Clientes

### O que é Reutilizável?

- ✅ **Repositório GitHub** (Dockerfile, docker-compose.yml)
- ✅ **Configuração base** (mesmas extensões PHP, mesma estrutura)

### O que é Específico por Cliente?

- 🔄 **Usuário do sistema** (USER)
- 🔄 **Domínio** (APP_URL)
- 🔄 **Nome da aplicação** (APP_NAME)
- 🔄 **Nome do banco de dados** (DB_DATABASE)
- 🔄 **Usuário do banco de dados** (DB_USERNAME)
- 🔄 **Senha do banco de dados** (DB_PASSWORD)
- 🔄 **Moeda padrão** (APP_CURRENCY)
- 🔄 **Instância do banco de dados** (totalmente isolada)

> **� MELHORIA:** Agora todos os parâmetros são configuráveis via variáveis de ambiente!

### Fluxo de Trabalho para Múltiplos Clientes

1. **Reutilize o mesmo repositório GitHub** - não é necessário criar forks separados
2. **Crie um novo recurso no Coolify** seguindo este manual
3. **Altere apenas as variáveis específicas do cliente**
4. **Cada cliente terá uma instância completamente isolada**

### Benefícios desta Abordagem

- ⚡ **Rápido:** 10 minutos por nova instalação
- 🔒 **Seguro:** Cada cliente tem banco de dados isolado
- 📊 **Escalável:** Dezenas de clientes no mesmo servidor
- 🛠️ **Maintível:** Atualizações via repositório único
- 🎯 **Flexível:** Configuração totalmente personalizável via variáveis de ambiente

### ✨ Melhorias Implementadas

**Antes:** Valores fixos no docker-compose.yml limitavam a personalização
**Agora:** Todas as configurações são dinâmicas via variáveis de ambiente

- 🔧 **MySQL completamente configurável:** Banco, usuário e senha únicos por cliente
- 🔄 **phpMyAdmin automático:** Se conecta automaticamente com as credenciais do cliente
- 🚀 **Deploy mais robusto:** Healthcheck usa as variáveis corretas
- 📋 **Isolamento total:** Cada cliente tem configurações 100% independentes
- 🔗 **Integração com n8n:** Rede compartilhada para automações e workflows
- 🌐 **Comunicação entre serviços:** n8n pode acessar diretamente os containers do Krayin

## Solução de Problemas

### Erro de Conexão com Banco de Dados

**Problema:** `SQLSTATE[HY000] [1045] Access denied for user 'krayin_user'@'10.0.9.7' (using password: YES)`

**Causa:** Configuração incorreta das variáveis de ambiente do banco de dados.

**Solução:**

1. Verifique se `DB_USERNAME`, `DB_PASSWORD` e `DB_DATABASE` estão configurados corretamente
2. Certifique-se de que os valores são consistentes entre si
3. O docker-compose.yml agora usa essas variáveis para criar automaticamente:
   - O banco de dados especificado em `DB_DATABASE`
   - O usuário especificado em `DB_USERNAME` com a senha `DB_PASSWORD`
4. Reinicie o deploy após fazer as correções

### Se o Deploy Falhar

1. Verifique se todas as variáveis de ambiente foram configuradas
2. Confirme que o domínio está apontando corretamente
3. Verifique os logs na aba "Logs" do Coolify

### Se os Comandos Finais Falharem

1. Certifique-se de estar no contêiner correto (`krayin-php-apache`)
2. Verifique se o banco de dados está rodando
3. Execute `php artisan config:clear` antes dos comandos se necessário

---

**📞 Suporte:** Em caso de dúvidas ou problemas, consulte os logs do Coolify ou a documentação do Krayin CRM.
