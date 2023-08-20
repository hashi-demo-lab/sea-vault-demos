pid_file = "./pidfile"

vault {
   address = "https://vault-dc1.hashibank.com:443"
   tls_skip_verify = false
}

auto_auth {
   method {
      type = "token_file"
      config = {
         token_file_path = "/Users/aarone/.vault-token"
      }
   }
   sink "file" {
      config = {
            path = "/Users/aarone/vault-token-via-agent"
      }
   }
}
