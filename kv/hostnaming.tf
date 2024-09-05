# Create a KV secrets engine
resource "vault_mount" "hostnaming" {
  path        = "hostnaming"
  type        = "kv"
  options     = { version = "2" }
  description = "Key/Value mount for hostnaming demo"
}

# No need to initialize a global lock and counter. 
# The microservice will create these dynamically for each prefix.
