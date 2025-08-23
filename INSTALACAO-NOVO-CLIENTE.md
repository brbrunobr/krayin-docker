# Manual de Instalação: Krayin CRM para Novo Cliente

Este manual permite criar uma nova instância do Krayin CRM para um novo cliente em aproximadamente **10 minutos**.

## Pré-requisitos

- Servidor Coolify configurado e funcionando
- Repositório GitHub com Dockerfile e docker-compose.yml já otimizados
- Domínio do cliente configurado para apontar para o IP do servidor

## Parte 1: Configuração do Domínio (2 minutos)

Antes de começar, certifique-se de que o DNS do domínio do novo cliente (ex: `crm.novocliente.com`) está apontando para o IP do seu servidor Coolify.

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
- Insira o domínio do seu novo cliente (ex: `https://crm.novocliente.com`) no campo do serviço `krayin-php-apache`

#### Variáveis de Ambiente

Vá para a aba **"Environment Variables"** e adicione as seguintes variáveis:

| Chave (Name)            | Valor (Value)                                         |
| ----------------------- | ----------------------------------------------------- |
| `APP_NAME`              | `CRM Novo Cliente`                                    |
| `APP_ENV`               | `production`                                          |
| `APP_DEBUG`             | `false`                                               |
| `APP_URL`               | `https://crm.novocliente.com`                         |
| `APP_KEY`               | `base64:IZgK8L4yQ5g5g2bY7h3eR9k7lPqE4sWvF1uT0xZ3aBc=` |
| `DB_CONNECTION`         | `mysql`                                               |
| `DB_HOST`               | `krayin-mysql`                                        |
| `DB_PORT`               | `3306`                                                |
| `DB_DATABASE`           | `krayin`                                              |
| `DB_USERNAME`           | `root`                                                |
| `DB_PASSWORD`           | `senha-super-segura-trocar-depois`                    |
| `SESSION_SECURE_COOKIE` | `true`                                                |

> **⚠️ IMPORTANTE:**
>
> - O `DB_PASSWORD` deve ser único para cada cliente por segurança
> - A `APP_KEY` pode ser reutilizada ou você pode gerar uma nova
> - Altere `APP_NAME` e `APP_URL` para os valores específicos do cliente

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

echo "Instalação finalizada! O CRM está pronto."
```

## Credenciais de Acesso Padrão

- **URL de Login:** `https://crm.novocliente.com/admin/login`
- **Usuário:** `admin@example.com`
- **Senha:** `admin123`

> **🔒 SEGURANÇA:** Altere a senha do administrador imediatamente após o primeiro login!

## Copiando o Projeto para Múltiplos Clientes

### O que é Reutilizável?

- ✅ **Repositório GitHub** (Dockerfile, docker-compose.yml)
- ✅ **Configuração base** (mesmas extensões PHP, mesma estrutura)

### O que é Específico por Cliente?

- 🔄 **Domínio** (APP_URL)
- 🔄 **Nome da aplicação** (APP_NAME)
- 🔄 **Senha do banco de dados** (DB_PASSWORD)
- 🔄 **Instância do banco de dados** (totalmente isolada)

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

## Solução de Problemas

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
