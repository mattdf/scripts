while true; do
	ping -w 20 -c 5 -W 2 8.8.8.8
	if [ $? -ne 0 ]; then
		killall -SIGHUP openvpn
	fi
	echo "Sleeping..."
	sleep 10
	if [ $? -ne 0 ]; then
		exit
	fi
	echo "Woke up"
done
