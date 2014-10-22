#!/bin/sh

set -e

# Set default docker repository if none exist in env
if [ -z $REPOSITORY ]; then
    REPOSITORY="grounds"
fi

# Set default docker url if none exist in env
if [ -z $DOCKER_URL ]; then
    DOCKER_URL="http://127.0.0.1:2375"
fi

# Set default port to serve if none exist in env
if [ -z $PORT ]; then
    PORT="8080"
fi

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

IMAGE="$REPOSITORY/grounds-exec:$GIT_BRANCH"
CONTAINER="grounds-exec"

if [ $DOCKER_TLS_VERIFY ]; then
    volume="-v $DOCKER_CERT_PATH:/home/.docker"
fi

server="server -e $DOCKER_URL -p $PORT -r $REPOSITORY"

build() {
    docker build -t "$IMAGE" .
}

clean() {
    if [ $(container_created) ]; then
        docker rm --force "$CONTAINER"
    fi
}

detach() {
    docker run -d $volume \
               --expose "$PORT" \
               --name "$CONTAINER" \
               "$IMAGE" $server
}

run() {
    docker run -ti $volume \
                -p "$PORT":"$PORT" \
                "$IMAGE" $server
}

test() {
    docker run -t $volume  \
               -e "DOCKER_URL=$DOCKER_URL" \
               -e "REPOSITORY=$REPOSITORY" \
               -e "TEST_OPTS=$TEST_OPTS" \
               --link "$CONTAINER":"$CONTAINER" \
               "$IMAGE" npm test 
}

container_created() {
    echo $(docker inspect --format={{.Created}} "$CONTAINER" 2>/dev/null)
}

main() {
    # If first parameter is missing or empty
    if [ -z $1 ]; then
        echo "usage: make [build|clean|detach|run|test]"
        return
    fi
    eval $1
}

main "$1"
