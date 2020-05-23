#!/bin/bash 

user=rabbitmq-user 
password=PASS 

ip=ADDRESS

data=$(curl -s -u $user:$password http://$ip:15672/api/queues | jq '') 

queue_name=($(echo $data | jq '[.[]["name"]]' | awk -F '"' '{print $2}')) 

queue_messages=($(echo $data | jq '[.[]["messages"]]' | awk -F ',' '{print $1}')) 

delete=$1 
echo "deleting? $delete" 
echo "###############" 
echo "${queue_name[@]}" 
echo "${queue_messages[@]}" 
echo "###############" 

count=${#queue_name[@]} 

i=0 
 
while [ "$i" -lt "$count" ] 
do 
        echo "queue_name $i = "${queue_name[$i]} 
        echo "queue_messages $[i+1] = "${queue_messages[$i+1]} 
        if [[ ${queue_messages[$i+1]} == "0" ]] && [[ ${queue_name[$i]} == *x.delay ]] 
        then 
                echo "queue ${queue_name[$i]} was deleting ###############" 
                if [[ $delete == delete ]] 
                then 
                        echo "deleting? $delete" 
                        curl -u $user:$password \
                                http://$ip:15672/api/queues/%2F/${queue_name[$i]} \
                                -X DELETE \
                                -H 'content-type: application/json' \
                                --data-binary '{"vhost":"/","name":"${queue_name[$i]}","mode":"delete"}' 
                fi 
        fi 
        i=$[i+1] 
done 

exit 0
