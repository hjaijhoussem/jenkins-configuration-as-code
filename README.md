# Jenkins Docker Setup with Configuration as Code

This repository provides a complete setup for Jenkins using Docker, with Configuration as Code (CASC) for easy configuration management. Below are the detailed instructions and explanations for the Docker setup, Docker Compose configuration, and CASC YAML file.

---

## Table of Contents
1. [Dockerfile](#dockerfile)
2. [Docker Compose](#docker-compose)
3. [Plugins file](#plugins-file)
4. [CASC YAML Configuration](#casc-yaml-configuration)
   5. [Most Ferquent Updated Configurations](#most-ferquent-updated-configurations)
      1. [Adding credentials](#adding-credentials) 
      2. [Adding Tools](#adding-tools)
      3. [Pipeline automation](#automate-pipeline-creation-in-jenkins)
4. [How to Use](#how-to-use)

---

## Dockerfile

The `Dockerfile` defines the custom Jenkins image used to run Jenkins in a Docker container, along with required dependencies and configuration files.

```dockerfile
FROM jenkins/jenkins:latest

# Set JAVA_OPTS environment variable to disable the Jenkins setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

USER root
# Install docker
RUN apt update && curl -fsSL https://get.docker.com | sh
RUN usermod -aG docker jenkins


# Expose the default Jenkins port (8080 inside the container)
ENTRYPOINT ["bash", "-c", "jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt --verbose && exec /usr/local/bin/jenkins.sh"]
EXPOSE 8080
```
## Docker compose

```yaml
version: '3.3'
services:
  ...
  jenkins:
    build:
      context: .
      dockerfile: Dockerfile
    image: "<YOUR-REPO>/jenkins:casc-custom"
    container_name: jenkins_casc
    ports:
      - '8081:8080'
      - '50000:50000'
    volumes:
      # Mount the plugins.txt  
      - './plugins.txt:/usr/share/jenkins/ref/plugins.txt'
      - /var/run/docker.sock:/var/run/docker.sock
      - jenkins_home:/var/jenkins_home
      # Mount the casc.yaml 
      - ./casc.yaml:/var/jenkins_home/casc.yaml
    networks:
      - pipeline
    environment:
      - CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml

networks:
  pipeline:
    driver: bridge
volumes:
  ...
  jenkins_home:
    driver: local
```

## Plugins file
This file is required to automate the installation of plugins on the Jenkins server. It must be mounted to the path `/usr/share/jenkins/ref/plugins.txt` within the Jenkins container.
The plugins.txt file follows a specific format, where each line should specify the plugin name and version in the format `<plugin-name>:<version>`. For example:
```plugins
    ant:latest
```
Ensure that each plugin is listed with its corresponding version or the desired version tag (e.g., `latest`).
## CASC YAML Configuration
The `casc.yaml` file is used to automate the configuration of Jenkins during the container startup process.

You can specify the location of the `casc.yaml` file by overriding the `CASC_JENKINS_CONFIG` environment variable (e.g., `CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml`) within the Jenkins container.
### Creating the casc.yaml File
You have two options for creating and managing the `casc.yaml` file:

1. Manual Creation:
You can manually create the casc.yaml file and mount it to the appropriate path within the Jenkins container.

2. **Export** from Jenkins UI:
Alternatively, you can **export** the `casc.yaml` configuration directly from the **Jenkins UI**. To do this:
   - Navigate to `Manage Jenkins` → `Configuration as Code`.
   - Click `Download Configuration` to export the current configuration as a casc.yaml file. 
### Updating the casc.yaml File
You can also update your `casc.yaml` configuration directly from the Jenkins UI. 
After making changes in the UI, follow these steps:
  - Go to `Manage Jenkins` → `Configuration as Code`.
  - Click `View Configuration` to see the current configuration.
  - Copy any added sections from the UI and incorporate them into your `casc.yaml` file.
### Most Ferquent Updated Configurations
#### Adding credentials
All credential configurations should be placed under the `credentials` section in your `casc.yaml` file as follows:
```yaml
credentials:
  system:
    domainCredentials:
      credentials:
       ...
```
- **SSH Key Credential**
```yaml
      - basicSSHUserPrivateKey:
          id: "github-jenkins"
          privateKeySource:
            directEntry:
            privateKey: "<your-private-key>"
          scope: GLOBAL
          username: "<username>"
```
- **Secret Credential**
```yaml
      - string:
          description: "token for github repo"
          id: "gh-jenkins-tk"
          scope: GLOBAL
          secret: "your-secret"
```
- **Username and Password Credential**
```yaml
      - usernamePassword:
          id: "nexus"
          password: "jenkins3"
          scope: GLOBAL
          username: "jenkins"
```
#### Adding tools
All tools configurations should be placed under the `tool` section in your `casc.yaml` file as follows:
```yaml
tool:
  ...
```
- **Git**
```yaml
      git:
      installations:
        - home: "git"
          name: "Default"
```
- **Maven**
```yaml
    maven:
      installations:
        - name: "3.9.5"
          properties:
            - installSource:
                installers:
                  - maven:
                      id: "3.9.5"
```
- **Node Js**
```yaml
      nodejs:
        installations:
          - name: "nodejs-18"
            properties:
              - installSource:
                  installers:
                    - nodeJSInstaller:
                        id: "18.20.5"
                        npmPackagesRefreshHours: 72
```
#### Automate pipeline creation in jenkins
This configuration is intended for a pipeline that stores its `Jenkinsfile` within a Git repository. The pipeline configurations should be specified under the jobs section in your `casc.yaml` file, as demonstrated below::
```yaml
jobs:
  ...
```
To add a pipeline, use the following configuration:
```yaml
    - script: >
        pipelineJob('car-pooling-be') {
          definition {
            cpsScm {
              scm {
                git {
                  remote {
                    url('<git-repo-url>')
                    credentials('<your-creds')
                  }
                  branch('*/main')
                }
              }
              scriptPath("<path>/Jenkinsfile")
              lightweight()
            }
          }
        }
```
**Note:** The pipeline configuration under `script: >` should not include any comments. Including comments will result in an error during Jenkins server startup.
## How to Use
1. Start the Services Using Docker Compose:
```shell
docker compose up -d --build
```
- `--build` tag to create the jenkins custom docker image
2. Access Jenkins: Once the containers are up and running, access Jenkins via http://localhost:8081 in your web browser.

   **Note**: The Jenkins server may take some time to start. Please refresh your browser periodically to check for updates.
3. **Clean-up**                           
```shell
docker compose down
```