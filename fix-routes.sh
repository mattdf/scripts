#!/bin/sh

echo "Adding default route to $route_vpn_gateway with /0 mask..."
/usr/sbin/ip route add default via $route_vpn_gateway

echo "Removing /1 routes..."
/usr/sbin/ip route del 0.0.0.0/1 via $route_vpn_gateway
/usr/sbin/ip route del 128.0.0.0/1 via $route_vpn_gateway

