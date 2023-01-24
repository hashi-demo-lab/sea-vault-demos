# Place provider configurations in this file.
# Leverage environment variables where possible
# If you are using them for auth then specify it with a comment in the provider block
# providers.tf shouldn't be present in module definitions. They should generally inherit the root module provider unless you need to do aliasing

provider "vault" {
  # using environment variables
}
