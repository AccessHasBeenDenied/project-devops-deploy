#!/bin/bash
java -jar app.jar &
nginx -g "daemon off;" &
wait -n  
exit $?