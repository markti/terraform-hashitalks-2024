ACR=craztflabdevagyhy3jv.azurecr.io
IMAGE=health-check
TAG=v2024.02.2

set -e
az acr login --name $ACR

docker buildx build --platform linux/amd64 -t $ACR/$IMAGE:$TAG -f Dockerfile .

docker push $ACR/$IMAGE:$TAG