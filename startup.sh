#!/usr/bin/env bash

proxy_bin="oauth2_proxy.darwin"

# Build project
bundle exec middleman build

mkdir -p logs

./shutdown.sh
./bin/"$proxy_bin" -config=oauth_config/local.cfg >logs/"$proxy_bin".log 2>&1 &
bundle exec middleman server >logs/middleman.log 2>&1 &

echo "Go to http://127.0.0.1:4180/"
