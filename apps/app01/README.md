# Instructions
Please note that the [Transform secrets engine](https://www.vaultproject.io/docs/secrets/transform) is an Enterprise only feature. If you wish to use Transform in this demo, make sure you are using Vault Enterprise. The Vault Enterprise binary is available at releases.hashicorp.com/vault, and will be denoted by +ent in the name. It will run for 30 minutes without a license before shutting down.

Install flask, hvac, and mysql connector:
```
pip3 install -r requirements.txt
```

## Configuration

This application reads the following required configuration parameters from environment variables at startup:
* `VAULT_ADDR` - Vault cluster or server address
* `VAULT_DATABASE_CREDS_PATH` - Vault MySQL database dynamic credentials path
* `VAULT_NAMESPACE` - Vault namespace
* `VAULT_TRANSFORM_PATH` - Vault Transform engine path
* `VAULT_TRANSFORM_MASKING_PATH` - Vault Transform engine path for masking
* `VAULT_TRANSIT_PATH` - Vault Transit engine path
* `MYSQL_ADDR` - MySQL database address (omit port as it is currently hardcoded to 3306)

Optional:
* `VAULT_TOKEN` - Provide if Vault token auth is desired

This application currently supports two Vault authentication methods: [token](https://www.vaultproject.io/docs/auth/token) auth or [JWT](https://www.vaultproject.io/docs/auth/jwt) auth with an Azure identity token. If a `VAULT_TOKEN` is provided it will be used. Otherwise the app will try retrieving an access token from [Azure MSI](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) and logging into Vault using the JWT auth method. The JWT auth method must be configured at the default path of `jwt` with a role of `webapp-role`.

## Run

Run the application from the backend folder:
```
python3 app.py
```

Or run with Docker:
```
docker run --name transit-app-example \
  -p 5000:5000 \
  -e VAULT_ADDR=http://192.168.100.2:8200 \
  -e VAULT_DATABASE_CREDS_PATH=database/creds/transit-app-example \
  -e VAULT_NAMESPACE=development \
  -e VAULT_TOKEN=s.AvYZaHT7DAUyP6dDbj7S4ESu \
  -e VAULT_TRANSFORM_PATH=transform \
  -e VAULT_TRANSFORM_MASKING_PATH=masking/transform \
  -e VAULT_TRANSIT_PATH=transit \
  -e MYSQL_ADDR=192.168.100.2 \
  -d assareh/transit-app-example:latest
```

### Known Issues:
- Browser window must be greater than 1100 or so pixels wide due to a CSS issue
