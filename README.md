# VxRailChallenge

Steps
------

* when system boot up , auto run the script ```sudo ./SetIP_VxRail.sh &``` in background
* waiting a while, ensure all nodes runs (recommended boot up + script run + 20s )
* customer goes into any of the node via KVM, run ```./User_Input_IP.sh```, key in the IPs one by one, after prompt.then hit ``CTRL+D``` to complete the key in.
* the node who customer goes to, will set IP from the pool
* the other nodes will select IP from the pool later

