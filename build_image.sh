docker build -t my-docker-app .
docker stop ace2_docker; docker rm ace2_docker; docker create -t -v /tmp/.X11-unix:/tmp/.X11-unix  -v $HOME/.Xauthority:/root/.Xauthority -p 6878:6878 -p 6000:6000 -e DISPLAY=$DISPLAY --name ace2_docker my-docker-app
xhost +local:docker
docker start ace2_docker
docker exec -it ace2_docker bash
docker logs ace2_docker -f -n 500
docker image prune -a

# Updating image
docker build --pull --no-cache -t my-docker-app .
docker stop ace2_docker; docker rm ace2_docker; docker create -t -v /tmp/.X11-unix:/tmp/.X11-unix  -v $HOME/.Xauthority:/root/.Xauthority -p 6878:6878 -p 6000:6000 -e DISPLAY=$DISPLAY --name ace2_docker my-docker-app

# Clean cache
docker start ace2_docker
docker exec -it ace2_docker bash -c "du -h /home/appuser/.ACEStream/.acestream_cache/"
docker exec -it ace2_docker bash -c "rm /home/appuser/.ACEStream/.acestream_cache/live*"
docker exec -it ace2_docker bash -c "rm /home/appuser/.ACEStream/.acestream_cache/hls*"
docker stop ace2_docker

