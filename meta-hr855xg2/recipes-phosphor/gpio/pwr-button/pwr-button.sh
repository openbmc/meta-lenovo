#!/bin/sh

# "Copyright (c) 2019-present Lenovo
# Licensed under BSD-3, see COPYING.BSD file for details."

# Add SEL
busctl call --no-page xyz.openbmc_project.Ipmi.Host /xyz/openbmc_project/Ipmi xyz.openbmc_project.Ipmi.Server execute yyyaya{sv} 0x0A 0 0x44 "16" "0" "0" "2" "0" "0" "0" "0" "32" "0" "4" "20" "242" "111" "0" "255" "255" "0"

# Get PWRGOOD state
last_state=`busctl get-property org.openbmc.control.Power /org/openbmc/control/power0 org.openbmc.control.Power pgood | awk '{print $2}'`

count=1
while :;
do
   curr_state=`busctl get-property org.openbmc.control.Power /org/openbmc/control/power0 org.openbmc.control.Power pgood | awk '{print $2}'`

   if [ $last_state != $curr_state ]; then
      break
   fi

   count=$(($count+1))
   if [ $count -eq 11 ]; then
      break
   fi
   sleep 1
done
state=$curr_state

# Sync Power State to state manager
if [ $state == "1" ]; then
   busctl set-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis CurrentPowerState s xyz.openbmc_project.State.Chassis.PowerState.On
else
   busctl set-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis CurrentPowerState s xyz.openbmc_project.State.Chassis.PowerState.Off
fi
