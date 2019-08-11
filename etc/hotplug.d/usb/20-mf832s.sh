#!/bin/sh

MF832S_PRODUCT="19d2/199/100"
MODEM=/dev/ttyUSB0
NETIF=network.interface.mf832s

[ "$PRODUCT" = "$MF832S_PRODUCT" ] && [ "${DEVICENAME##*.}" = "4" ] || exit

[ "$ACTION" = "remove" ] &&\
    { logger -t hotplug "MF832S: detach" &&\
    sleep 3 &&\
    ubus call $NETIF status | grep available | grep false &&\
    logger -t hotplug "MF832S: $NETIF down" &&\
    ubus call $NETIF down ||\
    exit ; }

[ "$ACTION" = "add" ] &&\
    { logger -t hotplug "MF832S: attach" &&\
    [ -c $MODEM ] &&\
        { logger -t hotplug "MF832S: test" &&\
        chat -f /etc/chatscripts/mf832s-online-test.chat <$MODEM >$MODEM &&\
        logger -t hotplug "MF832S: online" ; } ||\
        { logger -t hotplug "MF832S: offline" &&\
        logger -t hotplug "MF832S: $MODEM chat" &&\
        chat -f /etc/chatscripts/mf832s.chat <$MODEM >$MODEM &&\
        logger -t hotplug "MF832S: $MODEM chat success" &&\
        ubus call $NETIF status | grep available | grep true &&\
        logger -t hotplug "MF832S: $NETIF up" &&\
        ubus call $NETIF up ; } ||\
        logger -t hotplug "MF832S: $MODEM chat fail" ||\
    exit ; }
ifconfig eth1 up
sleep 20s
udhcpc -i eth1
