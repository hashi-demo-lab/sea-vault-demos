path "demo-pki*"                { capabilities = ["read", "list"] }
path "demo-pki/sign/my_role"    { capabilities = ["create", "update"] }
path "demo-pki/issue/my_role"   { capabilities = ["create"] }