#!/bin/bash

logger(){
	
	type=$1
	shift
	rest=$@
	
	mydt=$(date +"%Y-%m-%d %H:%M:%S")
	echo "${mydt}[${type}][${FUNCNAME[2]}]-${rest}"
}

info(){

	logger INFO "$@"
	
}

warning(){

	logger WARNING "$@"

}

error(){

	logger ERROR "$@"
	logger ERROR "Existing."
	exit -1
	
}
