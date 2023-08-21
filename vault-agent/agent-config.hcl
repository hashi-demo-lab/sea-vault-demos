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

#Demo Key-Value Secrets
template {
   source      = "/Users/aarone/Documents/sea-demos/vault-agent/kv-demo.tmpl"
   destination = "/Users/aarone/Documents/sea-demos/vault-agent/secrets/kv-demo.json"
}

#Demo Dynamic Database Credentials
template {
   source      = "/Users/aarone/Documents/sea-demos/vault-agent/dynamic-db-demo.tmpl"
   destination = "/Users/aarone/Documents/sea-demos/vault-agent/secrets/dynamic-db-demo.yaml"
}

#Demo PKI Certificates
template {
   source      = "/Users/aarone/Documents/sea-demos/vault-agent/pki-demo.tmpl"
   destination = "/Users/aarone/Documents/sea-demos/vault-agent/secrets/pki-demo-cert.pem"
}