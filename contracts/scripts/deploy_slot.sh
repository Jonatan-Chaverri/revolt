#!/bin/bash

slot deployments delete revolt-test katana
slot deployments delete revolt-test torii

sleep 2
slot deployments create revolt-test katana -v v1.0.0-alpha.5 --disable-fee true --invoke-max-steps 4294967295 --seed 420 -a 10

echo "sozo -P release build && sozo -P release migrate plan && sozo -P release migrate apply"
sozo -P release build && sozo -P release migrate plan 
sozo -P release migrate apply

echo -e "\n✅ Setup finish!"

export world_address=$(cat ./manifests/release/deployment/manifest.json | jq -r '.world.address')

echo -e "\n✅ Init Torii!"
slot d create revolt-test torii --rpc https://api.cartridge.gg/x/revolt-test/katana --world $world_address -v v1.0.0-alpha.5 --start-block 0
