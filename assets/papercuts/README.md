# WCA4Z_Install

This repository houses scripts and tools for automating the installation and setup of pre-requisites, applications, and 
services on an operating system. The repository is organized into two main directories `/refactor` && `addi`.

# Refactor
## Pre-reqs installation
- Ensures the required OS system version is met.
- Verifies available RAM, storage and CPU cores.
## Tools instllation
- Installs podman for container mgmt
- Installs OpenSSL for secure communication.
- Downloads and configures Java.
- Downloads and configures Watson X Code Assistant for Z.

# Addi
## User Access Management
- Scripts: `set_user_permissions.ps1`
- Manages user access by setting folder permissions and verifying the existence of required directories.

## SQL Server Provisioning
- Script: `sql_server_install.ps1`
- Installs and verifies the java development kit (jdk) along with setting up the env path

# Usage
1. Clone the repository to your local machine:
   `git clone https://github.ibm.com/Samuel-L/WCA4Z_Install.git`
2. Navigate to the desired directory (refactor or addi)
3. Execute the relevant script(s) based on your requirements. 

# Notes
- For detailed information on each script and its functionalities, refer rto the respective script files within the directories
- Always review and customize scripts based on your specific environment 
- Ensure proper permissions and execution rights before running the scripts.

# Contributors
- Samuel Lee
- Oscar Ricaud
- Eashan Thakuria
- Myron Woods
