#!/usr/bin/env bash

source functions.sh

while getopts ":dt" opt; do
    case ${opt} in
        d ) # process option h
            shift # Removes de First Argument from the queue
            download_datasets $1
            test -f /2006.tar && echo "$FILE já descompactado."
	    test -f /2007.tar && echo "$FILE já descompactado."
	    bzip2 -d 2006.tar.bz2
            bzip2 -d 2007.tar.bz2
        ;;
        t ) # process option t
        ;;
        \? ) echo "Usage: flight-delays.sh [-d] [-t]"
        ;;
  esac
done

