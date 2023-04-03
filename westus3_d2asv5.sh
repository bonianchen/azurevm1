#!/bin/sh

SPOT_NAME=202303vm
SPOT_RES=202303vm_wus3_res_group
SPOT_LOC=westus3
SPOT_KEY=202303vm_sshkey

az group create --name ${SPOT_RES} --location ${SPOT_LOC}

SPOT_VNET=${SPOT_NAME}_net
SPOT_NSG=${SPOT_NAME}_net_nsg

az network vnet create --name ${SPOT_VNET} --resource-group ${SPOT_RES} --location ${SPOT_LOC} &
az network nsg create --name ${SPOT_NSG} --resource-group ${SPOT_RES} --location ${SPOT_LOC}

az network nsg rule create --name ${SPOT_NSG}_rule1 --resource-group ${SPOT_RES} --nsg-name ${SPOT_NSG} --priority 1000 --destination-address-prefixes '*' --destination-port 22 --access Allow --protocol Tcp
az network nsg rule create --name ${SPOT_NSG}_rule2 --resource-group ${SPOT_RES} --nsg-name ${SPOT_NSG} --priority 1001 --destination-address-prefixes '*' --destination-port-ranges 60000-61000 --access Allow --protocol Udp &

#  --public-ip-sku Basic \
az vm create \
  --resource-group ${SPOT_RES} \
  --location ${SPOT_LOC} \
  --size Standard_D2as_v5 \
  --name ${SPOT_NAME} \
  --image Debian:debian-11:11:latest \
  --vnet-name ${SPOT_VNET} \
  --public-ip-address "" \
  --nsg ${SPOT_NSG} \
  --admin-username azureuser \
  --priority Spot \
  --eviction-policy Deallocate \
  --ssh-key-name ${SPOT_KEY} &> log_D2as_v5

az vm create \
  --resource-group ${SPOT_RES} \
  --location ${SPOT_LOC} \
  --size Standard_A1_v2 \
  --name ${SPOT_NAME}_boot \
  --subnet ${SPOT_NAME}Subnet \
  --image Debian:debian-11:11:latest \
  --vnet-name ${SPOT_VNET} \
  --public-ip-sku Basic \
  --nsg ${SPOT_NSG} \
  --admin-username azureuser \
  --priority Spot \
  --eviction-policy Deallocate \
  --ssh-key-name ${SPOT_KEY} &> log_A1_v2

IPD2=`grep privateIp log_D2as_v5 | cut -d\" -f4`
IPA1=`grep publicIp log_A1_v2 | cut -d\" -f4`

scp -o StrictHostKeyChecking=accept-new -i CRED.pem CRED.pem azureuser@${IPA1}:/home/azureuser
scp -i CRED.pem azurevm1/westus3_provision.sh azureuser@${IPA1}:/home/azureuser
ssh -i CRED.pem azureuser@${IPA1} "scp -o StrictHostKeyChecking=accept-new -i CRED.pem westus3_provision.sh azureuser@${IPD2}:/home/azureuser; ssh -i CRED.pem azureuser@${IPD2} 'source westus3_provision.sh'"
