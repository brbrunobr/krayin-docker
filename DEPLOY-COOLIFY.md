# 🚀 Deploy no Coolify - Comandos Necessários

## Criar Redes Docker (Execute ANTES do primeiro deploy)

Se você receber o erro `network krayin-network-cabana declared as external, but could not be found`, execute estes comandos no **terminal do servidor Coolify**:

```bash
# Criar a rede interna do Krayin
docker network create krayin-network-cabana

# Verificar se a rede do proxy já existe
docker network ls | grep proxy-public-network

# Se não existir, criar a rede do proxy
docker network create proxy-public-network
```

## Verificar Redes Existentes

```bash
# Listar todas as redes Docker
docker network ls

# Ver detalhes de uma rede específica
docker network inspect krayin-network-cabana
```

## Remover Redes (se necessário recriar)

```bash
# Parar todos os containers primeiro
docker compose down

# Remover a rede
docker network rm krayin-network-cabana

# Recriar
docker network create krayin-network-cabana
```

## Variáveis de Ambiente

Certifique-se de configurar no Coolify:

- `REDE_INTERNA` - Nome da instância (ex: cabana)
- `DB_DATABASE` - Nome do banco de dados
- `DB_USERNAME` - Usuário do MySQL
- `DB_PASSWORD` - Senha do MySQL
- `USER` - Usuário do sistema (opcional)

## Troubleshooting

### Container não inicia
```bash
# Ver logs do container
docker logs <container_id>

# Ver logs em tempo real
docker logs -f <container_id>
```

### Banco de dados não conecta
```bash
# Entrar no container do PHP
docker exec -it <container_id> bash

# Testar conexão com MySQL
php artisan tinker
# No tinker: DB::connection()->getPdo();
```
