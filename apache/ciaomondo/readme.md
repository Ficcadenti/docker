Compilazione:

docker build -t raffo-apache2:v0 .
docker run -dit --name raffo-app -p 8080:80 raffo-apache2:v0
