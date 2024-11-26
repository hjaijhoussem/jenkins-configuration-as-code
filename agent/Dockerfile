#FROM jenkins/agent
#USER root
#RUN apt update && curl -fsSL https://get.docker.com | sh
#RUN usermod -aG docker jenkins
#USER jenkins
# Use the official Jenkins agent image as the base
FROM jenkins/inbound-agent:latest

# Install Docker
USER root
RUN curl -fsSL https://test.docker.com -o test-docker.sh && sh test-docker.sh

# Configure Docker to run as non-root user
RUN sudo groupadd docker
RUN usermod -aG docker jenkins


# Enable DinD
RUN mkdir -p /var/lib/docker
VOLUME /var/lib/docker