# az acr login --name SergiiACR
# docker pull nginx
# docker tag nginx ${azurerm_container_registry.acr.login_server}
# echo "${azurerm_container_registry.acr.login_server}"

SERVER="$1"
USERNAME="$2"
PASSWORD="$3"


docker logout
docker login $SERVER -u $USERNAME -p $PASSWORD
docker push $SERVER/samples/httpd
