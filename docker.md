# Docker command notes
---
`docker pull <package name>`
`docker run <package name>` or `docker run -d <package name>` creates new container from image
`docker start <container id>` starts container
`docker stop <container id>`
`docker ps` or `docker ps -a`
---
## run container on certain port of computer
`docker run -p<port on computer>:<port of container> <package name>` 

## debugging
docker logs <container id>
### go into terminal of container
docker exec -it <container id> /bin/bash

