# MySQL/Keycloak Backup & Restore

## Backup MySQL
To back up the MySQL database:

```
docker compose exec mysql mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > backup/keycloak_backup.sql
```

## Restore MySQL
To restore:

```
docker compose exec -T mysql mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < backup/keycloak_backup.sql
```

## Notes
- Always test your backups!
- Automate backups for production.
