![Architecture diagram](vault_dr.png)


```
  for dc in dc1 dc2; do
    echo "\033[32mRoot token for $dc: $(eval echo "\${${dc}_root_token}")\033[0m"
    echo "\033[32mUnseal key for $dc: $(eval echo "\${${dc}_unseal_key}")\033[0m\n"
  done
```