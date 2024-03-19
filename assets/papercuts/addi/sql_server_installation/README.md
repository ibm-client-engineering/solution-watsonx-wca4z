## How to run SQL Server

## Allow the ability to run scripts
`Set-ExecutionPolicy Unrestricted`

## Install SQL Server
```
cd assets/papercuts/addi/SQL_Server
.\sql_server_install.ps1
```

## Configure SQL User Permissions
```
cd assets/papercuts/addi/SQL_Server
.\sql_user_permissions.ps1
```

## Output
```

Attached          : False
BlockSize         : 0
DevicePath        :
FileSize          : 1426724864
ImagePath         : C:\Users\ADMINI~1\AppData\Local\Temp\sql_server_install\SQLServer2019-x64-ENU-Dev.iso
LogicalSectorSize : 2048
Number            :
Size              : 1426724864
StorageType       : 1
PSComputerName    :
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Microsoft SQL Server 2019 (RTM) - 15.0.2000.5 (X64)
        Sep 24 2019 13:48:23
        Copyright (C) 2019 Microsoft Corporation
        Developer Edition (64-bit) on Windows 10 Enterprise 10.0 <X64> (Build 22621: ) (Hypervisor)
(1 rows affected)
```

** Note Restart powershell **
```
PS C:\Users\Administrator\Downloads\solution-watsonx-wca4z-main\solution-watsonx-wca4z-main\assets\papercuts\addi\SQL_Server> "SELECT @@version" | sqlcmd
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.
Install the latest PowerShell for new features and improvements! https://aka.ms/PSWindows
PS C:\Users\Administrator> “SELECT @@version” | sqlcmd
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Microsoft SQL Server 2019 (RTM) - 15.0.2000.5 (X64)
        Sep 24 2019 13:48:23
        Copyright (C) 2019 Microsoft Corporation
        Developer Edition (64-bit) on Windows 10 Enterprise 10.0 <X64> (Build 22621: ) (Hypervisor)
(1 rows affected)
PS C:\Users\Administrator>
```

## Update .env file
Update `sqlUser`, `serverInstance`, `sqlPassword`, `sqlDatabase`, `sqlCredential`


## Troubleshoot Reset SQL Password
If you are having issues with ADDI Server not connecting to the SQL Server you can do the following:

Open powershell as an admin
```powershell
sqlcmd
>> 1 ALTER LOGIN my_user WITH PASSWORD='me?*L=OchopRlx@9woc', CHECK_POLICY= OFF, CHECK_EXPIRATION = OFF;
>> 2 GO
```

Try again and you should now be able to login 
