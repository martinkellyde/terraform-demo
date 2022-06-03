# Bastion Hosts Config
Provides access to secure instances via ssh. 
Ssh is routed via an ELB to provide extra security and resilience. 

## Need To Know
1. The access key is encrypted using the following KMS key: 
 * Bastion-Host-Access
 * 4f:58:8f:19:73:8c:24:7b:90:7b:01:84:92:49:22:e9:c2:8f:5c:6e
1. Only the following users have permission to access the KMS key:
 * Andrew Norman
 * Martin Kelly
 * Bernard Jauregui
1. The SaaS NAT service is only available in one AZ, so is a single 
point of failure.
1. Users pulled from IAM with with special characters will be mapped:
 * + => '.plus.'
 * = => '.equal.'
 * , => '.comma.'
 * @ => '.at.'

## Usage
1. Get the user to upload their ssh public key to their IAM account
1. Add the user to the correct IAM group
1. Wait 10 minutes for the account to be picked up and then connect

## Outstanding Questions
1. Should there be a dedicated security group to ensure that ssh is 
available, even if the public / private security groups are 
over-tightened?

## To Do
1. Write instructions for configuring ssh to relax certificate checking.
