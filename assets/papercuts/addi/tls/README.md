## Install Dependencies
To install OpenSSL 
```
.\dependencies\install_open_ssl.ps1
```

To set up TLS on your environment update `tls/.env` file 
```bash
keyPass="p@ssw0rd"
keyStorePath="C:\certificates\server_keystore.p12"
certificatePath="C:\certificates\"
certificatePathRoot="C:\certificates\root.crt"
```

Then you can run to set up the following certs. `server.key`, `server_certificate`, `server_keystore`, `zookeeper`, `root.crt` on `C:\certificates\`
```
.\tls_certs_configuration.ps1
```

Once the script completes verify that those 5 files exist on your `C:\certificates` directory.