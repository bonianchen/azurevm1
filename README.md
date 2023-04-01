# Create VM on Microsoft Azure

Step1: Get into Azure Cloud Shell

       https://shell.azure.com

Step2: Have SSH credential file (CRED.pem) in Cloud Shell

Step3: Download westus3_d2asv5.sh from github

       git clone https://github.com/bonianchen/azurevm1

Step4: Run westus3_d2asv5.sh

       source azurevm1/westus3_d2asv5.sh


       2 VM will be created:
           D2as_v5 with private IP
           A1_v2 with both private IP and public IP

Step5: Click url appeared after step 4, and login.

Step6: Delete resource names containing "boot" keyword (terminate A1_v2)

       source azurevm1/westus3_deleteboot.sh

Step7: Connect to D2as_v5 through IP provided by tailscale.

# Shutdown

Step1: Delete resource

       source azurevm1/westus3_delete.sh
