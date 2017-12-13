#!/bin/bash  
#-------------------------------------------------------------------------------------------  
#   Script Name: autoDeployMain.sh  
#   Shell script to do auto-deployment                                                                           
#   <scriptPath>/autoDeployMain.sh
#   Version history:  
#   1.5     12/12/2017  HouYinlei --- docker registry url verification
#   1.4     05/12/2017  HouYinlei --- Done some improvements regarding global variables setting
#   1.3     01/12/2017  HouYinlei --- Improved check_stop_container process
#   1.2     28/11/2017  HouYinlei --- Done some optimization regarding existing image check
#   1.1     27/11/2017  HouYinlei --- Updated rename and remove process as well as docker run etc.  
#   1.0     22/11/2017  HouYinlei --- Created initial script to do auto-deployment                                  
#-------------------------------------------------------------------------------------------  

###pull the latest java8tomcat7 image from registry
check_get_image(){

	docker inspect --type=image "$BASEIMAGE"  > /dev/null 2>&1
	if [[ $? == 0 ]]; then
		info "$BASEIMAGE is already existing on this host, will not pull it again!"
	else
		info "$BASEIMAGE is not here on this host, now going to pull it from harbor..."
		docker pull $BASEIMAGE
		
		if [[ $? != 0 ]]; then
			error "failing to pull image from harbor, will exit this script, please check"
			exit 1
		fi
		
	fi
	
}

###1. check if the kevintest_registry container is running, then keep it!
###2. rename the running kevintest container to "kevintest_backup"
###3. stop the new-named "kevintest_backup"
check_stop_container(){

	#CONTAINER_NAME="kevintest"
	#check if kevintest-registry exists or not
	REGISTRY_CONTAINER_ID=`docker ps -a -f "status=running"|grep kevintest-registry|awk '{ print $1}'`
	RUNNING_CONTAINER_NUM=`docker ps -a -f "status=running"|grep $CONTAINER_NAME|wc -l`
	RUNNING_CONTAINER_IDs=`docker ps -a -f "status=running"|grep $CONTAINER_NAME|awk '{ print $1}'`
	
	if [[ $RUNNING_CONTAINER_NUM -gt 2 ]]; then
		error "there are more than 2 kevintest container running on this host, please check manually!"
		exit 1
	else
	
		for cid in $RUNNING_CONTAINER_IDs
		do
			if [[ "$cid" == "$REGISTRY_CONTAINER_ID" ]]; then
				info "kevintest-registry container is running on this host..."
			else
				OLD_NAME=`docker inspect -f '{{with .State}} {{$.Name}} {{end}}'  $cid | cut -d/ -f2`
				info "rename the running container $OLD_NAME to kevintest_backup."
				docker rename $OLD_NAME kevintest_backup
				info "stopping the old container..."
				docker stop kevintest_backup
			fi		
		done
		
	fi
	
}

###remove the old exited containers if this is the first time to run this script
check_remove_container(){

	#CONTAINER_NAME="kevintest"
	CONTAINER_ID=`docker ps -a -f "status=running"|grep $CONTAINER_NAME|awk '{ print $1}'`
	if [[ ! -z "$CONTAINER_ID"  ]]; then
		OLD_NAME=`docker inspect -f '{{with .State}} {{$.Name}} {{end}}'  $CONTAINER_ID | cut -d/ -f2`
		info "$OLD_NAME is running now..."
	fi
	
	info "deleting the exited container."
	EXITED_CONTAINER_IDs=`docker ps -a -f "status=exited"|awk '{ print $1}'`
	for ecid in ${EXITED_CONTAINER_IDs}
	do
		if [[ "$ecid" != "CONTAINER"  ]]; then
			docker rm $ecid
		fi
	done
	
	#docker rm $(docker ps -aq)
	
}

###start the new container based the java8tomcat7 image and new generated war file
start_container(){

	warnum=`ls $AUTODIR/*.war|wc -l`
	
	if [[ $warnum -gt 0 ]]; then
		info "war file has scped to $AUTODIR, will going on proceeding the deployment..."
	else
		error "it is not able to find any war file under $AUTODIR, please check"
		exit 1
	fi
	
	#JMX_PORT is needed by net host mode, bridge mode does not need it(default 8061)
	docker run -d --net host -e PORT=$PORT -e JMX_PORT=$JMX_PORT --name="$CONTAINER_NAME" \
		-v /home/kevinhou/.ssh:/home/kevinhou/.ssh:rw \
		-v $AUTODIR:/data/apps:rw \
		$BASEIMAGE  
	
	###check if the ontainer is started successfully or not
	COUNT=60
	for i in `seq 1 $COUNT`
	do
		sleep 2
		CONTAINER_ID=`docker ps -a -f "status=running"|grep java8tomcat7|awk '{ print $1}'`
		if [[ ! -z "$CONTAINER_ID"  ]]; then
			info "kevintest is started successfully!"
			#remove the war file from auto dir once the container is started successfully
			rm -f $AUTODIR/*.war
			break
		else 
			info "starting..."
		fi		
	done
	
	#recover to backup once the newer kevintest container starting failed... 
	RUNNING_CID=`docker ps -a -f "status=running"|grep java8tomcat7|awk '{ print $1}'`
	if [[ -z "$RUNNING_CID"  ]]; then
		info "kevintest container was not started successfully, now will recover to backup one..."
		
		docker rm kevintest
		
		recover_container
		
	fi		
	
}

###recover to the backup container "kevintest_backup" and rename it back to kevintest
recover_container(){

	CONTAINER_ID=`docker ps -a -f "status=running"|grep kevintest_backup|awk '{ print $1}'`
	if [[ ! -z "$CONTAINER_ID"  ]]; then
		
		error "kevintest_backup is running, will exit this script..."
		exit 1

	else
	
		info "starting the backup container..."
		docker start kevintest_backup
		sleep 5
		docker rename kevintest_backup kevintest
		
	fi		

}

###deployment process
deploy(){

	check_remove_container
	check_get_image
	check_stop_container
	start_container
}

###recovery process
recovery(){
	recover_container
}

####################################start from here################################################

BINDIR=`pwd`  
cd $BINDIR 
scriptLocation="$( cd "$( dirname "$0"  )" && pwd  )" 

source $scriptLocation/logger.sh
source $scriptLocation/autoDeployMain.param

BASEIMAGE="${TOMCAT_BASEIMAGE}"
action=$ACTION

  
case $action in   
"deploy") deploy;;  
"recovery") recovery;;  
*) echo "invalid entry";;  
esac