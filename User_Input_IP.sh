#!/bin/bash

NIC=eth1

lldpcli  show neighbors |grep VxRail -B2|grep ChassisID |awk '{print $NF}' > /tmp/mac_list_others.txt

MY_MAC=$( ifconfig $NIC      |grep HWaddr|awk '{print $NF}' )

echo $MY_MAC >> /tmp/mac_list_others.txt

COUNT=$(wc -l /tmp/mac_list_others.txt| awk '{print $1}')

echo "there are $COUNT VxRail nodes detected(including this one), please key in the IP for all of them.(hit ctrl+D to stop)"

while read line
do
        my_array=("${my_array[@]}" $line)
done

echo ${my_array[@]}

rm /tmp/tttt.txt -f

for i in ${my_array[@]};
do
    echo $i >> /tmp/tttt.txt
done

mv /tmp/tttt.txt /tmp/IP_Pool_Input.txt

echo "Done, the IP list is in /tmp/IP_Pool_Input.txt"



