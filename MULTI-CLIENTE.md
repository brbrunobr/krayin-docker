# 🚀 Como configurar múltiplos clientes

Este setup permite rodar **múltiplas instâncias** do Krayin CRM no mesmo servidor, cada uma com recursos isolados e únicos.

## 📋 Como funciona

Todos os recursos (containers, volumes, imagens) usam a variável `${CLIENTE}` como sufixo, garantindo que:
- ✅ Cada cliente tem seu próprio banco de dados isolado
- ✅ Volumes de armazenamento separados
- ✅ Containers com nomes únicos (sem conflito)
- ✅ Redes isoladas por cliente

## 🛠️ Setup para um novo cliente

### 1. Copie o arquivo de exemplo
```powershell
Copy-Item .env.exemplo .env
```

### 2. Edite o `.env` e configure:
```env
# Nome único do cliente (sem espaços, use hífen ou underscore)
CLIENTE=cliente-abc

# Outras configurações...
DB_PASSWORD=SenhaSuperSegura123
MAIL_HOST=mail.cliente.com.br
# ... etc
```

### 3. Suba os containers
```powershell
docker-compose up -d
```

## 📦 Exemplo com 3 clientes diferentes

### Cliente 1: "cabana-eco"
```env
CLIENTE=cabana-eco
REDE_INTERNA=1
DB_DATABASE=krayin_cabana
DB_PASSWORD=Senha123!
```
Containers criados:
- `krayin-php-apache-cabana-eco`
- `krayin-mysql-cabana-eco`
- `krayin-redis-cabana-eco`
- `krayin-phpmyadmin-cabana-eco`
- `krayin-mailhog-cabana-eco`

### Cliente 2: "hotel-praia"
```env
CLIENTE=hotel-praia
REDE_INTERNA=2
DB_DATABASE=krayin_hotel
DB_PASSWORD=OutraSenha456!
```
Containers criados:
- `krayin-php-apache-hotel-praia`
- `krayin-mysql-hotel-praia`
- ... etc

### Cliente 3: "resort-montanha"
```env
CLIENTE=resort-montanha
REDE_INTERNA=3
DB_DATABASE=krayin_resort
DB_PASSWORD=MaisSenha789!
```
Containers criados:
- `krayin-php-apache-resort-montanha`
- `krayin-mysql-resort-montanha`
- ... etc

## 🔍 Comandos úteis

### Ver containers de um cliente específico
```powershell
docker ps --filter "name=cabana-eco"
```

### Parar/Iniciar uma instância específica
```powershell
# Parar
docker-compose --env-file .env.cabana-eco down

# Iniciar
docker-compose --env-file .env.cabana-eco up -d
```

### Ver logs de um cliente
```powershell
docker logs -f krayin-php-apache-cabana-eco
```

### Acessar bash do container
```powershell
docker exec -it krayin-php-apache-cabana-eco bash
```

## 📂 Estrutura de arquivos recomendada

```
krayin-docker/
├── docker-compose.yml          # Arquivo base (único)
├── .env.exemplo                # Template
├── .env.cabana-eco            # Config cliente 1
├── .env.hotel-praia           # Config cliente 2
├── .env.resort-montanha       # Config cliente 3
└── .configs/
    ├── mysql-data-cabana-eco/     # Dados do MySQL cliente 1
    ├── mysql-data-hotel-praia/    # Dados do MySQL cliente 2
    ├── mysql-data-resort-montanha/ # Dados do MySQL cliente 3
    ├── redis-data-cabana-eco/
    ├── redis-data-hotel-praia/
    └── redis-data-resort-montanha/
```

## ⚠️ IMPORTANTE

1. **Sempre use `.env` diferente por cliente** ou especifique com `--env-file`
2. **Não versione arquivos `.env` no Git** (adicione ao `.gitignore`)
3. **Use senhas diferentes** para cada cliente
4. **Ajuste `REDE_INTERNA`** para cada cliente (números únicos)
5. **Backup dos volumes** regularmente

## 🔐 Segurança

- Nunca commite arquivos `.env` com senhas reais
- Use senhas fortes e únicas por cliente
- Configure firewall para isolar as redes
- Considere usar Docker Secrets em produção

## 🎯 Benefícios desta abordagem

✅ Isolamento total entre clientes  
✅ Fácil de gerenciar múltiplas instâncias  
✅ Backups independentes por cliente  
✅ Não há risco de conflito de nomes  
✅ Escalável (adicione quantos clientes quiser)  
