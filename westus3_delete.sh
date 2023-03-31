#!/bin/sh

SPOT_RES=202303vm_res_group

az disk delete --resource-group ${SPOT_RES} --name `az disk list --resource-group ${SPOT_RES} | grep '"name"' | head -1 | cut -d\" -f4` -y
