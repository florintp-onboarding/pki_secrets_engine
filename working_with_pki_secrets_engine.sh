#!/bin/bash
vault status
[ $? -gt 0 ] && echo "Vault is not in the correct state!" && exit 1 

vault secrets list
vault secrets disable pki 2>/dev/null
vault secrets disable pki_int 2>/dev/null

echo "### Enable PKI"
vault secrets enable -description="PKI CA" pki
vault secrets tune -max-lease-ttl=87600h pki
 
echo "### Create CA into PKI"
vault write -field=certificate pki/root/generate/internal \
	 common_name="vaultadvanced.com" \
	 ttl=87600h >ca_cert.crt

echo "### Configure URLs into PKI"
vault write pki/config/urls \
	 issueing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
	 crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"

echo "### Enable PKI_INT"
vault secrets enable -description="PKI Intermediate secrets engine" -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int


vault secrets list
read x
echo "### Creating Certificate Request for intermediate PKI_INT"
vault write -format=json pki_int/intermediate/generate/internal \
	 common_name="vaultadvanced.com Intermediate Authority" | jq -r '.data.csr' >pki_intermediate.csr
[ -f pki_intermediate ] && ls -ltr pki_intermediate.csr
read x

echo "### Sign the Certificate Request from PKI_INT by the CA from PKI"
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr format=pem_bundle ttl="43800h" |jq -r '.data.certificate' > intermediate.cert.pem
[ -s intermediate.cert.pem ] && ls -haic  intermediate.cert.pem 
[ $? -eq 0 ] && vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
read x

echo "### Set Signed Certificate Request into PKI_INT"
[ -f intermediate.cert.pem ] && vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
echo "### Creating the role domains and subdomains for Intermediate Certificate into PKI_INT"
vault write pki_int/roles/vaultadvanced \
	allowed_domains="vaultadvanced.com" \
	allow_subdomains=true max_ttl="720h"
read x

vault list pki_int/roles
echo "(optional) vault read pki_int/roles/vaultadvanced"
read x

vault write -format=json pki_int/issue/vaultadvanced common_name="learn.vaultadvanced.com" ttl="24h" >learn.vaultadvanced.com.pem
[ -f learn.vaultadvanced.com.pem ] && ls -ltr learn.vaultadvanced.com.pem
vault write -format=json pki_int/issue/vaultadvanced common_name="atm01.vaultadvanced.com" ttl="4h" >atm01.vaultadvanced.com.pem
[ -f atm01.vaultadvanced.com.pem ] && ls -ltr atm01.vaultadvanced.com.pem

ls -ltr

echo "
### Select the PRIVATE KEY for learning.vaultadvanced.com
cat atm01.vaultadvanced.com.pem|jq -r '.data.private_key'

### Select the PRIVATE KEY for atm01.vaultadvanced.com
cat learn.vaultadvanced.com.pem|jq -r '.data.private_key'
###
"

echo "### Cleanup (if needed)"
echo -ne "\n\nrm -f atm01.vaultadvanced.com.pem \\ \n learn.vaultadvanced.com.pem \\ \n intermediate.cert.pem \\ \n pki_intermediate.csr \\ \n ca_cert.crt\n"
