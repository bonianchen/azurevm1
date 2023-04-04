#!/bin/sh

SPOT_RES=`grep '"resourceGroup"' log_A1_v2 | cut -d\" -f4`

az vm delete --resource-group ${SPOT_RES} --name `az vm list --resource-group ${SPOT_RES} | grep boot | grep '"name"' | head -1 | cut -d\" -f4` -y
az disk delete --resource-group ${SPOT_RES} --name `az disk list --resource-group ${SPOT_RES} | grep boot | grep '"name"' | head -1 | cut -d\" -f4` -y
az network nic delete --resource-group ${SPOT_RES} --name `az network nic list --resource-group ${SPOT_RES} | grep boot | grep '"name"' | tail -1 | cut -d\" -f4`
az network public-ip delete --resource-group ${SPOT_RES} --name `az network public-ip list --resource-group ${SPOT_RES} | grep '"name"' | head -1 | cut -d\" -f4`
