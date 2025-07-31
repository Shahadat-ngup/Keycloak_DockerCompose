# MySQL/Keycloak Backup & Restore

## Backup MySQL
To back up the MySQL database:

1. (One-time setup, already done):
   - Grant the PROCESS privilege to the Keycloak user:
     ```sql
     sudo docker compose exec mysql mysql -uroot -p
     GRANT PROCESS ON *.* TO 'keycloak'@'%';
     FLUSH PRIVILEGES;
     EXIT;
     ```

2. Run the backup command (replace with your actual values):
   ```bash
   sudo docker compose exec mysql mysqldump -ukeycloak -p'YOUR_PASSWORD' keycloak_v1 > backup/keycloak_backup.sql
   ```
   - You can also use environment variables if you export them in your shell.
   - After running, check your backup file with:
     ```bash
     head backup/keycloak_backup.sql
     ```
     You should see SQL statements like `CREATE TABLE` and `INSERT INTO`.

3. **Automate with Cron (Recommended for Production):**
   - Add this line to your crontab (`crontab -e`) to run the backup every day at 2:00 AM:
     ```cron
     0 2 * * * /home/shahadat/Desktop/Keycloak-Docker/backup/backup-keycloak-db.sh >> /home/shahadat/Desktop/Keycloak-Docker/backup/backup-cron.log 2>&1
     ```
   - This will create a timestamped backup file in `/home/shahadat/Desktop/Keycloak-Docker/backup/` and log output/errors to `backup-cron.log`.
   - Make sure your script is executable:
     ```bash
     chmod +x /home/shahadat/Desktop/Keycloak-Docker/backup/backup-keycloak-db.sh
     ```

## Restore MySQL
To restore from a backup:

```bash
sudo docker compose exec -T mysql mysql -ukeycloak -p'YOUR_PASSWORD' keycloak_v1 < backup/keycloak_backup.sql
```

## Notes
- Always test your backups by restoring to a test database.
- Automate backups for production (e.g., with a cron job as above).
- Store backup files securely and do not commit them to git.
- Check `backup-cron.log` for errors if backups do not appear as expected.
