## Install Dependencies
To install OpenSSL 
```
.\dependencies\install_open_ssl.ps1
```

Next you want to generate a SHA256 password. You can generate one online or use `htpasswd` and running the following command.

```bash
htpasswd -nbBC 10 addi_user p@ssw0rd
addi_user:$2y$10$vAk2SLjHIU2x2dNuzwDxDuq6TwdnLK1XeO8OCzxNqXK3yv3ObYfIy
````

Next, update the `tls/.env` file. Update each variable that has `<>` for the following `Username`, `AddiIP`, `RefactorIP`, `AddiFQDN`, `RefactorFQDN`, `DB2CertPath`, `MyHashPassword`
```bash
KeyPass="password"
KeyStorePath="C:\certificates\server_keystore.p12"
CertificatePath="C:\certificates\"
CertificatePathRoot="C:\certificates\root.crt"
RootFilePath="C:\root\certs\root.crt"
Username="Administrator"
AddiIP=<Your ADDI IP Address>
RefactorIP=<your Refactor IP Address>
MyHashPassword="<GENERATE YOUR HASH PASSWORD HERE using httpdpassword i.e 2$y$10....Iy>"
JreCaCertsPath="<JreCerts Path...>"
DB2CertPath="<Path to your DigiCertGlobalRootCA.crt can be generated on IBM Cloud DB2 > "
AddiFQDN=<Your ADDI FQDN>
RefactorFQDN=<Your Refactor FQDN>
```

e.g example of your .env file

```
KeyPass="password"
KeyStorePath="C:\certificates\server_keystore.p12"
CertificatePath="C:\certificates\"
CertificatePathRoot="C:\certificates\root.crt"
RootFilePath="C:\root\certs\root.crt"
Username="Administrator"
AddiIP=123.456.789
RefactorIP=223.456.789
MyHashPassword="$2y$10$vAk2SLjHIU2x2dNuzwDxDuq6TwdnLK1XeO8OCzxNqXK3yv3ObYfIy"
JreCaCertsPath="C:\Program Files\Eclipse Adoptium\jre-11.0.22.7-hotspot\lib\security\cacerts"
DB2CertPath="C:\certificates\DigiCertGlobalRootCA.crt"
AddiFQDN="addi.cpdkh23yy.ibmworkshops.com"
RefactorFQDN="refactor.cpdkh23yy.ibmworkshops.com"
```

Then you can run the helper script `.\tls_certs_configuration.ps1` to generate the following files.
- `combined.cer`
- `combined.crt`
- `root.crt`
- `server_key`
- `server_certificate.crt`
- `server_keystore.p12`
- `zookeeper.crt`
- `zookeeper.yaml`


Then you can run the helper script to generate you the certs. 
```
.\tls_certs_configuration.ps1
```

Once the script completes verify that those 5 files exist on your `C:\certificates` directory.