# VxRailChallenge

Steps
------
Option #1:  User use keyboard monitor to login any of the nodes, and input available IP
------
* when system boot up , auto run the script ```sudo ./SetIP_VxRail.sh &``` in background
* waiting a while, ensure all nodes runs (recommended boot up + script run + 20s )
* customer goes into any of the node via KVM, run ```./User_Input_IP.sh```, key in the IPs one by one, after prompt.then hit ``CTRL+D``` to complete the key in.
* the node who customer goes to, will set IP from the pool
* the other nodes will select IP from the pool later

------
Option #2: If 169.254.0.0/16 is safe in end-user enviroment
------
* when system boot up , auto run the script ```sudo ./SetIP_VxRail2.sh ``` 
* the nodes will select IP from the pool , among the IP ranges




