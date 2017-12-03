# jenkins-maven-ssh
use jenkins to build maven project and ssh to deploy

ssh to execute the auto-deploy scripts:

#!/bin/bash

ips="192.168.153.133,192.168.153.134"

hosts=$(echo $ips | tr "," "\n")

for targethost in $hosts
do
	scp $WORKSPACE/kevin_test/target/*.war kevinhou@$targethost:/home/kevinhou/

	scp -r $WORKSPACE/kevin_test/autoScripts/ kevinhou@$targethost:/home/kevinhou/

    if [[ $? == 0 ]]; then
        ssh kevinhou@$targethost "sed -i 's/\r$//' /home/kevinhou/autoScripts/test.sh"
        ssh kevinhou@$targethost "sh /home/kevinhou/autoScripts/test.sh"
    fi
    
        ssh kevinhou@$targethost "echo $(docker ps -a |grep 'name=kevin'|grep 'status=running'|awk -F {print $1})"
    fi
    
done

