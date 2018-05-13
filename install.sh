#!/bin/bash
network="lightning"
neutrino="faucet.lightning.community"
lnd="lnd-bb"
lncli_web="lncli-web-bb"
lnddir=$HOME/.lnd-bb

info() {
  echo -e "\e[36m$1\e[0m"
}
error() {
  echo -e "\e[31m$1\e[0m"
}

if [[ ! $(command -v chromium-browser) ]]; then
  info "Installing Chromium..."
  sudo apt install chromium-browser
fi

if [[ ! $(command -v docker) ]]; then
  error "Docker not installed, please install Docker"
  error "https://store.docker.com/search?type=edition&offering=community"
  exit 1
fi

if [[ $(docker ps | echo $?) -gt 0 ]]; then
  error "Your user does not have permission to run Docker commands"
  error "Add yourself to the 'docker' group and log out and back in"
  exit 1
fi

if [[ $(docker network ls -qf "name=$network" | wc -l) -gt 0 ]]; then
  error "Docker network exists, skipping"
else
  info "Creating internal Docker network..."
  docker network create $network
fi

if [[ $(docker ps -qaf "name=$lnd" | wc -l) -gt 0 ]]; then
  error "LND container already exists, skipping"
else
  info "Creating LND Docker container..."
  docker create --network $network \
    -e BITCOIN_ACTIVE=1 \
    -e BITCOIN_TESTNET=1 \
    -e BITCOIN_NODE=neutrino \
    -e NEUTRINO_CONNECT=$neutrino \
    -e RPCLISTEN=0.0.0.0:10009 \
    -e RESTLISTEN=0.0.0.0:8080 \
    -e TLSEXTRAIP=0.0.0.0 \
    -v $lnddir:/root/.lnd \
    --publish 9735:9735 \
    --publish 127.0.0.1:8080:8080 \
    --expose 10009 \
    --name $lnd \
    tyzbit/lnd
fi

if [[ $(docker ps -qaf "name=$lncli_web" | wc -l) -gt 0 ]]; then
  error "lncli-web container already exists, skipping"
else
  info "Creating lncli-web Docker container..."
  docker create --network $network \
    -e SET_LNDHOST=$lnd:10009 \
    -e SET_SERVERHOST=0.0.0.0 \
    -v $lnddir:/config \
    --publish 127.0.0.1:8280:8280 \
    --name $lncli_web \
    tyzbit/lncli-web
fi

if [[ $(docker ps -qf "name=$lnd" | wc -l) -gt 0 ]]; then
  error "LND container (name: $lnd) already running"
else
  info "Starting LND"
  docker start $lnd
  info "Create a wallet"
  docker exec -it $lnd lncli create
fi

if [[ $(docker ps -qf "name=$lncli_web" | wc -l) -gt 0 ]]; then
  error "LND container (name: $lncli_web) already running"
else
  info "Starting lncli-web"
  # sleeping 5 to give the macaroons time to generate
  sleep 5; docker start $lncli_web
fi
