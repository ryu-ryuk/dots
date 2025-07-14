#!/bin/bash

echo "[+] Starting WARP with IPv6 protection"
sudo wg-quick up wgcf-profile

# Block all IPv6 except via WARP
sudo ip6tables -P OUTPUT DROP
sudo ip6tables -A OUTPUT -o wgcf -j ACCEPT
echo "[+] WARP is active with IPv6 locked down"

