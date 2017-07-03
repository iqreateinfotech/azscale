#!/bin/bash

buildfiles="/home/muthu/testproject/workcicd"
cd $buildfiles
cat azuredeploy.parameters.json
azure login -u https://login.microsoftonline.com/%0D/oauth2/token?api-version=1.0 --service-principal --tenant 8a729d75-ff0f-4b29-86a7-10e08dd838ee -p UniQreate0743
azure group deployment create -f azuredeploy.json -e azuredeploy.parameters.json  -g pep-vmss-autoscale-rg -n pepdashdeploy 'S3cureP@55123456'
