#Load .env
set -o allexport
source .env set

#copy config template and edit
cp /opt/refactoring-assistant/refactoring-assistant/config/template.properties /opt/refactoring-assistant/refactoring-assistant/config/config.properties

chmod 766 refactoring_assistant/config/config.properties

sed -i "s@CERTS_LOCATION=.*@CERTS_LOCATION=$CERTS_LOCATION@" /opt/refactoring-assistant/refactoring-assistant/config/config.properties
sed -i "s@HOST_PORT=.*@HOST_PORT=$HOST_PORT@" /opt/refactoring-assistant/refactoring-assistant/config/config.properties
sed -i "s@ENVIRONMENT_ID=.*@ENVIRONMENT_ID=$ENVIRONMENT_ID@" /opt/refactoring-assistant/refactoring-assistant/config/config.properties

chmod 766 /opt/refactoring-assistant/refactoring-assistant/scripts/nls.sh

cd /opt/refactoring-assistant/refactoring-assistant
./start.sh --prepare-only /root/certs
