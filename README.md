# Create VM on Microsoft Azure

Step1: Get into [Azure Cloud Shell](https://shell.azure.com)

       https://shell.azure.com

Step2: Have SSH credential file (CRED.pem) in Cloud Shell

Step3: Download project from github

       git clone https://github.com/bonianchen/azurevm1

Step4: Run createvm.sh

       source azurevm1/createvm.sh westus3_d2asv5.config


       2 VM will be created:
           D2as_v5 with private IP
           A1_v2 with both private IP and public IP

Step5: Click url appeared after step 4, and login.

Step6: Delete resource names containing "boot" keyword (terminate A1_v2)

       source azurevm1/deleteboot.sh

Step7: Connect to D2as_v5 through IP provided by tailscale.

# Shutdown

Step1: Delete resource

       source azurevm1/deletevm.sh
