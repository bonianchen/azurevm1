#!/bin/sh

SPOT_RES=202303vm_wus3_res_group

az vm delete --resource-group ${SPOT_RES} --name `az vm list --resource-group ${SPOT_RES} | grep '"name"' | head -1 | cut -d\" -f4` -y
az disk delete --resource-group ${SPOT_RES} --name `az disk list --resource-group ${SPOT_RES} | grep '"name"' | head -1 | cut -d\" -f4` -y
az network nic delete --resource-group ${SPOT_RES} --name `az network nic list --resource-group ${SPOT_RES} | grep '"name"' | tail -1 | cut -d\" -f4`
