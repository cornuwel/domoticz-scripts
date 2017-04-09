#!/bin/bash

LOGFILE=/var/tmp/minerControl.log
USER=julien
LEVEL=$1
IP=$2
MAC=$3
WORKER=$4
MINER=/home/julien/eqm_v1.0.4c_Linux_Ubuntu16/eqm_ubuntu_16
GPUS=$(/usr/bin/seq -s ' ' 0 $(($LEVEL - 1)))
BTCADDR="1PqJhJZDvwXtRdgAxMwFUse6j3imjXqBgo"


# Shutdown the host
if [ "$LEVEL" == "0" ]
then
	echo "$(/bin/date "+%F %T") Shutdown $WORKER" >> $LOGFILE
	ssh $USER@$IP 'sudo /sbin/shutdown -h now'
	exit 0
fi

# Wake up the host if necessary
if ! /usr/bin/ssh -q -o "ConnectTimeout=3" $USER@$IP exit
then
	echo "$(/bin/date "+%F %T") Wake on LAN for $WORKER" >> $LOGFILE
	/usr/bin/wakeonlan $MAC

	while ! /usr/bin/ssh -q -o "ConnectTimeout=3" $USER@$IP exit
	do
		echo "$(/bin/date "+%F %T") Waiting for $WORKER" >> $LOGFILE
		sleep 5
	done
	echo "$(/bin/date "+%F %T") $WORKER is responding to SSH" >> $LOGFILE
	sleep 10
fi

# Kill the old miner
echo "$(/bin/date "+%F %T") Killing the old miner on $WORKER" >> $LOGFILE
ssh $USER@$IP '/usr/bin/pkill -9 -f eqm_ubuntu_16'
sleep 2

while true
do
	# Start the miner with new params
	CMD="$MINER -t 0 -l eu -u $BTCADDR -w $WORKER -cd $GPUS"
	
	echo "$(/bin/date "+%F %T") Starting miner: $CMD" >> $LOGFILE
	ssh $USER@$IP "/usr/bin/screen -wipe"
	ssh $USER@$IP "/usr/bin/screen -S miner -d -m $CMD"
	sleep 5

	if /usr/bin/ssh $USER@$IP "/usr/bin/nvidia-smi | /bin/grep eqm_ubuntu_16" &>/dev/null
	then
		echo "$(/bin/date "+%F %T") Miner running on $WORKER" >> $LOGFILE
		exit 0
	else
		echo "$(/bin/date "+%F %T") Miner not running on $WORKER" >> $LOGFILE
		ssh $USER@$IP '/usr/bin/pkill -9 -f eqm_ubuntu_16'
		sleep 2
	fi
done
