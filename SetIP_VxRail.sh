#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

rm /tmp/mac_list.txt
rm /tmp/mac_list_ordered.txt
rm /tmp/IP_Pool_Input.txt

NIC=eth1

VXRAIL_FLAG="VxRail Node."

sudo service lldpd stop 
sudo pkill lldpd 
sudo lldpd -d -I $NIC -S $VXRAIL_FLAG &
echo "[Info] waiting lldpd to working. please wait 20 sec"
sleep 20
echo "[Info]sleep done. "

#if [ ! $(type "lldpd" > /dev/null) ] #|| [ ! type "lldpcli" > /dev/null ];
if [ "$(which lldpd)" == "" ] || [ "$(which lldpcli)" == "" ]
then
    echo "[Error]: please pre-install lldpd in VxRail nodes. aborting"
    exit 1
fi


PREFIX=$VXRAIL_FLAG"User Define IP Pool:"

#############################
#  Assuming the node already obtinaed IP pool, will set its desc to $PREFIX IP1|IP2|IP3....
#############################
while true; do


    # this /tmp/IP_Pool_Input.txt comes from User Input
    if [ -f /tmp/IP_Pool_Input.txt ]
    then
        IP_LIST=$(cat /tmp/IP_Pool_Input.txt)
        echo "[Info]Detect Customer Input of IP Pools."
        IPs=$(echo $IP_LIST| tr "|" "\n")
        break;
    fi

    DESC=$(lldpcli  show neighbors | grep "$PREFIX" )
    # Get VxRail IP List
    IP_LIST=${DESC#* $PREFIX}
    if [  "$(echo $IP_LIST)" != ""  ] 
    then
        echo IP_LIST= $IP_LIST
        echo "[Info]Another VxRail node obtains IP pool input.Start to grab IP from it...."
        break;
    fi

    sleep 3

done



# split
IPs=$(echo $IP_LIST| tr "|" "\n") 

IP_COUNT=${#IPs[@]}
#sort
IPs_sorted=$(for l in ${IPs[@]}; do echo $l; done | sort)


#######################################################
#
# Assume all VxRail nodes are up and running to here.
#
######################################################
# get all vXrail MAC List
lldpcli  show neighbors |grep VxRail -B2|grep ChassisID |awk '{print $NF}' > /tmp/mac_list.txt
# get all vXrail IP List
lldpcli  show neighbors |grep VxRail -A1|grep MgmtIP |awk '{print $NF}' > /tmp/used_ip_list.txt

# restart service
if [ -f /tmp/IP_Pool_Input.txt ]
then
    sudo pkill lldpd
    sleep 1
    echo "[Info] Restart lldpd agent, carry the IP pool info."
    sudo nohup  lldpd -d -I $NIC -S "${PREFIX} ${IP_LIST}" &
fi





# get local MAC, assuming $NIC
MY_MAC=$( ifconfig $NIC      |grep HWaddr|awk '{print $NF}' )



MAC_COUNT=$(wc -l /tmp/mac_list.txt | awk '{print $1}' )


#http://unix.stackexchange.com/questions/242251/count-number-of-elements-in-bash-array-where-the-name-of-the-array-is-dynamic

if [ "${MAC_COUNT}" -gt "$IP_COUNT" ]
then
    echo "[Warning]: User Input IP Pool is Not enough! aborting"
fi


# sort MAC
echo $MY_MAC >> /tmp/mac_list.txt
sort /tmp/mac_list.txt > /tmp/mac_list_ordered.txt



# Get rank
RANK=$( grep -n $MY_MAC /tmp/mac_list_ordered.txt |awk -F ":" '{print $1}')

echo "RANK="$RANK

# local IP to be configued ======== WTF, this line doesn't work in bash ??!!
#MY_IP=${IPs_sorted[$RANK-1]}

cnt=1
for l in ${IPs_sorted[@]};
do
    if [ "$cnt" -gt "$RANK" ];
    then
        if [ "$(grep $l /tmp/used_ip_list.txt)" == "" ];
        then
              MY_IP=$l
              break
        fi
    fi
    let "cnt=cnt+1"
done 

if [ "$MY_IP"  == "" ]
then
    echo "[Error]: Not IP avaiable for this node :-(  . exit "
    exit -1
fi
echo "My IP Should be : $MY_IP ( run : sudo ifconfig $NIC $MY_IP  )"

# ifconfig $NIC $MY_IP
