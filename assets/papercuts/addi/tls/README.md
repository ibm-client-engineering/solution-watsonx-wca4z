## Install Dependencies
To install OpenSSL 
```
.\dependencies\install_open_ssl.ps1
```

Next, update the `tls/.env` file where it mentions `change this`. you can use the default values or change them if you'd like
```bash
KeyPass="password" # default
KeyStorePath="C:\certificates\server_keystore.p12" # default
CertificatePath="C:\certificates\" # default
CertificatePathRoot="C:\certificates\root.crt" # default
RootFilePath="C:\root\certs\root.crt" # default
Username="Administrator" # change this
AddiIP=9.46.246.102 # change this
RefactorIP=9.46.246.104 # change this
JreCaCertsPath="C:\Program Files\Eclipse Adoptium\jre-11.0.22.7-hotspot\lib\security\cacerts" # change this
```

Then you can run the helper script to generate you the certs. 
```
.\tls_certs_configuration.ps1
```

Once the script completes verify that those 5 files exist on your `C:\certificates` directory.