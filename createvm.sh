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
  --nsg ${SPOT_NSG} \
  --admin-username azureuser \
  --priority Spot \
  --eviction-policy Deallocate \
  --ssh-key-name ${SPOT_KEY} &> log_vm

IPVM=`grep privateIp log_vm | cut -d\" -f4`
echo "${SPOT_NAME} created: ${IPVM}"

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

IPA1=`grep publicIp log_A1_v2 | cut -d\" -f4`

scp -o StrictHostKeyChecking=accept-new -i CRED.pem CRED.pem azureuser@${IPA1}:/home/azureuser
scp -i CRED.pem azurevm1/provisionvm.sh azureuser@${IPA1}:/home/azureuser
ssh -i CRED.pem azureuser@${IPA1} "scp -o StrictHostKeyChecking=accept-new -i CRED.pem provisionvm.sh azureuser@${IPVM}:/home/azureuser; ssh -i CRED.pem azureuser@${IPVM} 'source provisionvm.sh'"
