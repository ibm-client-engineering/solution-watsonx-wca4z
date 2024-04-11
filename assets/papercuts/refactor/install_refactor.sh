#Install

# Check OS version
os_version=$(awk -F"release " '/release/ {print $2}' /etc/redhat-release | awk -F"." '{print $1}')
if [ "$os_version" -ge 7 ]; then
  echo "OS version: Passed (Red Hat Linux $os_version)"
else
  echo "OS version: Failed (Expected Red Hat Linux > 7)"
fi

# Check RAM
ram=$(free -g | awk '/^Mem:/ {print $2}')
if [ "$ram" -ge 16 ]; then
  echo "RAM: Passed ($ram GB)"
else
  echo "RAM: Failed (Expected 16 GB)"
fi

# Check Storage
local_storage=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$local_storage" -ge 100 ]; then
  echo "Local Storage: Passed ($local_storage GB)"
else
  echo "Local Storage: Failed (Expected 100 GB)"
fi

data_storage=$(df -BG /data | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$data_storage" -ge 400 ]; then
  echo "Data Storage: Passed ($data_storage GB)"
else
  echo "Data Storage: Failed (Expected 400 GB for /data)"
fi

# Check Cores
cores=$(nproc)
if [ "$cores" -ge 4 ]; then
  echo "Cores: Passed ($cores)"
else
  echo "Cores: Failed (Expected 4 or more)"
fi


#Prereqs
dnf update

# Install Podman version 4 
echo "Installing Podman version 4..."
dnf -y install podman unzip wget java-11-openjdk.x86_64
systemctl start podman
systemctl enable podman
 
# Install OpenSSL 
echo "Installing OpenSSL..."
dnf install openssl

# Add commands to install OpenSSL based on your package manager (e.g., apt-get, brew) 
echo "Installation completed."

echo "Downloading Refactor Assistant"
wget https://ak-dsw-mul.dhe.ibm.com/sdfdl/v2/fulfill/M0H0FML/Xa.2/Xb.htcOMovxHCAgZGRqiJYFDYk9OTYxy-c7/Xc.M0H0FML/wCAZ_RA_z_OS_1.0.1_Linux_ML.zip/Xd./Xf.lPr.A6VR/Xg.12733994/Xi./XY.knac/XZ.1efcOXzSId6WTOO0hjQ6e7nxqkkooqVN/wCAZ_RA_z_OS_1.0.1_Linux_ML.zip -O wCAZ_RA_z_OS_1.0.1_Linux_ML.zip

echo $(java --version)
echo $(openssl version)
echo $(podman version)

#Install
#unzip the file and setup
unzip wCAZ_RA_z_OS_1.0.1_Linux_ML.zip
cd 'IBM watsonx Code Assistant for Z Refactoring Assistant 1.1.0 Linux Multilingual'/
unzip refactoring-assistant-1.1.0.zip 
tar zxf refactoring-assistant-1.1.0.tgz
mv refactoring-assistant ../refactoring_assistant
cd ../refactoring_assistant
./setup.sh


