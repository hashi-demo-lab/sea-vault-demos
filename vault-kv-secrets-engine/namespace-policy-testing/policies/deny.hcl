# Deny policy for specific secret engines
path "sys/mounts/transit" {
  capabilities = ["deny"]
}

# Deny other specific secret engines as needed
# Example for another secret engine:
# path "sys/mounts/another_engine" {
#   capabilities = ["deny"]
# }
