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
To install Putty 
```
.\dependencies\install_pcp.ps1
```

To install OpenSSL 
```
.\dependencies\install_open_ssl.ps1
```


## On Refactor Host you must import the /root/root.crt file into the Windows Host
To install pswh
```
sudo dnf install https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-1.rh.x86_64.rpm
```

To set up TLS on your environment update `tls/.env` file 
```bash
keyPass="p@ssw0rd"
keyStorePath="C:\certificates\server_keystore.p12"
certificatePath="C:\certificates\"
certificatePathRoot="C:\certificates\root.crt"
```

Then you can run to set up the 3 following certs. `server.key`, `server_certificate` and `server_keystore` on `C:\certificates`
```
.\tls_certs_configuration.ps1
```

Once the script completes verify that those 3 files exist on your `C:\certificates` directory. You will then need to do the following [manual step](https://pages.github.ibm.com/ibm-client-engineering/solution-watsonx-wca4z/Prepare/TLS#configuring-certs)
In this section you will need to open the `server_certificate.crt` in a notepad and reset the order of the certs. We want the `root.crt` to be at the top.

You can get your `root.crt` file by ssh into your Refactor Host and you can run `cat /root/root.crt` to get the values.
Create file `root.crt` You can then copy those values in your `C:\certificates`, 


On the RA host, create the zookeeper.crt file in /etc/pki/ca-trust/source/anchors and copy the contents of zookeeper.crt into it.
```bash
update-ca-trust extract
ln -s /etc/pki/ca-trust/source/anchors/zookeeper.crt /root/certs/ad.crt
ln -s /etc/pki/ca-trust/source/anchors/zookeeper.crt /root/certs/dex.crt
ln -s /etc/pki/ca-trust/source/anchors/zookeeper.crt /root/certs/zookeeper.crt
```

Continue the manual steps on the [DEX Server Configuration](https://pages.github.ibm.com/ibm-client-engineering/solution-watsonx-wca4z/Prepare/TLS#configuring-certs) 

## What happens under the hood 

1. **Generates SSH Key Pair**:
    - Use the `Generate-SSHKeyPair` function provided in the PowerShell script to generate an SSH key pair (`id_rsa` and `id_rsa.pub`).
    - Specify the desired passphrase for the private key when prompted.
   ```powershell
   Generate-SSHKeyPair -keyPath "C:\Users\Administrator\.ssh\id_rsa" -passphrase "your_passphrase"
   ```

2. **Copy Public Key to Remote Host**:
    - Use the `Copy-PublicKeyToRemoteHost` function provided in the PowerShell script to copy the public key (`id_rsa.pub`) to the `authorized_keys` file on the remote host.
    - Specify the path to the public key file and the destination host's hostname and username.
    - No password for the remote host is required as SSH key-based authentication is used.
      ```powershell
      
      ```
3. **Automate SCP File Transfer**:
    - Use the `Copy-FileViaSCP` function provided in the PowerShell script to automate SCP file transfer between hosts.
    - Specify the source host, source file path, destination host, destination file path, username, and private key path as parameters.
    - Authentication will be handled using the private key associated with the SSH key pair.

4. **Example Usage**:
    - Example commands for generating SSH key pair, copying the public key to the remote host, and transferring files via SCP are provided in the PowerShell script.
    - Adjust parameters such as file paths, hostnames, and usernames according to your environment.



## Notes
- Ensure SSH key-based authentication is properly set up and tested before relying on automation in a production environment.
- Review and understand the security implications of SSH key-based authentication and SCP file transfer in your environment.
- Modify the provided PowerShell script according to your specific requirements and security policies.