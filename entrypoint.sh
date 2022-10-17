#!/bin/bash

su - newuser

/env/bin/xpra start ":81" --bind-tcp="0.0.0.0:8080" --mdns=no --webcam=no --no-daemon --start-on-connect="/env/bin/spyder" --start="xhost +"

tail -F /dev/null
