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

# Install helpful packages
apt-get install yq -y

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
docker plugin install grafana/loki-docker-driver:2.9.2 --alias loki --grant-all-permissions
echo '{
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "http://localhost:3100/api/v1/push",
    "loki-retries": "5",
    "loki-batch-size": "400"
  }
}' > /etc/docker/daemon.json


# Create directories for services
mkdir /data
mkdir /data/pr2-mysql-data
mkdir /data/grafana-data
mkdir /data/loki-data
mkdir /data/prometheus-data
mkdir /data/tempo-data
mkdir /data/pr4-dev-kratos
mkdir /backups/pr2-mysql-backups
chown -R fred-bot:fred-bot /backups

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

# Set up cron job to run sync.sh every 10 minutes
echo "Setting up cron job..."
(crontab -l 2>/dev/null; echo "*/10 * * * * /home/fred-bot/server-config/mend-hub/scripts/sync.sh"; \
echo "@reboot /home/fred-bot/server-config/mend-hub/scripts/sync.sh"; \
echo "5 4 * * * /home/fred-bot/server-config/mend-hub/pr2/backup.sh"; \
echo "* * * * * docker exec pr2-http php /pr2/common/cron/minute.php"; \
echo "9 * * * * docker exec pr2-http php /pr2/common/cron/hourly.php"; \
echo "10 5 * * * docker exec pr2-http php /pr2/common/cron/daily.php"; \
echo "11 6 * * 1 docker exec pr2-http php /pr2/common/cron/weekly.php"; \
echo "12 * * * * docker exec pr2-http php /pr2/common/cron/update-s3-version.php") | crontab -
EOF

# Set up a root cron job to restart the VM once per month
echo "Setting up monthly VM restart cron job..."
(crontab -l 2>/dev/null; echo "0 0 1 * * /sbin/reboot") | crontab -

# Done!
echo "Setup complete!"
echo "Note that dev.secrets.yaml and prod.secrets.yaml need to be created."
