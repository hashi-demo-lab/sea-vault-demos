ldapadd -cxD "cn=admin,dc=hashibank,dc=com" -w admin <<EOF
dn: ou=groups,dc=hashibank,dc=com
objectClass: organizationalunit
objectClass: top
ou: groups
description: groups of users

dn: ou=users,dc=hashibank,dc=com
objectClass: organizationalunit
objectClass: top
ou: users
description: users

dn: cn=dev,ou=groups,dc=hashibank,dc=com
objectClass: groupofnames
objectClass: top
description: testing group for dev
cn: dev
member: cn=alice,ou=users,dc=hashibank,dc=com
member: cn=aaron,ou=users,dc=hashibank,dc=com

dn: cn=manager,ou=groups,dc=hashibank,dc=com
objectClass: groupofnames
objectClass: top
description: testing group for dev
cn: manager
member: cn=raymond,ou=users,dc=hashibank,dc=com

dn: cn=alice,ou=users,dc=hashibank,dc=com
objectClass: person
objectClass: top
cn: alice
sn: lee
memberOf: cn=dev,ou=groups,dc=hashibank,dc=com
userPassword: password123

dn: cn=aaron,ou=users,dc=hashibank,dc=com
objectClass: person
objectClass: top
cn: aaron
sn: villa
memberOf: cn=dev,ou=groups,dc=hashibank,dc=com
userPassword: password123

dn: cn=raymond,ou=users,dc=hashibank,dc=com
objectClass: person
objectClass: top
cn: raymond
sn: goh
memberOf: cn=manager,ou=groups,dc=hashibank,dc=com
userPassword: password123

dn: cn=vault,ou=users,dc=hashibank,dc=com
objectClass: person
objectClass: top
cn: vault
sn: vault
memberOf: cn=manager,ou=groups,dc=hashibank,dc=com
userPassword: vault
EOF