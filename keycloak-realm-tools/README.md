# Keycloak Realm Import/Export Tools

## Prerequisites

- Docker Compose environment with Keycloak and MySQL
- `.env` file with database credentials in the parent directory

## Exporting a Realm

```sh
./export-realm.sh <realm-name> [export-dir] [users-strategy]
```

- `realm-name`: Name of the realm to export (required)
- `export-dir`: Directory to store exported files (default: `<realm-name>-export` in this folder)
- `users-strategy`: User export strategy (`different_files`, `skip`, `realm_file`, `same_file`; default: `realm_file`)

**Export without users (recommended for LDAP-backed realms):**
```sh
./export-realm.sh myrealm "" skip
```
> **Note:** Replace `myrealm` with your actual realm name (e.g., `ccom`).  
> If you want to skip users and use the default export directory, use `""` for the export-dir.

**Example:**
```sh
./export-realm.sh ccom "" skip
```

### Permissions Note

After running the export, if you see a "Permission denied" error, set the correct permissions on the export directory:

```sh
sudo chown -R 1000:1000 /home/shahadat/Keycloak-Docker/keycloak-realm-tools/ccom-export
sudo chmod -R 755 /home/shahadat/Keycloak-Docker/keycloak-realm-tools/ccom-export
```

- `1000:1000` is the default UID:GID for the Keycloak container user.  
- Adjust the path and UID/GID if your setup is different.

## Importing a Realm
jq 'del(.. | .id?)' my-new-ccom-realm.json > my-new-ccom-realm-noids.json
Reame the file or move to the new realm name
```sh
mv /home/shahadat/Keycloak-Docker/keycloak-realm-tools/ccom-export/ccom-realm.json \
   /home/shahadat/Keycloak-Docker/keycloak-realm-tools/ccom-export/my-new-ccom-realm.json
```
```sh
./import-realm.sh <import-dir> [override]
```

- `import-dir`: Directory containing exported realm files (required)
- `override`: `true` (default) to overwrite existing realms, `false` to skip

**Example:**
```sh
./import-realm.sh ./ccom-export true
```

## Notes

- The scripts will stop the Keycloak container before import/export and restart it after.
- Export/import is performed using a one-off container with DB credentials from `.env`.
- Exported files are stored in the specified directory on the host.

See