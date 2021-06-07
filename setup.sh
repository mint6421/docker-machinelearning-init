#!/bin/sh

docker rm -f python_machine_learning
docker rmi python_machine_learning

docker-compose up -d

URL=`docker exec -it python_machine_learning sh -c "jupyter notebook list"`
echo $URL
echo $URL > notebookURL.txt
