# Jenkins JNLP Agent for Windows Docker Image

[![](https://img.shields.io/docker/stars/jonathank/jenkins-jnlp-slave-windows.svg)](https://hub.docker.com/r/jonathank/jenkins-jnlp-slave-windows)
[![](https://img.shields.io/docker/pulls/jonathank/jenkins-jnlp-slave-windows.svg)](https://hub.docker.com/r/jonathank/jenkins-jnlp-slave-windows)

This is a base image for Jenkins agent (FKA "slave") on Windows using JNLP to establish connection.
This agent is powered by the Jenkins Remoting library, taken from their [artifacts repository](https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/).

For correct agent version see the [Remoting Sub-Project](https://github.com/jenkinsci/remoting/blob/master/CHANGELOG.md) for more info.

See [Jenkins Distributed builds](https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds) for more info.

## Running

To run a Docker container

```
docker run jonathank/jenkins-jnlp-slave-windows -url http://jenkins-server:port <secret> <agent name>
```


*Optional environment variables:*

* JENKINS_URL: url for the Jenkins server, can be used as a replacement to -url option, or to set alternate jenkins URL
* JENKINS_TUNNEL: (HOST:PORT) connect to this agent host and port instead of Jenkins server, assuming this one do route TCP traffic to Jenkins master. Useful when when Jenkins runs behind a load balancer, reverse proxy, etc.
* JENKINS_SECRET: agent secret, if not set as an argument
* JENKINS_AGENT_NAME: agent name, if not set as an argument

## Issues

If you have any problems with or questions about this image, please contact me through a [GitHub issue](https://github.com/JonCubed/docker-jenkins-jnlp-slave-windows).

## Contributing

You are invited to contribute new features, fixes, or updates, large or small via pull requests, and I'll do my best to process them as fast as I can.
