#!/usr/bin/env bash

source functions.sh
atual=""
declare -A companhia
declare -A aeroporto
companhia["teste"]=1
aeroporto["teste"]=1

#Feature .3
function atrasos_por_companhia(){
	companhia_mais_atrasos="teste"

	#Para cada uma das companhia com atrasos, faça
	for key in ${!companhia[@]};do
		#Se a companhia atual tiver mais atrasos que a companhia com mais atrasos
        	if [[ ${companhia[$key]} -gt ${companhia[$companhia_mais_atrasos]} ]]; then
			#A companhia atual se torna a companhia com mais atrasos
			companhia_mais_atrasos=$key
		fi
	done

	echo "A Companhia com mais atrasos foi:"
	echo $companhia_mais_atrasos
}

#Feature .4
function atrasos_por_aeroporto(){
        aeroporto_mais_atrasos="teste"

	#Para cada uma dos aeroportos com atrasos, faça
        for key in ${!aeroporto[@]};do
		#Se o aeroporto atual tiver mais atrasos que o aeroporto com mais atrasos
                if [[ ${aeroporto[$key]} -gt ${aeroporto[$aeroporto_mais_atrasos]} ]]; then
			#O aeroporto atual se torna a companhia com mais atrasos
                        aeroporto_mais_atrasos=$key
                fi
        done

        echo "O Aeroporto com mais atrasos foi:"
        echo $aeroporto_mais_atrasos
}


function ler_companhia(){
	#Realiza a leitura do arquivo carriers.csv linha por linha, atribuindo a primeira célula para a variável sigla, e a segunda célula para a variável nome
	while IFS=, read -r sigla nome; do
		#declara a string aspas com valor "
		aspas="\""
		#se a "sigla" for igual a sigla lida
	        if [[ "$aspas$1$aspas" == $sigla ]]; then
			#se já existir o registro desta companhia
        	        if [ "${#companhia[@]}" -ne 0 ]; then
				#adiciona +1 nos valores de atraso
                	        companhia["$1"]=$((companhia["$1"] + 1))
	                else
				#cria a companhia com valor 1
	                        companhia["$1"]=1
        	        fi
	        fi
	done < carriers.csv

	#imprime a leitura atual do dicionário de companhias e atrasos (somente para testes)
	for key in ${!companhia[@]};do
        	echo "Companhia  = ${key}"
	        echo "Atrasos = ${companhia[$key]}"
	done
}

function ler_aeroporto(){
	#Realiza a leitura do arquivo airports.csv linha por linha, atribuindo a primeira célula para a variável sigla, e a segunda célula para a variável nome, o restante ficará na variável cidade
	while IFS=, read -r sigla nome cidade; do
	        #mesma lógica da função ler_companhia
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
        d ) # Download de datasets 
            shift 
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
	     #Realiza a leitura linha por linha do arquivo que o usuário decidir utilizar ($2) e armazena os valores separados por , para cada célula do array arr
	     while IFS=, read -ra arr; do
		#Se o ano do dado for igual a entrada do usuário
		if [[ ${arr[0]} -eq $2 ]]; then
			#se o valor de atraso for positivo
			if [[ ${arr[14]} -gt 0 ]]; then
				#Conta mais um atraso
				contador_atrasos=$(($contador_atrasos + 1))
			fi
		fi
	     done < $2
	     echo "O número de atrasos neste ano foram:"
	     echo "$contador_atrasos"

	;;
	c ) # Dados por Companhia aérea

	     #Mesma lógico do caso -n
	     while IFS=, read -ra arr; do
                if [[ ${arr[0]} -eq $2 ]]; then
                        if [[ ${arr[14]} -gt 0 ]]; then
				#chama a função ler_companhia passado por parâmetro a sigla da companhia com atraso
				ler_companhia ${arr[8]}
			fi
                fi

		#conta apenas 100 linhas (Para teste)
                contador=$((contador + 1))
	        if [[ $contador -gt 100  ]];then
        	        break
	        fi

             done < $2
	     #chama a função que verifica o número de atrasos_por_companhia
	     atrasos_por_companhia
	;;
	a ) # Atraso por Aeroporto

	    #Mesma lógica do caso -n
	    while IFS=, read -ra arr; do
                if [[ ${arr[0]} -eq $2 ]]; then
                        if [[ ${arr[14]} -gt 0 ]]; then
                                #chama a função ler_aeroporto passando por parâmetro a sigla do aeroporto com atraso
				ler_aeroporto ${arr[17]}
                        fi
                fi

		#conta apenas 100 linhas (Para teste)
                contador=$((contador + 1))
                if [[ $contador -gt 100  ]];then
                        break
                fi

             done < $2
	     #chama a função que verifica o número de atrasos_por_aeroporto
	     atrasos_por_aeroporto
	;;
        \? ) echo "Usage: flight-delays.sh [-d] [-t]"
        ;;
  esac
done


