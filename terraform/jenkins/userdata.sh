#!/bin/bash
set -e

#################################
# System update
#################################
apt update -y
apt upgrade -y

#################################
# Base dependencies
#################################
apt install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  unzip \
  software-properties-common \
  fontconfig

#################################
# Install Docker (for CI builds)
#################################
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

#################################
# Install Java 21 (Required for Jenkins & SonarQube)
#################################
apt install -y openjdk-21-jre
java -version

#################################
# Install Jenkins (LATEST METHOD)
#################################
mkdir -p /etc/apt/keyrings

wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian binary/" \
| tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update -y
apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins

#################################
# Kernel tuning for SonarQube (PERSISTENT)
#################################
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072

grep -q "vm.max_map_count" /etc/sysctl.conf || echo "vm.max_map_count=524288" >> /etc/sysctl.conf
grep -q "fs.file-max" /etc/sysctl.conf || echo "fs.file-max=131072" >> /etc/sysctl.conf

#################################
# Install SonarQube (HOST BASED)
#################################
useradd sonar || true

cd /opt
rm -rf sonarqube*

SONAR_VERSION=10.4.1.88267
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip
unzip sonarqube-${SONAR_VERSION}.zip
mv sonarqube-${SONAR_VERSION} sonarqube

chown -R sonar:sonar /opt/sonarqube
chmod +x /opt/sonarqube/bin/linux-x86-64/sonar.sh

#################################
# SonarQube systemd service
#################################
cat <<EOF >/etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking
User=sonar
Group=sonar
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl daemon-reexec
systemctl enable sonarqube
systemctl start sonarqube

#################################
# Install Trivy (ON HOST)
#################################
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin

#################################
# Info
#################################
echo "Jenkins running on port 8080"
echo "SonarQube running on port 9000"
echo "Docker & Trivy installed"