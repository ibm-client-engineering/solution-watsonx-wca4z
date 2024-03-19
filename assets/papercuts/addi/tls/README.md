# TLS

This README provides instructions for automating SCP (Secure Copy Protocol) file transfer between hosts using PowerShell with SSH key-based authentication.

## Prerequisites

Before proceeding, ensure the following prerequisites are met:

- Windows or Linux machine with PowerShell installed.
- SSH installed on both the source and destination hosts.
- Permission to execute PowerShell scripts.
- Access to both the source and destination hosts via SSH.
- Basic understanding of PowerShell scripting.

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