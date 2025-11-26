# Keycloak + MySQL + Nginx Docker Production Deployment

This repository contains a production-ready Keycloak deployment with MySQL database, Nginx reverse proxy, and PostgreSQL for external services. **Optimized for 10,000 concurrent users** with 8 CPU cores.

---

## 🚀 Features

- **Keycloak 26.3.4** with custom themes and providers
- **MySQL 9.3.0** as primary identity database (optimized with 500 connections, 2GB buffer pool)
- **PostgreSQL 17.6** for external service integrations
- **Nginx 1.29.0** reverse proxy with SSL/TLS (HTTP/2 enabled)
- **Performance tuning**: JVM heap (4GB), connection pooling (256 keepalive), resource limits
- Let's Encrypt SSL certificates
- Docker Compose orchestration

---

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose v2.40+
- 8 CPU cores (minimum 4)
- 8GB RAM (minimum)
- Domain with DNS pointing to server
- Let's Encrypt SSL certificates at `/etc/letsencrypt/live/id.ipb.pt/`

---

## 🎯 Performance Specifications

### Resource Allocation
- **Keycloak**: 4 CPU cores, 5GB RAM, 2-4GB JVM heap
- **MySQL**: 2 CPU cores, 3GB RAM, 2GB InnoDB buffer pool
- **Nginx**: Connection pooling (256 keepalive), 65535 file descriptors
- **Target Capacity**: 10,000 concurrent users

### Optimizations Applied
- ✅ HTTP/2 enabled
- ✅ Nginx upstream connection pooling
- ✅ MySQL connection pool (500 max)
- ✅ Keycloak DB pool (100 max)
- ✅ G1 garbage collector
- ✅ Resource limits enforced via Docker

---

## 📁 Project Structure

```
Keycloak-Docker/
├── docker-compose.yml          # Main orchestration (optimized)
├── .env                        # Environment variables (credentials)
├── nginx/
│   └── nginx.conf             # Nginx config (HTTP/2, keepalive, rate limiting)
├── keycloak/
│   ├── themes/                # Custom Keycloak themes
│   └── providers/             # Custom SPI providers
├── keycloak-realm-tools/
│   └── clone_realm.py         # Realm cloning utility
├── backup/
│   ├── backup.sh              # Automated backup script
│   └── restore.sh             # Restore script
└── README.md
```

---

## 🔧 Quick Start: Installation & Replication

### 1. Clone Repository
```bash
git clone <repository-url>
cd Keycloak-Docker
```

### 2. Configure Environment Variables
```bash
cp .env.example .env
nano .env
```

**Required variables:**
```bash
# MySQL
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=keycloak
MYSQL_USER=keycloak
MYSQL_PASSWORD=secure_password

# PostgreSQL (for external services)
PG_DATABASE=autenticacao_ipb
PG_USER=keycloak_plugin
PG_PASSWORD=secure_pg_password

# Keycloak Admin
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=secure_admin_password
```

### 3. SSL Certificates Setup
Ensure Let's Encrypt certificates exist:
```bash
ls -la /etc/letsencrypt/live/id.ipb.pt/
# Should show: fullchain.pem, privkey.pem
```

### 4. Deploy Services
```bash
# Start all services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f keycloak
```

### 5. Access Keycloak
- **Public URL**: `https://id.ipb.pt`
- **Admin Console**: `https://id.ipb.pt/admin/master/console/`
- **Credentials**: Use `KEYCLOAK_ADMIN` from `.env`

---

## ✅ Verification Commands

### System Health Check
```bash
# 1. Check all services running
docker compose ps

# 2. Verify resource limits
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
# Expected: Keycloak < 5GB, MySQL < 3GB

# 3. Check HTTP/2 enabled
curl -I -k https://id.ipb.pt 2>&1 | grep HTTP
# Expected: HTTP/2 302

# 4. Verify Nginx ulimit
docker compose exec nginx sh -c "ulimit -n"
# Expected: 65535

# 5. Confirm JVM settings
docker inspect keycloak-docker-keycloak-1 --format='{{range .Config.Env}}{{println .}}{{end}}' | grep JAVA_OPTS
# Expected: -Xms2g -Xmx4g -XX:+UseG1GC

# 6. Response time test
time curl -I -k https://id.ipb.pt
# Expected: < 200ms

# 7. System resources
free -h
nproc
# Expected: 8 CPU cores, 5GB+ available RAM
```

### Connection Pooling Test
```bash
# Generate sustained traffic
timeout 30s bash -c 'while true; do curl -s -o /dev/null https://id.ipb.pt/realms/ccom/protocol/openid-connect/certs & sleep 0.1; done' &

# Check keepalive connections (during traffic)
sleep 5
docker compose exec nginx netstat -an | grep :8080 | grep ESTABLISHED
# Expected: Multiple persistent connections
```

### Database Connectivity
```bash
# MySQL
docker compose exec mysql mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW VARIABLES LIKE 'max_connections';"
# Expected: 500

# PostgreSQL
docker compose exec postgres psql -U ${PG_USER} -d ${PG_DATABASE} -c "\dt"
# Expected: List of tables including 'users'
```

---

## 🔒 PostgreSQL External Service Setup

### Table Schema
```sql
CREATE TABLE users (
  bduid         TEXT PRIMARY KEY,
  bi            BYTEA NOT NULL,
  tipo          TEXT NOT NULL,
  nif           BYTEA NOT NULL,
  country_code  TEXT NOT NULL
);
```

### Access MysqlSQL
```bash
# Enter container
docker exec -it keycloak-docker-mysql-1 sh
# Enter prompted pass
mysql -u root -p
#Create database if needed
CREATE DATABASE keycloak_v1_qa;
CREATE USER 'keycloak_qa'@'%' IDENTIFIED BY 'Dewan41724%';
GRANT ALL PRIVILEGES ON keycloak_v1_qa.* TO 'keycloak_qa'@'%';
FLUSH PRIVILEGES;
#show database
show databases;

```

---


### Access PostgreSQL
```bash
# From host machine
psql "host=193.136.195.218 port=5432 dbname=autenticacao_ipb user=keycloak_plugin password=<password>"

# From container
docker compose exec postgres psql -U keycloak_plugin -d autenticacao_ipb
```

---

## 🛠️ Maintenance

### Backup
```bash
cd backup/
./backup.sh
# Creates timestamped backup in backup/backups/
```

### Restore
```bash
cd backup/
./restore.sh backups/backup_YYYYMMDD_HHMMSS.sql
```

### Update Keycloak
```bash
# Edit docker-compose.yml, change image tag
nano docker-compose.yml

# Restart
docker compose down
docker compose up -d
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f keycloak
docker compose logs -f nginx
docker compose logs -f mysql
```

### Restart Services
```bash
# Restart all
docker compose restart

# Restart specific service
docker compose restart keycloak
docker compose restart nginx
```

---

## 📊 Performance Tuning

### Current Configuration

**Keycloak JVM:**
```yaml
JAVA_OPTS_APPEND: >-
  -Xms2g -Xmx4g
  -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m
  -XX:+UseG1GC
  -XX:MaxGCPauseMillis=100
```

**MySQL:**
```yaml
command: >
  --max-connections=500
  --innodb-buffer-pool-size=2G
```

**Nginx:**
```nginx
worker_connections 10000;
keepalive 256;
http2 on;


```
### Nginx For our clone and main has also be done like this.
sudo cp /etc/letsencrypt/live/id-qa.ipb.pt/fullchain.pem /etc/letsencrypt/live/id-qa.ipb.pt/id-qa.ipb.pt.pem
sudo cp /etc/letsencrypt/live/id-qa.ipb.pt/privkey.pem /etc/letsencrypt/live/id-qa.ipb.pt/id-qa.ipb.pt.key
sudo chmod 644 /etc/letsencrypt/live/id-qa.ipb.pt/id-qa.ipb.pt.pem
sudo chmod 600 /etc/letsencrypt/live/id-qa.ipb.pt/id-qa.ipb.pt.key
# and then change in nginx.conf
ssl_certificate /etc/letsencrypt/live/id-qa.ipb.pt/id-qa.ipb.pt.pem;
ssl_certificate_key /etc/letsencrypt/live/id-qa.ipb.pt/id-qa.ipb.pt.key;

# down and up


### Scaling Beyond 10k Users

For **20k+ concurrent users**, consider:

1. **Enable Keycloak Clustering** (2-3 instances)
2. **Redis for distributed caching**
3. **MySQL read replicas**
4. **Increase CPU to 16 cores**
5. **Upgrade RAM to 16GB+**
6. **Use external load balancer** (HAProxy/AWS ALB)

---

## 🐛 Troubleshooting

### Issue: Keycloak not starting
```bash
# Check logs
docker compose logs keycloak

# Common causes:
# - MySQL not ready (wait 30s)
# - Wrong DB credentials in .env
# - Port 8080 already in use
```

### Issue: SSL certificate errors
```bash
# Verify certificates exist
ls -la /etc/letsencrypt/live/id.ipb.pt/

# Renew Let's Encrypt
certbot renew
docker compose restart nginx
```

### Issue: High memory usage
```bash
# Check current usage
docker stats

# Reduce Keycloak heap if needed
# Edit docker-compose.yml: -Xmx3g instead of -Xmx4g
```

### Issue: Slow response times
```bash
# Check connection pooling
docker compose exec nginx netstat -an | grep :8080 | wc -l

# Check MySQL queries
docker compose exec mysql mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW PROCESSLIST;"

# Restart services
docker compose restart
```

---

## 🔐 Security Notes

- Change all default passwords in `.env`
- Keep SSL certificates up to date
- Regularly update Docker images
- Monitor logs for suspicious activity
- Restrict database ports (3306, 5432) to internal network only
- Use secrets management in production (e.g., Docker Secrets, Vault)

---

## 📚 Additional Resources

- [Keycloak Official Documentation](https://www.keycloak.org/documentation)
- [Keycloak Performance Tuning](https://www.keycloak.org/server/configuration-production)
- [Nginx HTTP/2 Guide](https://nginx.org/en/docs/http/ngx_http_v2_module.html)
- [MySQL Optimization](https://dev.mysql.com/doc/refman/9.0/en/optimization.html)

---

