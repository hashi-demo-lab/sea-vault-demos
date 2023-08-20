path "demo-pki-*"                            { capabilities = ["read", "list"] }
path "demo-pki-intermediate/sign/my_role"    { capabilities = ["create", "update"] }
path "demo-pki-intermediate/issue/my_role"   { capabilities = ["create"] }
path "demo-pki-root/sign/my_role"            { capabilities = ["create", "update"] }
path "demo-pki-root/issue/my_role"           { capabilities = ["create"] }