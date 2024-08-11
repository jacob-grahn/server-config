#!/bin/bash

set -e # Exit script if a command errors

# Set up a backup directory that stores files on a remote bucket
if [ ! -f "${HOME}/.passwd-s3fs" ]; then
  read -p 'Bucket Name: (example: mend-hub-backups): ' bucket_name
  read -p 'Bucket URL (example: s3.us-west-000.backblazeb2.com): ' bucket_url
  read -p 'Bucket Key: ' bucket_key
  read -sp 'Bucket Secret: ' bucket_secret
  echo $bucket_key:$bucket_secret > ${HOME}/.passwd-s3fs
  chmod 600 ${HOME}/.passwd-s3fs
  apt-get install s3fs -y
  mkdir /backups
  s3fs $bucket_name /backups -o use_path_request_style -o url=https://$bucket_url/
  echo "$bucket_name /backups fuse.s3fs _netdev,allow_other,use_path_request_style,url=https://$bucket_url/ 0 0" >> /etc/fstab
fi

# Update and upgrade the system packages
echo "Updating system packages..."
apt-get update && apt-get upgrade -y

# Install unattended-upgrades for automatic package updates
echo "Installing unattended-upgrades for automatic system updates..."
apt-get install -y unattended-upgrades
dpkg-reconfigure -pmedium unattended-upgrades

# Add Docker's official GPG key:
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y

# Install docker
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Create directories for services
mkdir /data/pr2-db-data
mkdir /backups/pr2-db-backups

# Create a non-root user 'fred-bot'
echo "Creating user 'fred-bot'..."
useradd -m -s /bin/bash fred-bot

# Add 'fred-bot' to the docker group to allow running docker without sudo
echo "Adding 'fred-bot' to the docker group..."
usermod -aG docker fred-bot

# Switch to user 'fred-bot' and set up environment
echo "Setting up environment for 'fred-bot'..."
sudo -i -u fred-bot bash << EOF
# Clone the specified git repository using HTTPS
echo "Cloning repository..."
git clone https://github.com/jacob-grahn/server-config.git ~/server-config

# Set up cron job to run sync-from-repo.sh every 10 minutes
echo "Setting up cron job..."
(crontab -l 2>/dev/null; echo "*/10 * * * * /home/fred-bot/server-config/scripts/sync-from-repo.sh") | crontab -
(crontab -l 2>/dev/null; echo "@reboot /home/fred-bot/server-config/scripts/sync-from-repo.sh") | crontab -
EOF

# Set up a root cron job to restart the VM once per month
echo "Setting up monthly VM restart cron job..."
(crontab -l 2>/dev/null; echo "0 0 1 * * /sbin/reboot") | crontab -

# Done!
echo "Setup complete!"
echo "Note that dev.secrets.yaml and prod.secrets.yaml need to be created."
