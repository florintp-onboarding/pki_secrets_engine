[![license](http://img.shields.io/badge/license-apache_2.0-red.svg?style=flat)](https://github.com/florintp-onboarding/pki_secrets_engine/LICENSE)

# Working with PKI Secrets Engine

The repository is used as an workout exercise on using PKI Secrets Engine follwing the [Learning HahiCorp](https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine)
The all-in-one script [working_with_pki_secrets_engine.sh](https://github.com/florintp-onboarding/pki_secrets_engine/working_with_pki_secrets_engine.sh) is written in Bash and was successfully tested on MAC (Intel and M1).


# Prerequisites
Install the latest version of vault and bash for your distribution.
As example for MAC, using brew:
```
brew install vault
brew install bash
brew install git
brew install gh
```

# Vault configuration used in this workout is using the [vault-as-docker]()
The following block actions are executed by the functions from the script:
 - Validating the environment and status of the Vault server.
 - Enable the PKI secrets engine type.
 - Execute the steps for creating certificate authority and intermediate request, signing the intermediate request, and create the leafs for learning.vaultadvanced.com atm01.vaultadvanced.com.
 - Clean-up the files and folders:
 ```plaintext
 ./intermediate.cert.pem
 ./ca_cert.crt
 ./atm01.vaultadvanced.com.pem
 ./learn.vaultadvanced.com.pem
 ./pki_intermediate.csr
```
 

# All the steps in opne script file
1. Clone the current repository or only the current script create_cluster.sh
```
git clone https://github.com/florintp-onboarding/pki_secrets_engine
```
or
```
gh repo clone florintp-onboarding/pki_secrets_engine/
```

2. Execute the steps from working_with_pki_secrets_engine.sh.
