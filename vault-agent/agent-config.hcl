pid_file = "./pidfile"

vault {
   address = "http://localhost:32000"
   tls_skip_verify = true
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
