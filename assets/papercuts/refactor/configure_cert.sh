#Load .env
set -o allexport
source .env set
+o allexport

#copy config template and edit
cp 'IBM watsonx Code Assistant for Z Refactoring Assistant 1.1.0 Linux Multilingual/config/template.properties' 'IBM watsonx Code Assistant for Z Refactoring Assistant 1.1.0 Linux Multilingual/config/config.properties'

sed -i "s@CERTS_LOCATION=.*@CERTS_LOCATION=$CERTS_LOCATION@" config.properties
sed -i "s@HOST_PORT=.*@HOST_PORT=$HOST_PORT@" config.properties
sed -i "s@ENVIRONMENT_ID=.*@ENVIRONMENT_ID==$ENVIRONMENT_ID@" config.properties

