# cms-docker
Docker container with ready-to-use CMS.


Change DBPASSWORD in .env_variables file. This specifies password for postgresDB.

To start the container first build it using docker-compose:
`docker compose build`.

After that run the container using predefined port mapping in docker-compose.yml:
`docker compose up`.

If you want to run the container in the background, use:
`docker compose up &`.

If you want to connect to running container use:
`docker exec -it cms-docker bash`. 
