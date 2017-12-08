#!/bin/bash

set -x
#set -e

if pgrep ruby; then exit; fi

while true
do
  ruby .cron.rb
  if [ $? -eq 0 ]
  then
	  exit
  fi
done
