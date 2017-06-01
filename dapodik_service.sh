#!/bin/bash

# put the code in as /etc/init.d/run_update_dapodik
# run with
# $ service run_update_dapodik start
# and to stop with:
# $ service run_update_dapodik stop

case "$1" in
    start)
        /home/mantra/zmisc/run_update_dapodik.sh &
        echo $!>/var/run/update_dapodik.pid
        ;;

    stop)
        kill `cat /var/run/update_dapodik.pid`
        rm /var/run/update_dapodik.pid
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    status)
        if [ -e /var/run/update_dapodik ]; then
            echo run_update_dapodik.sh is running, \
                pid=`cat /var/run/update_dapodik.pid`
        else
            echo run_update_dapodik.sh is NOT running
            exit 1
        fi
        ;;
    *)
        echo "Usage: `$0` {start|stop|status|restart}"
esac

exit 0
