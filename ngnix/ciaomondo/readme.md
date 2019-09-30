Compilazione:

docker build -t raffo-ngnix:v0 .
docker run -dit --name raffo-app2 -p 8080:80 raffo-ngnix:v0
