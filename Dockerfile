# escape=`

# Get OpenJDK nanoserver container
FROM openjdk:8-nanoserver as openjdk

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Remoting versions can be found in Remoting sub-project changelog
# https://github.com/jenkinsci/remoting/blob/master/CHANGELOG.md
ENV SLAVE_FILENAME=slave.jar `
    SLAVE_HASH_FILENAME=$SLAVE_FILENAME.sha1 `
    REMOTING_VERSION=3.7

# Get the Slave from the Jenkins server
RUN Invoke-WebRequest "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$env:REMOTING_VERSION/remoting-$env:REMOTING_VERSION.jar" -OutFile $env:SLAVE_FILENAME -UseBasicParsing; `
    Invoke-WebRequest "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$env:REMOTING_VERSION/remoting-$env:REMOTING_VERSION.jar.sha1" -OutFile $env:SLAVE_HASH_FILENAME -UseBasicParsing; `
    if ((Get-FileHash $env:SLAVE_FILENAME -Algorithm SHA1).Hash -ne $(Get-Content $env:SLAVE_HASH_FILENAME)) {exit 1};


# Build off .NET Core nanoserver container
FROM microsoft/nanoserver:10.0.14393.1593

LABEL maintainer="Jonathan Kuleff <jonathankuleff+docker@gmail.com>" `
      org.label-schema.schema-version="1.0" `
      org.label-schema.name="Jenkins JNLP Windows Slave"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV JAVA_HOME="c:\Program Files\openjdk" `
    JENKINS_HOME="c:\Program Files\jenkins"

RUN setx /M PATH $($Env:PATH + ';' + $Env:JAVA_HOME + '\bin')

# Copy java into the container
COPY --from=openjdk "C:\ojdkbuild" "$JAVA_HOME"

#Copy launch script used by entry point
COPY "slave-launch.ps1" ".\slave-launch.ps1"

# Copy Jenkins JNLP Slave into container
COPY --from=openjdk ".\slave.jar" ".\slave.jar"

ENTRYPOINT .\slave-launch.ps1

LABEL jenkins-remoting-version="3.7" `
      jenkins-min-version="2.50" `
      jenkins-lts-min-version="2.46.2" `
      windows-version="10.0.14393.1593" `
      jdk-version="1.8"
