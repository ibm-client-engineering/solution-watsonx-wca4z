# WCA4Z_Install

This repository houses scripts and tools for automating the installation and setup of pre-requisites, applications, and 
services on an operating system for Watson Code Assistant for Z. The repository is organized into two main directories `/refactor` && `/addi`.

In each subdirectory you will find different helper functions to automate the following:
- Access Management
- Installation of IBM AD Analyze Client (Addi)
- Installation of Microsoft SQL Server
- Installation of Java 11
- DB2 Configuration
- Configuring TLS/Certs for Refactor Assistant Host and Addi Host 
- Ensures the required OS system version is met.
- Verifies available RAM, storage and CPU cores.
- Installs podman for container mgmt
- Installs OpenSSL for secure communication.
- Downloads and configures Java.
- Downloads and configures Watson X Code Assistant for Z.

# Usage
1. Clone the repository to your local machine:
   `git clone https://github.ibm.com/ibm-client-engineering/solution-watsonx-wca4z`
2. Navigate to the desired directory (`/refactor` or `/addi`)
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
