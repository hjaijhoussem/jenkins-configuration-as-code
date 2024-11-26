FROM jenkins/jenkins:latest

# Set JAVA_OPTS environment variable to disable the Jenkins setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

USER root
RUN apt update && curl -fsSL https://get.docker.com | sh
RUN usermod -aG docker jenkins


# Expose the default Jenkins port (8080 inside the container)
ENTRYPOINT ["bash", "-c", "jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt --verbose && exec /usr/local/bin/jenkins.sh"]
EXPOSE 8080

