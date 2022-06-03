#!/bin/bash

# Create the index maintainance script
cat >/home/ec2-user/deleteindex.sh <<'EOT'
index=cwl-`date --date='1 week ago' '+%Y.%m.%d'`
echo $index
curl -XDELETE "https://prod-elasticsearch.sptlfe-dev.com/$index"
EOT


# Add DNA team keys to ec2-user
cat >> /home/ec2-user/.ssh/authorized_keys <<EOL
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdQnkd7T4YFAyZ622SGNBI8u/pdEdPtSr/LE5lNaaO21Xivp5GbCd40+oFWybIoeFyyx5jtsjI42lGEv5P/2wFZnMA+UtxpyjX57xfBwbGK5x4qrsU5XxwxPqbvT1CWbw8Psmjn1w7xSxDJ6iAOQMgb6K4fYq2XvNhKh8nL+eMGHELsK6MMjVfEW4noUrWRURowGqlecuSOCIgAzJZqYY0RmOADh7ZINRi6433llMfG+Nj727XOw09f8XzvIrXCq3Y5DTvZQ1RFvbbx49tYz/mAHBLL5IH+VRVPvaKieNqYzVhVVfjZA3/IZnQcmEMvXRPjTYGm+r+juZQGYw8LDPPxtWYaAoOXyietXce03DMhRN3K3iRsT8eWfRI437Xcmqrdkevgla2q1tjp0zFSoXItg5kopL2SDx1pjVlDzOGQiCO1DIZBHOIFiANoDRSf03gxGUvPo2/1+JqQly6dEfyUjp4zKyYZcWoqx4BPPlUZ4JUkIMWUiu8aP8zrBvcrXMgLBXE60eDCNlO26FIjzdX85NW6aeEim59DpgnMnpSdd8xbJ2D7KSvj1BRcWO47EjYeA+cx4ToG1V2N4Fmnh5//Q1ArQH9uKezDhnhrIlT5WEv0Q1F1S2/KHpgSNrBlGb5c2hwg88+ZLP3fnJ6Yay13VwSOhLP/8p0twQ25dh60w== antonio.quintana@nagra.com
EOL