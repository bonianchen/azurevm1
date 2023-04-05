# Create VM on Microsoft Azure

Step1: Get into [Azure Cloud Shell](https://shell.azure.com)

       https://shell.azure.com

Step2: Have tailscale key (TAILSCALE.key) in Cloud Shell

Step3: Download project from github

       git clone https://github.com/bonianchen/azurevm1

Step4: Run createvm.sh

       source azurevm1/createvm.sh westus3_d2asv5.config

Step5: Check the IP address allocated by TailScale, and connect to it. (SSH or mosh)

# Shutdown

Step1: Delete resource

       source azurevm1/deletevm.sh
