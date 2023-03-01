#!/bin/zsh

# Unset out current status of the Environment Variables

unset LDAP_ORGANISATION
unset LDAP_DOMAIN
unset LDAP_ADMIN_PASSWORD

# Set envrionment variables

export VAULT_PORT=8200
export VAULT_TOKEN=root
export VAULT_ADDR=http://localhost:${VAULT_PORT}
export LDAP_ORGANISATION=engineers
export LDAP_DOMAIN=example.org
export LDAP_ADMIN_PASSWORD=admin

# Pull container images

docker pull osixia/openldap:latest
docker pull osixia/phpldapadmin:latest

# Start OpenLDAP

echo "\n\033[32m---STARTING OPENLDAP CONTAINER---\033[0m"
if docker inspect "ldap-service" &> /dev/null; then
  echo "\033[33mContainer ldap-service already exists, killing container and redeploying.\033[0m"
  docker rm -f ldap-service
  sleep 5
fi
docker run -d --rm  --name ldap-service --hostname ldap-service --network demo-network \
  -e "LDAP_ORGANISATION=$LDAP_ORGANISATION" \
  -e "LDAP_DOMAIN=$LDAP_DOMAIN" \
  -e "LDAP_ADMIN_PASSWORD=$LDAP_ADMIN_PASSWORD" \
  -p 389:389 \
  -p 636:636 \
  osixia/openldap:latest

# Start phpldapadmin

echo "\n\033[32m---STARTING PHPLDAPADMIN CONTAINER---\033[0m"
if docker inspect "phpldapadmin-service" &> /dev/null; then
  echo "\033[33mContainer phpldapadmin already exists, killing container and redeploying.\033[0m"
  docker rm -f phpldapadmin-service
  sleep 5
fi
docker run -d --rm --name phpldapadmin-service --hostname phpldapadmin-service --network demo-network \
    --link ldap-service:ldap-host \
    -e PHPLDAPADMIN_LDAP_HOSTS=ldap-host \
    -p 6443:443 \
    osixia/phpldapadmin:latest
sleep 5

# Create dev group with two members

ldapadd -cxD "cn=admin,dc=example,dc=org" -w admin <<EOF
dn: ou=groups,dc=example,dc=org
objectClass: organizationalunit
objectClass: top
ou: groups
description: groups of users

dn: ou=users,dc=example,dc=org
objectClass: organizationalunit
objectClass: top
ou: users
description: users

dn: cn=dev,ou=groups,dc=example,dc=org
objectClass: groupofnames
objectClass: top
description: testing group for dev
cn: dev
member: cn=alice,ou=users,dc=example,dc=org
member: cn=aaron,ou=users,dc=example,dc=org

dn: cn=manager,ou=groups,dc=example,dc=org
objectClass: groupofnames
objectClass: top
description: testing group for dev
cn: manager
member: cn=raymond,ou=users,dc=example,dc=org

dn: cn=alice,ou=users,dc=example,dc=org
objectClass: person
objectClass: top
cn: alice
sn: lee
memberOf: cn=dev,ou=groups,dc=example,dc=org
userPassword: password123

dn: cn=aaron,ou=users,dc=example,dc=org
objectClass: person
objectClass: top
cn: aaron
sn: villa
memberOf: cn=dev,ou=groups,dc=example,dc=org
userPassword: password123

dn: cn=raymond,ou=users,dc=example,dc=org
objectClass: person
objectClass: top
cn: raymond
sn: goh
memberOf: cn=manager,ou=groups,dc=example,dc=org
userPassword: password123

dn: cn=vault,ou=users,dc=example,dc=org
objectClass: person
objectClass: top
cn: vault
sn: vault
memberOf: cn=manager,ou=groups,dc=example,dc=org
userPassword: vault
EOF

# Setup LDAP Auth method and LDAP Secrets Engine

#terraform init
#terraform apply -auto-approve