#!/bin/sh

SPOT_RES=202303vm_wus3_res_group
SPOT_LOC=westus3

az group create --name ${SPOT_RES} --location ${SPOT_LOC}

SPOT_VNET=202303vm_net
SPOT_NSG=202303vm_net_nsg

az network vnet create --name ${SPOT_VNET} --resource-group ${SPOT_RES} --location ${SPOT_LOC}
az network nsg create --name ${SPOT_NSG} --resource-group ${SPOT_RES} --location ${SPOT_LOC}

az network nsg rule create --name ${SPOT_NSG}_rule1 --resource-group ${SPOT_RES} --nsg-name ${SPOT_NSG} --priority 1000 --destination-address-prefixes '*' --destination-port 22 --access Allow --protocol Tcp
az network nsg rule create --name ${SPOT_NSG}_rule2 --resource-group ${SPOT_RES} --nsg-name ${SPOT_NSG} --priority 1001 --destination-address-prefixes '*' --destination-port-ranges 60000-61000 --access Allow --protocol Udp

#  --public-ip-sku Basic \
az vm create \
  --resource-group ${SPOT_RES} \
  --location ${SPOT_LOC} \
  --size Standard_D2ds_v5 \
  --name 202303vm \
  --image Debian:debian-11:11:latest \
  --vnet-name ${SPOT_VNET} \
  --public-ip-address "" \
  --nsg ${SPOT_NSG} \
  --admin-username azureuser \
  --priority Spot \
  --eviction-policy Deallocate \
  --ssh-key-name 202303vm_sshkey

az vm create \
  --resource-group ${SPOT_RES} \
  --location ${SPOT_LOC} \
  --size Standard_A1_v2 \
  --name 202303vm_boot \
  --subnet 202303vmSubnet \
  --image Debian:debian-11:11:latest \
  --os-disk-size-gb 8 \
  --vnet-name ${SPOT_VNET} \
  --public-ip-sku Basic \
  --nsg ${SPOT_NSG} \
  --admin-username azureuser \
  --priority Spot \
  --eviction-policy Deallocate \
  --ssh-key-name 202303vm_sshkey
