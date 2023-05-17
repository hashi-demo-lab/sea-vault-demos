provider "vault" {
  address = var.vault_address
}

/*resource "vault_database_secrets_mount" "databases" {
  path        = "demo-databases"
  description = "This is an example database secret engine mount"
  mysql {
    name           = var.mysql_database_name
    username       = var.mysql_username
    password       = var.mysql_password
    connection_url = "{{username}}:{{password}}@tcp(mysql:3306)/"
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
  rotation_period = 120
}

resource "vault_database_secret_backend_role" "db-user-readonly" {
  backend             = vault_database_secrets_mount.databases.path
  name                = "db-user-readonly"
  db_name             = vault_database_secrets_mount.databases.mysql[0].name
  default_ttl         = 600
  max_ttl             = 900
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON my_app.* TO '{{name}}'@'%';"]
}

resource "vault_database_secret_backend_role" "db-user-readwrite" {
  backend             = vault_database_secrets_mount.databases.path
  name                = "db-user-readwrite"
  db_name             = vault_database_secrets_mount.databases.mysql[0].name
  default_ttl         = 3600
  max_ttl             = 7200
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON *.* TO '{{name}}'@'%';"]
}

resource "vault_mount" "transit" {
  path                      = "demo-transit"
  type                      = "transit"
  description               = "This is an example transit secret engine mount"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_backend_key" "key" {
  backend          = vault_mount.transit.path
  name             = "customer-key"
  deletion_allowed = true
}

resource "vault_mount" "transform" {
  path        = "demo-transform"
  type        = "transform"
  description = "This is an example transform secret engine mount"
}

resource "vault_transform_role" "transform_role" {
  path            = vault_mount.transform.path
  name            = "ssn"
  transformations = ["ssn-fpe"]
}

resource "vault_transform_transformation" "example" {
  path             = vault_mount.transform.path
  name             = "ssn-fpe"
  type             = "fpe"
  template         = "builtin/socialsecuritynumber"
  tweak_source     = "internal"
  allowed_roles    = ["ssn"]
  deletion_allowed = true
}*/