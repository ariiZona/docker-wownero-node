#!/bin/bash

# Dynamically determine onion address to serve wownerod on tor network

hidden_service=(
    wownerod
    wownerod-rpc
)
for i in "${hidden_service[@]}"; do
    tries=0
    until [ -f /var/lib/tor/"${i}"/hostname ]; do
        if [ $tries -ge 5 ]; then
            echo "[+] Failed to generate ${i} onion address"
            exit 1
        fi
        tries=$((tries+1))
        echo -e "[${tries}] Waiting for ${i} onion address to be generated"
        sleep 1
    done
    onion=$(cat "/var/lib/tor/${i}/hostname")
    echo -e "[+] Generated /var/lib/tor/${i}/hostname\n${onion}\n"
done

export ONION_ADDRESS=$(cat /var/lib/tor/wownerod-rpc/hostname)
export P2P_ONION_ADDRESS=$(cat /var/lib/tor/wownerod/hostname)

echo "=========================================="
echo "Your Wownero RPC Onion address is: ${ONION_ADDRESS}"
echo "=========================================="

sleep 3

wownerod \
    --data-dir=/data \
    --p2p-bind-ip=0.0.0.0 \
    --p2p-bind-port=34567 \
    --rpc-restricted-bind-ip=0.0.0.0 \
    --rpc-restricted-bind-port=34568 \
    --zmq-rpc-bind-ip=0.0.0.0 \
    --zmq-rpc-bind-port=34569 \
    --rpc-bind-ip=0.0.0.0 \
    --rpc-bind-port=34570 \
    --non-interactive \
    --confirm-external-bind \
    --public-node \
    --log-level=0 \
    --rpc-ssl=disabled \
    --ban-list=/ban_list.txt \
    --anonymous-inbound=${P2P_ONION_ADDRESS}:34571,0.0.0.0:34571,24 \
    --tx-proxy=tor,172.31.255.250:9050,disable_noise,24 \
    --tx-proxy=i2p,172.31.255.251:4447,disable_noise,24
