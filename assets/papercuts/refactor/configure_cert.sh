#Load .env
set -o allexport
source .env set
+o allexport


echo $CERTS_LOCATION
echo $HOST_PORT
echo $ENVIRONMENT_ID

#copy config templat
e and edit
cp -a 'refactoring_assistant/config/template.properties' 'refactoring_assistant/config/config.properties'

sed -i "s@CERTS_LOCATION=.*@CERTS_LOCATION=$CERTS_LOCATION@" config.properties
sed -i "s@HOST_PORT=.*@HOST_PORT=$HOST_PORT@" config.properties
sed -i "s@ENVIRONMENT_ID=.*@ENVIRONMENT_ID==$ENVIRONMENT_ID@" config.properties

chmod 766 /refactoring_assistant/scripts/nls.sh

#./refactoring_assistant/start.sh --prepare-only /root/certs
