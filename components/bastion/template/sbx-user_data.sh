#!/bin/bash

# Install aws-ec2-ssh (https://github.com/widdix/aws-ec2-ssh)
wget -O /opt/authorized_keys_command.sh https://raw.githubusercontent.com/widdix/aws-ec2-ssh/master/authorized_keys_command.sh && \
	chmod +x /opt/authorized_keys_command.sh

wget -O /opt/import_users.sh https://raw.githubusercontent.com/widdix/aws-ec2-ssh/master/import_users.sh && \
	chmod +x /opt/import_users.sh

# Create aws-ec2-ssh config
cat <<EOF > /etc/aws-ec2-ssh.conf
IAM_AUTHORIZED_GROUPS="${environment}-${region}-iam-ssh-users"
LOCAL_MARKER_GROUP="iam-synced-users"
LOCAL_GROUPS=""
SUDOERS_GROUPS=""
ASSUMEROLE=""

# Remove or set to 0 if you are done with configuration
# To change the interval of the sync change the file
# /etc/cron.d/aws-ec2-ssh
DONOTSYNC=0
EOF

# Enable aws-ec2-ssh
sed -i 's:#AuthorizedKeysCommand none:AuthorizedKeysCommand /opt/authorized_keys_command.sh:g' /etc/ssh/sshd_config
sed -i 's:#AuthorizedKeysCommandUser nobody:AuthorizedKeysCommandUser nobody:g' /etc/ssh/sshd_config

# Create aws-ec2-ssh cron job to import users
echo "*/10 * * * * root /opt/import_users.sh" > /etc/cron.d/import_users && \
	chmod 0644 /etc/cron.d/import_users

service sshd restart
