# Virtual-ECN-ns2-
Virtual ECN Prediction Based on ns2 traces

In Dumbbell.tcl, a newtork topology was build up as followed:
All senders are running the same TCP congestion control protocol (New Reno or Cubic). The nqueue1 is running RED queue, nqueue2 is running DropTail. The RTT in in range of (10ms~100ms).

#####Build a dumbbell model with N senders and N receivers communicating
#####through two connected routers

####### s0                                                  r1
#######   \                                                 /
####### s1\\ lineRate RTT1                    lineRate RTT3//r2
####### .  \\        bottleNeckLinkDataRate  RTT2         //  .
####### . -/ nqueue1-------------------------------nqueue2 ---.
####### . /   (RED)                             (DropTail) \
####### sN                                                 rN

In Dumbbell_UDP.tcl, the same newtork topology was build up as above with one difference:
Out of the 10 users, there is one running UDP.

Traces are collected through ns2 for the above two set up. For each received ACK, exponential weighted moving average of interarrival ACK time and the indicated sending time in the ACK package are calculated. 

Based on those data, a machine learing algorithm is designed to predict Virtual_ECN.
