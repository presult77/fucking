#!/bin/bash
pid=$(pidof badvpn-udpgw)
sudo cpulimit --pid $pid --limit 15 --background