#!/bin/bash

cd ../../source/ArmoniK.Samples

export CPIP=$(kubectl get svc control-plane -n armonik -o custom-columns="IP:.status.loadBalancer.ingress[*].hostname" --no-headers=true)
export CPPort=$(kubectl get svc control-plane -n armonik -o custom-columns="PORT:.spec.ports[*].port" --no-headers=true)
export Grpc__Endpoint=http://$CPIP:$CPPort
export S3_BUCKET=$(aws s3api list-buckets | jq '.Buckets[0].Name')

cd Samples/SymphonyLike/
dotnet publish --self-contained -r linux-x64 SymphonyLike.sln

#scp -i ~/.ssh/cluster-key packages/ArmoniK.Samples.SymphonyPackage-v1.0.0.zip ec2-user@54.213.147.130:/data
aws s3 cp packages/ArmoniK.Samples.SymphonyPackage-v1.0.0.zip s3://$S3_BUCKET

cd ArmoniK.Samples.SymphonyClient/
dotnet bin/Debug/net5.0/linux-x64/ArmoniK.Samples.SymphonyClient.dll
