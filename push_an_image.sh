# az acr login --name SergiiACR
# docker pull nginx
# docker tag nginx SergiiACR.azurecr.io/samples/nginx
docker push SergiiACR.azurecr.io/samples/nginx
