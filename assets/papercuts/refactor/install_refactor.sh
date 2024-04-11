source .env
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
REFACTOR_INSTALL_PATH=$(grep 'REFACTOR_INSTALL_PATH' .env | cut -d '=' -f 2)

echo "REFACTOR_INSTALL_PATH: $REFACTOR_INSTALL_PATH"

echo $(java --version)
echo $(openssl version)
echo $(podman version)

#unzip the file and setup
ZIP_FILE_PATH="$REFACTOR_INSTALL_PATH/$REFACTOR_NAME_OF_ZIP_FILE"

if [ ! -f "$ZIP_FILE_PATH" ]; then
  echo "ZIP file not found: $ZIP_FILE_PATH"
  exit 1
fi

unzip "$ZIP_FILE_PATH" -d "$REFACTOR_INSTALL_PATH"

if [ $? -ne 0 ]; then
    echo "Unzipping refactoring assistant zip file failed."
    exit 1
fi

# cd "$REFACTOR_INSTALL_PATH/IBM watsonx Code Assistant for Z Refactoring Assistant 1.1.0 Linux Multilingual"/
cd "$(find "$REFACTOR_INSTALL_PATH" -type d -name 'IBM watsonx*' -print -quit)"

echo "Unzipping refactoring-assistant zip file"
unzip refactoring-assistant-1.1.0.zip

tar zxf refactoring-assistant-1.1.0.tgz

echo "Moving refactoring-assistant to ../refactoring_assistant"
mv refactoring-assistant ../refactoring_assistant

cd ../refactoring_assistant
echo "pwd"
echo "ls -la"
# ./setup.sh


