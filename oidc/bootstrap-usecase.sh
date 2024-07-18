#!/bin/zsh

# Enabling the OIDC auth method
vault auth enable oidc

# Writing the OIDC config
vault write auth/oidc/config \
    oidc_discovery_url="${VAULT_OIDC_DISCOVERY_URL}" \
    oidc_client_id="${VAULT_OIDC_CLIENT_ID}" \
    oidc_client_secret="${VAULT_OIDC_CLIENT_SECRET}" \
    default_role="${VAULT_DEFAULT_ROLE}"

# Writing the OIDC role
vault write auth/oidc/role/demo \
    bound_audiences="${VAULT_BOUND_AUDIENCES}" \
    allowed_redirect_uris="${VAULT_ALLOWED_REDIRECT_URIS}" \
    user_claim="${VAULT_USER_CLAIM}" \
    token_policies="${VAULT_TOKEN_POLICIES}"
