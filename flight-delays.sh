#!/usr/bin/env bash

source functions.sh
atual=""
declare -A companhia
declare -A aeroporto

function ler_companhia(){
while IFS=, read -r sigla nome; do
	aspas="\""
        if [[ "$aspas$1$aspas" == $sigla ]]; then
                if [ "${#companhia[@]}" -ne 0 ]; then
                        companhia["$1"]=$((companhia["$1"] + 1))

                else
                        companhia["$1"]=1
                fi
        fi
done < carriers.csv

for key in ${!companhia[@]};do
        echo "Companhia  = ${key}"
        echo "Atrasos = ${companhia[$key]}"
done
}

function ler_aeroporto(){

while IFS=, read -r sigla nome cidade; do
        aspas="\""
        if [[ "$aspas$1$aspas" == $sigla ]]; then
		if [ "${#aeroporto[@]}" -ne 0 ]; then
			aeroporto["$1"]=$((aeroporto["$1"] + 1))

		else
			aeroporto["$1"]=1
		fi
	fi
done < airports.csv

for key in ${!aeroporto[@]};do
	echo "Aeroporto  = ${key}"
	echo "Atrasos = ${aeroporto[$key]}"
done

}

while getopts ":dtnca" opt; do
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
	a ) # Atraso por Aeropoto
	    while IFS=, read -ra arr; do
                if [[ ${arr[0]} -eq $2 ]]; then
                        if [[ ${arr[14]} -gt 0 ]]; then
                                ler_aeroporto ${arr[17]}
                        fi
                fi
             done < $2

	;;
        \? ) echo "Usage: flight-delays.sh [-d] [-t]"
        ;;
  esac
done


