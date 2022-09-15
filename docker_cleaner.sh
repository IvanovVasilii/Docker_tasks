#! /bin/bash
# Script for removing failed Swarm services and related volumes

#log file initiation
log_path=/var/log/docker_cleaner
log_name=docker_cleaner.log
#creating dir for log file if dir doesn't exist
if [ ! -d $log_path ]; then mkdir -p $log_path ; fi

#redirect stdout and stderr to log file
exec 1>>$log_path/$log_name 2>&1

echo $(date +"%x %T") "Start of docker_cleaner"

#service name template initiation 
prefix='sandbox_'
liter='_2e'

#user name on other node initiation
ssh_user=$LOGNAME

#looking for services with 0/1 replicas
#that match service name template "^$prefix.*$liter..$"
echo 'Looking for services with 0/1 replicas...'
docker service ls | grep ' 0/1 ' | tr -s ' ' | \
cut -d ' ' -f 2 | grep "^$prefix.*$liter..$"| \
while read serv_name;
do
    {
    echo "=======$serv_name=======";
    #ps_line will contain whole service ps output in one line
    ps_line=$(echo $(docker service ps $serv_name));
    cur_state_begin=$(echo $ps_line|cut -d ' ' -f 16);
    #checking if service just has started
    if [ $cur_state_begin == 'Preparing' ];
    then
        echo "Service $serv_name preparing";
    else
        #remove failed service
        echo "docker service rm $serv_name";
        docker service rm $serv_name && echo "$serv_name was removed";
        #preparation for volume remove
        surname=$(echo $serv_name | cut -d '_' -f 2);
        initials=$(echo $serv_name | rev | cut -c -2 | rev);
        vol_name="${prefix}volume_personal_${surname}.$initials";
        node=$(echo $ps_line|cut -d ' ' -f 14);
        if [ $node == $HOSTNAME ];
        then
            echo "$vol_name is on the current host";
            echo "docker volume rm $vol_name";
            docker volume rm -f $vol_name && echo "$vol_name was removed";
        else
            #ssh connection to the host with volume
            echo "ssh $ssh_user@$node";
            ssh $ssh_user@$node "docker volume rm -f $vol_name" && echo "$vol_name was removed";
        fi;
    fi;
    # need </dev/null to protect stdin for serv_name
    } < /dev/null
done
echo $(date +"%x %T") "Stop  of docker_cleaner"
echo "#########################################"
