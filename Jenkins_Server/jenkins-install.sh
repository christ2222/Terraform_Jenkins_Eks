#!/bin/bash
# Complete Jenkins Installation Script for Amazon Linux 2
# Includes Java 17, Jenkins, Terraform, Git, and kubectl

# Set debug mode (logs all commands)
set -x

# Update system and install basic tools
sudo yum update -y
sudo yum install -y curl wget unzip

# ===== 1. INSTALL JAVA 17 =====
sudo amazon-linux-extras enable corretto8
sudo yum clean metadata
sudo yum install -y java-17-amazon-corretto-devel

# Verify Java installation
java -version || { echo "Java installation failed"; exit 1; }

# ===== 2. INSTALL JENKINS (with GPG workaround) =====
# Add Jenkins repository
sudo curl -o /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Temporary GPG check bypass (remove in production)
sudo yum install -y jenkins --nogpgcheck

# Configure Jenkins
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "JAVA_HOME=\"$JAVA_HOME\"" | sudo tee -a /etc/sysconfig/jenkins

# Start Jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# ===== 3. INSTALL TERRAFORM =====
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform

# ===== 4. INSTALL GIT =====
sudo yum install -y git

# ===== 5. INSTALL KUBECTL =====
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# ===== 6. FIREWALL CONFIGURATION =====
# Configure EC2 security group to allow port 8080 (Jenkins) via AWS Console/CLI

# ===== 7. VERIFICATION AND OUTPUT =====
# Create setup completion file
cat > /home/ec2-user/setup-complete.txt <<EOF
=== INSTALLATION COMPLETE ===
Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080
Initial Admin Password: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Run 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'")

Installed Tools:
Java: $(java -version 2>&1 | head -n 1)
Jenkins: $(sudo systemctl status jenkins | grep Active)
Terraform: $(terraform --version | head -n 1)
Git: $(git --version)
kubectl: $(kubectl version --client --short)

Installation time: $(date)
EOF

# Display completion message
echo "============================================="
cat /home/ec2-user/setup-complete.txt
echo "============================================="