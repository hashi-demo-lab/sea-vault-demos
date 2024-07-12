/*path "demo-pki-intermediate/issue/my_role" {
  capabilities = [ "create", "update" ]

  control_group = {
    factor "authorizer" {
      identity {
        group_names = [ "acct_manager" ]
        approvals = 1
      }
    }
  }
}*/

path "demo-pki-intermediate/issue/my_role" {
  capabilities = [ "create", "update" ]
}