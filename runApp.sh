#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

function dkcl(){
        CONTAINER_IDS=$(docker ps -aq)
	echo
        if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" = " " ]; then
                echo "========== No containers available for deletion =========="
        else
                docker rm -f $CONTAINER_IDS
        fi
	echo
}

function dkrm(){
        DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
	echo
        if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" = " " ]; then
		echo "========== No images available for deletion ==========="
        else
                docker rmi -f $DOCKER_IMAGE_IDS
        fi
	echo
}

function restartNetwork() {
	# COMPOSE_FILE=./artifacts/docker-compose.yaml

	# COMPOSE_FILE_COUCH=./artifacts/docker-compose-couch.yaml

	# # kafka and zookeeper compose file
	# COMPOSE_FILE_KAFKA=./artifacts/docker-compose-kafka.yaml

	# CONSENSUS_TYPE="solo"

	echo

  #teardown the network and clean the containers and intermediate images
	docker-compose -f ./artifacts/docker-compose.yaml down
	dkcl
	dkrm

	#Cleanup the stores
	rm -rf ./fabric-client-kv-org*

	#Start the network
	docker-compose -f ./artifacts/docker-compose.yaml up -d

	# echo "CONSENSUS_TYPE="$CONSENSUS_TYPE
	# if [ "$CONSENSUS_TYPE" == "solo" ]; then
    # 	configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./artifacts/genesis.block
	# 	docker-compose -f ./artifacts/docker-compose.yaml up -d
  	# elif [ "$CONSENSUS_TYPE" == "kafka" ]; then
    # 	configtxgen -profile SampleDevModeKafka -channelID byfn-sys-channel -outputBlock ./artifacts/genesis.block
	# 	#Start the network
	# 	docker-compose -f ./artifacts/docker-compose.yaml up -d
  	# else
	#   echo "unrecognized CONSENSUS_TYPE='$CONSENSUS_TYPE'. exiting"
	#   exit 1
	# fi
	# res=$?
	# if [ $res -ne 0 ]; then
    # echo "Failed to generate orderer genesis block..."
    # exit 1
  	# fi
		

	#CouchDB Configuration
	# if [ "${IF_COUCHDB}" == "couchdb" ]; then
    # 	if [ "$CONSENSUS_TYPE" == "kafka" ]; then
    #   IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_KAFKA -f $COMPOSE_FILE_COUCH up -d 2>&1
    # 	else
    #   IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH up -d 2>&1
    # 	fi
  	# else
    # 	if [ "$CONSENSUS_TYPE" == "kafka" ]; then
    #   IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_KAFKA up -d 2>&1
    # 	else
    #   IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE up -d 2>&1
    # 	fi
  	# fi
  	# if [ $? -ne 0 ]; then
    # echo "ERROR !!!! Unable to start network"
    # exit 1
  	# fi

  	# if [ "$CONSENSUS_TYPE" == "kafka" ]; then
    # sleep 1
    # echo "Sleeping 10s to allow kafka cluster to complete booting"
    # sleep 9
  	# fi
}

function installNodeModules() {
	echo
	if [ -d node_modules ]; then
		echo "============== node modules installed already ============="
	else
		echo "============== Installing node modules ============="
		npm install
	fi
	echo
}


restartNetwork

installNodeModules

PORT=4000 node app
