#!/usr/bin/env bash

source functions.sh
atual=""

function ler_companhia(){
while IFS=, read -r sigla nome; do
	aspas="\""
	if [[ "$aspas$1$aspas" == $sigla ]] && [[ $atual != $nome ]]; then
		echo "$nome"
		atual="$nome"
	fi
done < carriers.csv
}

while getopts ":dtnc" opt; do
    case ${opt} in
        d ) # process option h
            shift # Removes de First Argument from the queue
            download_datasets $1
            test -f /2006.tar && echo "$FILE já descompactado."
	    test -f /2007.tar && echo "$FILE já descompactado."
	    bzip2 -d 2006.tar.bz2
            bzip2 -d 2007.tar.bz2
	    mv 2006.tar 2006
	    mv 2007.tar 2007
        ;;
        t ) # process option t
        ;;
	n ) # Listar atrasos por ano
	     echo "$2"
	     contador_atrasos=0
	     while IFS=, read -ra arr; do
		if [[ ${arr[0]} -eq $2 ]]; then
			if [[ ${arr[14]} -gt 0 ]]; then
				contador_atrasos=$(($contador_atrasos + 1))
			fi
		fi
	     done < $2
	     echo "O número de atrasos neste ano foram:"
	     echo "$contador_atrasos"

	;;
	c ) # Atraso por Companhia aérea
	     echo "$2"
             while IFS=, read -ra arr; do
                if [[ ${arr[0]} -eq $2 ]]; then
                        if [[ ${arr[14]} -gt 0 ]]; then
				ler_companhia ${arr[8]}
			fi
                fi
             done < $2
	;;
        \? ) echo "Usage: flight-delays.sh [-d] [-t]"
        ;;
  esac
done


