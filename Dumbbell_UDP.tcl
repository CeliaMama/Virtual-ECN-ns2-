#####Build a dumbbell model with N senders and N receivers communicating
#####through two connected routers



set N 10
set bottleNeckLinkDataRate 1Gb
set lineRate 1Gb
set RTT1 0.04
set RTT2 0.02
set RTT3 0.01
set packetSize 1460
set routerBufferSize [expr round($RTT2 * 1000000000 / 8 /$packetSize)]   


set simulationTime 1.0
set startMeasurementTime 0.0
set stopMeasurementTime 100.0
set flowClassifyTime 0.04

set congestionControlAlg NewReno
#set congestionControlAlg Cubic

set switchQueueAlg RED

set traceSamplingInterval 0.0001
set enableNam 1
set ns [new Simulator]

Agent/TCP set ecn_ 1
Agent/TCP set packetSize_ $packetSize
Agent/TCP set window_ [expr $routerBufferSize + 10]


Queue set limit_ $routerBufferSize
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes true
Queue/RED set mean_pktsize_ $packetSize
Queue/RED set setbit_ true
Queue/RED set q_weight_ 1.0
Queue/RED set thresh_ [expr $routerBufferSize/2]
Queue/RED set maxthresh_ [expr $routerBufferSize]

DelayLink set avoidReordering_ true

if {$enableNam != 0} {

	set namfile [open outNewReno.nam w]
	$ns namtrace-all $namfile
}

set tf [open outNewReno.tr w]
$ns trace-all $tf


proc finish {} {
	global ns enableNam namfile tf
	$ns flush-trace
	close $tf
	if {$enableNam != 0} {
		close $namfile
		exec nam outNewReno.nam &
	}
	exit 0
}

$ns color 0 Red
$ns color 1 Orange
$ns color 2 Yellow
$ns color 3 Green
$ns color 4 Blue
$ns color 5 Violet
$ns color 6 Brown
$ns color 7 Black
$ns color 8 Purple
$ns color 9 SeaGreen



for {set i 0} {$i < $N} {incr i} {
	set s($i) [$ns node]
    set r($i) [$ns node]
}

set nqueue1 [$ns node]
set nqueue2 [$ns node]

set udpnode [$ns node]
set udprecnode [$ns node]

for {set i 0} {$i < $N} {incr i} {
	$ns duplex-link $s($i) $nqueue1 $lineRate [expr $RTT1/2] DropTail
	$ns duplex-link $r($i) $nqueue2 $lineRate [expr $RTT3/2] DropTail
}

$ns duplex-link $udpnode $nqueue1 $lineRate [expr $RTT1/2] DropTail
$ns duplex-link $nqueue2 $udprecnode $lineRate [expr $RTT1/2] DropTail

$ns simplex-link $nqueue1 $nqueue2 $bottleNeckLinkDataRate [expr $RTT2/2] $switchQueueAlg
$ns simplex-link $nqueue2 $nqueue1 $bottleNeckLinkDataRate [expr $RTT2/2] DropTail
$ns queue-limit $nqueue1 $nqueue2 $routerBufferSize

$ns duplex-link-op $nqueue1 $nqueue2 color "green"
$ns duplex-link-op $nqueue1 $nqueue2 queuePos 0.25
#set qfile [$ns monitor-queue $nqueue1 $nqueue2 [open queue.tr w] $traceSamplingInterval]


####Create Error Model
set off [new ErrorModel/Uniform 0 pkt]
set on [new ErrorModel/Uniform 1 pkt] 

set m_states [list $off $on]
# Durations for each of the states, tmp, tmp1 and tmp2, respectively 
#set m_periods [list 0.2 0.1 0.05]
set m_periods [list 4 0.01]
# Transition state model matrix
#set m_transmx { {0 1 0}
#{0 0 1}
#{1 0 0}}
set m_transmx { 
	{0 1}
    {1 0}
}
set m_trunit pkt
# Use time-based transition
set m_sttype time
set m_nstates 2
set m_nstart [lindex $m_states 0]
set em [new ErrorModel/MultiState $m_states $m_periods $m_transmx $m_trunit $m_sttype $m_nstates $m_nstart]


#$ns link-lossmodel $em $nqueue1 $nqueue2

for {set i 0} {$i < $N} {incr i} {
	if {[string compare $congestionControlAlg "NewReno"] == 0} {
		set tcp($i) [new Agent/TCP/Newreno]
		set sink($i) [new Agent/TCPSink]
	}
	if {[string compare $congestionControlAlg "Cubic"] == 0} {
		set tcp($i) [new Agent/TCP/Linux]
		$tcp($i) set timestamps_ true
		$ns at 0 "$tcp($i) select_ca cubic"
		set sink($i) [new Agent/TCPSink]
	}
	$ns attach-agent $s($i) $tcp($i)
	$ns attach-agent $r($i) $sink($i)

	$tcp($i) set fid_ [expr $i]
	$sink($i) set fid_ [expr $i]

	$ns connect $tcp($i) $sink($i)
}






for {set i 0} {$i < $N} {incr i} {
	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tcp($i)
	$ns at 0.0 "$ftp($i) start"
	$ns at [expr $simulationTime] "$ftp($i) stop"
}


set udp [new Agent/UDP]
$ns attach-agent $udpnode $udp
set null [new Agent/Null]
$ns attach-agent $udprecnode $null
$ns connect $udp $null
$udp set fid_ $N+1


set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 3000
$cbr set rate_ 1Gb
$cbr set random_ false
$cbr set maxpkts_ 1

$ns at 0.0 "$cbr start"
$ns at [expr $simulationTime] "$cbr stop"


$ns at $simulationTime "finish"
$ns run
