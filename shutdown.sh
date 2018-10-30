#!/usr/bin/env bash

proxy_bin="oauth2_proxy.darwin"

function kill_stuff {
  echo "Killing oauth_proxy"
  pkill -9 "$proxy_bin"

  echo "Killing middleman"
  pkill -9 middleman
}

trap kill_stuff SIGINT SIGTERM

kill_stuff
