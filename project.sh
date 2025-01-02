#!/bin/bash

## Check for linux and docker compose or quit

if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Script runs only on GNU/Linux OS. Exiting..." 
    exit
fi

if [[ ! -x "$(command -v compose version)" ]]; then
    echo "Compose plugin is not installed. Exiting..."
    exit
fi

## Variables

#PROJECT_NAME=`echo ${PWD##*/}` ## PROJECT_NAME = parent directory
PROJECT_UID=$(id -u)
PROJECT_GID=$(id -g)

export COMPOSE_IGNORE_ORPHANS=True
echo "Setting COMPOSE_IGNORE_ORPHANS to true and making it accessible to current shell process"

## Configuration files

# docker-compose.yml
if [ ! -f docker-compose.yml ]; then
    cat << EOF > docker-compose.yml
services:
    node:
        image: node:current-alpine
        user: $PROJECT_UID:$PROJECT_GID
        working_dir: /home/node
        volumes:
            - .:/home/node
        environment:
            NODE_ENV:   development
            PATH:     "/home/node/.yarn/bin:/home/node/node_modules/.bin:\$PATH"
        network_mode: host
EOF
fi

clean() {

    docker compose down -v --rmi all --remove-orphans
    rm -rf \
        docker-compose.yml \
        node_modules \
        yarn.lock \
        .cache \
        .npm \
        .yarn/berry \
        .yarn/bin \
        .yarn/unplugged \
        .yarn/install-state.gz \
        .yarnrc

}

node() {

if [ ! -f package.json ]; then
    docker compose run node yarn init
else
    docker compose run node yarn install
fi

    docker compose run node sh -c "printenv"
    docker compose run node sh -c "yarn serve"

}

start() {

    node

}

"$1"
