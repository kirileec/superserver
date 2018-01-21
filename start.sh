#!/bin/bash
echo Begin Rabbit
chown -R rabbitmq:rabbitmq /data
ulimit -n 1024
set -m
rabbitmq-server -detached

mongodb_cmd="mongod"
cmd="$mongodb_cmd"

if [ "$AUTH" == "yes" ]; then
	    cmd="$cmd --auth"
    fi

    $cmd &

    if [ ! -f /data/db/.mongodb_password_set ]; then
	      nohup  /set_mongodb_password.sh &
	fi

	fg


echo Begin SuperCenterServer
/superserver/SuperCenterServer
