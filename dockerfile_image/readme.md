Compilazione:

docker build -t raffo-image:v0 .
docker run -it --name raffo-image raffo-image:v0 .

Successivamente eseguire il container:
docker container run -it <IMAGE_ID>

All'interno dell container eseguire:
apt-get install -y curl
CTRL+P CTRL+Q

Sseguire 
docker container commit <CONTAINER_ID>

Provare ad eseguire nuovamente il container per verificare la presenza del comando curl
