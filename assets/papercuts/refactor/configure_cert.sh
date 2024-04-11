#Load .env
set -o allexport
source .env set

#copy config template and edit
cp refactoring_assistant/config/template.properties refactoring_assistant/config/config.properties

chmod 766 refactoring_assistant/config/config.properties

sed -i "s@CERTS_LOCATION=.*@CERTS_LOCATION=$CERTS_LOCATION@" refactoring_assistant/config/config.properties
sed -i "s@HOST_PORT=.*@HOST_PORT=$HOST_PORT@" refactoring_assistant/config/config.properties
sed -i "s@ENVIRONMENT_ID=.*@ENVIRONMENT_ID==$ENVIRONMENT_ID@" refactoring_assistant/config/config.properties

chmod 766 refactoring_assistant/scripts/nls.sh

cd refactoring_assistant
./start.sh --prepare-only /root/certs
