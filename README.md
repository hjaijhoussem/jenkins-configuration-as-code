# Jenkins Docker Setup with Configuration as Code

This repository provides a complete setup for Jenkins using Docker, with Configuration as Code (CASC) for easy configuration management. Below are the detailed instructions and explanations for the Docker setup, Docker Compose configuration, and CASC YAML file.

---

## Table of Contents
1. [Dockerfile](#dockerfile)
2. [Docker Compose](#docker-compose)
3. [CASC YAML Configuration](#casc-yaml-configuration)
4. [How to Use](#how-to-use)

---

## Dockerfile

The `Dockerfile` defines the custom Jenkins image used to run Jenkins in a Docker container, along with required dependencies and configuration files.

```dockerfile
# Use the official Jenkins LTS image as the base image
FROM jenkins/jenkins:lts

# Switch to root to install necessary packages
USER root

# Install dependencies for the Jenkins setup
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    vim \
    && apt-get clean

# Set the home directory for Jenkins
USER jenkins

# Expose necessary ports
EXPOSE 8080
EXPOSE 50000

# Set the Jenkins home directory
ENV JENKINS_HOME /var/jenkins_home

# Copy the CASC file into the container
COPY casc.yaml /var/jenkins_home/casc.yaml

# Set the Jenkins Java options (adjust memory limits as needed)
ENV JAVA_OPTS -Xms2048m -Xmx4096m

# Start Jenkins with the CASC configuration
ENTRYPOINT ["/usr/bin/java", "-jar", "/usr/share/jenkins/jenkins.war", "--httpPort=8080", "--prefix=/jenkins"]
