resource "vault_database_secrets_mount" "databases" {
  path = "demo-databases"

  mysql {
    name           = var.mysql_database_name
    username       = var.mysql_username
    password       = var.mysql_password
    connection_url = "{{username}}:{{password}}@tcp(host.docker.internal:3306)/"
    allowed_roles = [
      "db-user-static",
      "db-user-readonly",
      "db-user-readwrite"
    ]
  }
}

resource "vault_database_secret_backend_static_role" "static_role" {
  backend         = vault_database_secrets_mount.databases.path
  name            = "db-user-static"
  db_name         = vault_database_secrets_mount.databases.mysql[0].name
  username        = var.mysql_application_username
  rotation_period = 60
}

resource "vault_database_secret_backend_role" "db-user-readonly" {
  backend             = vault_database_secrets_mount.databases.path
  name                = "db-user-readonly"
  db_name             = vault_database_secrets_mount.databases.mysql[0].name
  default_ttl         = 60
  max_ttl             = 300
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON my_app.* TO '{{name}}'@'%';"]
}