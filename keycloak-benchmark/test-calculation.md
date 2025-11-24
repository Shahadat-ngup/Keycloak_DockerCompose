## ⚙️ Performance Calculations (8,000 Concurrent Users)

### System Resources
- **CPU**: 8 cores | **RAM**: 8GB | **Target**: 8,000 users

### Resource Allocation
| Service | CPU | RAM | Limit | Status |
|---------|-----|-----|-------|--------|
| Keycloak | 4 | 4.5GB | 8k users | ✅ Primary |
| MySQL | 2 | 2.5GB | 400 conn | ✅ Optimized |
| Nginx | 1.5 | 512MB | 16k conn | ✅ Tuned |
| PostgreSQL | 0.5 | 512MB | 50 conn | ✅ Light |
| **Total** | **8** | **8GB** | **8k users** | **✅ Balanced** |

---

## Nginx Configuration Calculations

### Worker Settings
```nginx
worker_processes  2;              # Frees 6 cores for Keycloak
worker_connections 8192;          # 2 × 8192 = 16,384 total
worker_rlimit_nofile 65535;       # Matches Docker ulimit
```

**Formula**:
```
Connections needed = 8,000 users × 2 (client→nginx, nginx→keycloak) = 16,000
Worker capacity = 2 workers × 8,192 = 16,384 ✅
File descriptors = 16,384 × 2 = 32,768 (< 65,535 limit) ✅
```

### Keepalive Pool
```nginx
keepalive 128;  # 2 workers × 64 connections
```

---

## Required Configuration Changes

### 1. Update `nginx/nginx.conf`
```nginx
worker_processes  2;  # Change from 'auto'
worker_rlimit_nofile 65535;

events {
    worker_connections 8192;
}

http {
    upstream keycloak_backend {
        server keycloak:8080;
        keepalive 128;  # Reduced from 256
    }
}
```

### 2. Update `docker-compose.yml`

**Keycloak** (reduce heap to fit 8GB):
```yaml
keycloak:
  environment:
    JAVA_OPTS_APPEND: >-
      -Xms2g -Xmx3500m
      -XX:+UseG1GC
  deploy:
    resources:
      limits:
        memory: 4.5G  # Reduced from 5G
```

**MySQL** (optimize connections):
```yaml
mysql:
  command: >
    --max-connections=400
    --innodb-buffer-pool-size=1536M
  deploy:
    resources:
      limits:
        memory: 2.5G  # Reduced from 3G
```

**Nginx** (keep ulimit):
```yaml
nginx:
  ulimits:
    nofile:
      soft: 65535
      hard: 65535
```

---

## Capacity Verification

| Metric | Configured | At 8k Users | Headroom |
|--------|-----------|-------------|----------|
| Nginx connections | 16,384 | 16,000 | 2% |
| File descriptors | 65,535 | 32,000 | 51% |
| Keycloak RAM | 4.5GB | ~4GB | 11% |
| MySQL connections | 400 | ~350 | 13% |
| Total RAM | 8GB | ~7.5GB | 6% |

---

## Validation Commands

```bash
# Check ulimit
docker compose exec nginx sh -c "ulimit -n"
# Expected: 65535

# Verify worker processes (after restart)
docker compose exec nginx sh -c "grep worker_processes /etc/nginx/nginx.conf"
# Expected: worker_processes  2;

# Monitor RAM usage
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}"
# Keycloak < 4.5GB, MySQL < 2.5GB

# Response time test
time curl -I -k https://id.ipb.pt
# Expected: < 200ms
```

---

## Performance Expectations

```
Response Time (p95):     < 300ms
CPU (Keycloak):         80-95%
CPU (MySQL):            60-70%
RAM Usage (Total):      7.0-7.5GB
Error Rate:             < 0.1%
```

---

## Scaling Beyond 8,000 Users

**For 12,000+ users**, you need:
- Add 4GB RAM (8GB → 12GB)
- Increase Keycloak heap to 6GB
- Consider Keycloak clustering

**For 20,000+ users**:
- Keycloak cluster (2-3 instances)
- External load balancer
- MySQL read replicas