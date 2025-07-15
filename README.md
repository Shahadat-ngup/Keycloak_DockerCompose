# Keycloak + MySQL + Nginx Docker Production Deployment

## Quick Start
1. Copy `.env` and set strong passwords for MySQL and Keycloak.
2. Make sure your SSL certificates are in `/etc/letsencrypt/live/id.ipb.pt/` (or update the path in `docker-compose.yml` and `nginx.conf`).
3. Run:
   ```bash
   docker compose up -d
   ```
4. Access Keycloak:
   - Locally: http://localhost:8080
   - Via HTTPS: https://id.ipb.pt/ (or your domain)

## Folder Structure
- `nginx/nginx.conf` – Nginx reverse proxy config (handles HTTPS)
- `nginx/` – Place any additional Nginx files here
- `backup/` – Backup/restore instructions and scripts
- `.env` – Environment variables for MySQL and Keycloak
- `docker-compose.yml` – Main Docker Compose file

## Updating

**1. Backup your MySQL database before any update:**

```bash
mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > backup/keycloak_backup_$(date +%F).sql
```

**2. Update Keycloak or MySQL:**
- Edit `docker-compose.yml` and change the image tag for Keycloak or MySQL to the desired version (e.g., `quay.io/keycloak/keycloak:24.0.1` or `mysql:8.4`).
- Or, keep using `latest` for automatic latest, but using a specific version is safer for production.

**3. Pull and restart containers:**

```bash
docker compose pull
docker compose up -d
```

**4. Verify everything is working:**
- Check logs: `docker compose logs keycloak` and `docker compose logs mysql`
- Test your Keycloak login and database access.

**5. If something goes wrong, you can restore your backup:**

```bash
docker compose exec -T mysql mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < backup/keycloak_backup_YYYY-MM-DD.sql
```

## Important Docker Compose Commands

| Command                                 | Description                       |
|-----------------------------------------|-----------------------------------|
| `docker compose up -d`                  | Start all services in background  |
| `docker compose down`                   | Stop and remove all containers    |
| `docker compose ps`                     | List running containers           |
| `docker compose logs -f`                | Follow logs for all services      |
| `docker compose logs -f nginx`          | Follow logs for Nginx only        |
| `docker compose logs -f keycloak`       | Follow logs for Keycloak only     |
| `docker compose exec keycloak bash`     | Open shell in Keycloak container  |
| `docker compose exec mysql bash`        | Open shell in MySQL container     |
| `docker compose restart nginx`          | Restart Nginx container           |
| `docker compose pull`                   | Pull latest images                |
| `docker compose build`                  | Build images (if using Dockerfile)|

## Security
- Change all default passwords in `.env`.
- Use HTTPS in production (Nginx reverse proxy is already set up).
- Keep your certificates up to date (renew with Certbot or your CA).
- Regularly backup your database.

## Backup & Restore
See `backup/README.md` for detailed instructions.

---

**Congratulations! Your production-ready Keycloak + MySQL + Nginx stack is running with HTTPS.**
