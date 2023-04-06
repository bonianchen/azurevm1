#!/bin/sh

SPOT_NAME=`grep ^SPOT_NAME $1 | cut -d= -f2`
SPOT_RES=`grep ^SPOT_RES $1 | cut -d= -f2`
SPOT_LOC=`grep ^SPOT_LOC $1 | cut -d= -f2`
SPOT_KEY=`grep ^SPOT_KEY $1 | cut -d= -f2`
SPOT_TYPE=`grep ^SPOT_TYPE $1 | cut -d= -f2`

az group create --name ${SPOT_RES} --location ${SPOT_LOC}

SPOT_VNET=${SPOT_NAME}_net
SPOT_NSG=${SPOT_NAME}_net_nsg

az network vnet create --name ${SPOT_VNET} --resource-group ${SPOT_RES} --location ${SPOT_LOC} &
az network nsg create --name ${SPOT_NSG} --resource-group ${SPOT_RES} --location ${SPOT_LOC}

az network nsg rule create --name ${SPOT_NSG}_rule1 --resource-group ${SPOT_RES} --nsg-name ${SPOT_NSG} --priority 1000 --destination-address-prefixes '*' --destination-port 22 --access Allow --protocol Tcp &
az network nsg rule create --name ${SPOT_NSG}_rule2 --resource-group ${SPOT_RES} --nsg-name ${SPOT_NSG} --priority 1001 --destination-address-prefixes '*' --destination-port-ranges 60000-61000 --access Allow --protocol Udp &

#  --public-ip-sku Basic \
az vm create \
  --resource-group ${SPOT_RES} \
  --location ${SPOT_LOC} \
  --size ${SPOT_TYPE} \
  --name ${SPOT_NAME} \
  --image Debian:debian-11:11:latest \
  --vnet-name ${SPOT_VNET} \
  --public-ip-address "" \
  --nic-delete-option Delete \
  --nsg ${SPOT_NSG} \
  --admin-username azureuser \
  --priority Spot \
  --max-price 0.01 \
  --eviction-policy Deallocate \
  --ssh-key-name ${SPOT_KEY} 2>&1 > log_vm

# Wait for the VM to be created.
az vm wait --name ${SPOT_NAME} --state running

IDVM=`grep '"id"' log_vm | cut -d\" -f4`
echo "${SPOT_NAME} created: ${IDVM}"

IPAUTHKEY=`cat TAILSCALE.key`
az vm run-command invoke --ids ${IDVM} --command-id RunShellScript \
  --scripts "curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null; curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list >/dev/null; sudo apt-get update >/dev/null; sudo apt-get install -y tailscale mosh git >/dev/null; sudo tailscale up --authkey ${IPAUTHKEY} >/dev/null"
