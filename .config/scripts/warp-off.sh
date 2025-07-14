#!/bin/bash

echo "[+] Stopping WARP and restoring IPv6"
sudo wg-quick down wgcf-profile

# Flush IPv6 firewall rules and accept all again
sudo ip6tables -F
sudo ip6tables -P OUTPUT ACCEPT
echo "[+] WARP disabled and IPv6 restored"

