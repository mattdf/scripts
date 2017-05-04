#!/bin/bash

xrandr -q | grep -q "HDMI-1 connected"
CONNECTED=$?

if [ $? -eq 0 ]; then
	xrandr --output HDMI-1 --above eDP-1 --auto
else
	xrandr --output HDMI-1 --off
fi
