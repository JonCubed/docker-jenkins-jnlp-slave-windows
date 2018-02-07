# escape=`

# Get OpenJDK nanoserver container
FROM openjdk:8-nanoserver as openjdk

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Remoting versions can be found in Remoting sub-project changelog
# https://github.com/jenkinsci/remoting/blob/master/CHANGELOG.md
ENV SLAVE_FILENAME=slave.jar `
    REMOTING_VERSION=3.15

ENV SLAVE_HASH_FILENAME=$SLAVE_FILENAME.sha1

# Get the Slave from the Jenkins Artifacts Repository
RUN Invoke-WebRequest "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$env:REMOTING_VERSION/remoting-$env:REMOTING_VERSION.jar" -OutFile $env:SLAVE_FILENAME -UseBasicParsing; `
    Invoke-WebRequest "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$env:REMOTING_VERSION/remoting-$env:REMOTING_VERSION.jar.sha1" -OutFile $env:SLAVE_HASH_FILENAME -UseBasicParsing; `
    if ((Get-FileHash $env:SLAVE_FILENAME -Algorithm SHA1).Hash -ne $(Get-Content $env:SLAVE_HASH_FILENAME)) {exit 1};


# Build Git only image
FROM microsoft/nanoserver:sac2016 as git

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV GIT_VERSION=2.15.1.2 `
    GIT_TAG=v2.15.1.windows.2

ENV GIT_FILENAME=MinGit-$GIT_VERSION-64-bit.zip `
    GIT_HASH_FILENAME=$GIT_FILENAME.sha256 `
    GIT_RELEASE_NOTES_FILENAME=releaseNotes.html

# Get Git
RUN Invoke-WebRequest "https://github.com/git-for-windows/git/releases/download/$env:GIT_TAG/$env:GIT_FILENAME" -OutFile $env:GIT_FILENAME -UseBasicParsing;`
    Invoke-WebRequest "https://github.com/git-for-windows/git/releases/tag/$env:GIT_TAG" -OutFile $env:GIT_RELEASE_NOTES_FILENAME -UseBasicParsing; `
    Select-String $env:GIT_RELEASE_NOTES_FILENAME -Pattern "\"<td>$env:GIT_FILENAME</td>\"" -Context 1 `
    | Select-Object -ExpandProperty Context `
    | Select-Object -ExpandProperty DisplayPostContext `
    | Select-String -Pattern '[a-f0-9]{64}' `
    | % { $_.Matches } `
    | % { $_.Value } `
    > $env:GIT_HASH_FILENAME; `
    if ((Get-FileHash $env:GIT_FILENAME -Algorithm SHA256).Hash -ne $(Get-Content $env:GIT_HASH_FILENAME)) {exit 1};

RUN Expand-Archive $env:GIT_FILENAME .\git;

# Build off nanoserver container
FROM microsoft/nanoserver:sac2016

LABEL maintainer="Jonathan Kuleff <jonathankuleff+docker@gmail.com>" `
    org.label-schema.schema-version="1.0" `
    org.label-schema.name="Jenkins JNLP Windows Slave"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV JAVA_HOME="c:\Program Files\openjdk" `
    JENKINS_HOME="c:\Program Files\jenkins" `
    GIT_HOME="c:\Program Files\git"

RUN setx /M PATH $($env:Path.TrimEnd(';') +';' + $env:JAVA_HOME + '\bin;' + $env:GIT_HOME +'\cmd;' + $env:GIT_HOME +'\usr\bin;')

# Copy java into the container
COPY --from=openjdk "C:\ojdkbuild" "$JAVA_HOME"

#Copy launch script used by entry point
COPY "slave-launch.ps1" ".\slave-launch.ps1"

# Copy Jenkins JNLP Slave into container
COPY --from=openjdk ".\slave.jar" ".\slave.jar"

# Copy Jenkins JNLP Slave into container
COPY --from=git ".\git" "$GIT_HOME"

ENTRYPOINT .\slave-launch.ps1

# Find Jenkins LTS version https://jenkins.io/changelog-stable/
LABEL application-min-version.jenkins="2.85.0" `
    application-min-version.jenkins-lts="2.89.2" `
    application-version.jenkins-remoting="3.15" `
    application-version.windows="sac2016" `
    application-version.jdk="1.8" `
    application-version.git="2.15.1.2"
