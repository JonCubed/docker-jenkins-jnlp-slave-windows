# Based of script used by jenkinsci/jnlp-slave
# https://github.com/jenkinsci/docker-jnlp-slave/blob/master/jenkins-slave
#
# Usage : slave-launch.ps1 -Url <url> [-Tunnel <tunnel>] [<secret>] [<agent Name>]
#
# Optional environment variables:
# * JENKINS_TUNNEL      : HOST:PORT for a tunnel to route TCP traffic to a Jenkins host when Jenkins can't be directly accessed over network
# * JENKINS_URL         : alternative Jenkins URL
# * JENKINS_SECRET      : agent secret, used if not already set via command-line argument
# * JENKINS_AGENT_NAME  : agent name, used if not already set via command-line argument
[CmdletBinding(DefaultParametersetName = "WithoutTunnel")]
param (
    [Parameter(Mandatory = $true, Position = 1)]
    [String]
    $Url,

    [Parameter(ParameterSetName = "WithTunnel", Mandatory = $true, Position = 2)]
    [String]
    $Tunnel,

    [Parameter(ParameterSetName = "WithTunnel", Position = 3)]
    [String]
    $Secret1,

    [Parameter(ParameterSetName = "WithTunnel", Position = 4)]
    [String]
    $AgentName1,

    [Parameter(ParameterSetName = "WithoutTunnel", Position = 2)]
    [String]
    $Secret2,

    [Parameter(ParameterSetName = "WithoutTunnel", Position = 3)]
    [String]
    $AgentName2
)

$secret = @{$true = $Secret1; $false = $Secret2}[$Secret1 -ne ""]
$agentName = @{$true = $AgentName1; $false = $AgentName2}[$AgentName1 -ne ""]

if ($env:JENKINS_TUNNEL) {
    $Tunnel = $env:JENKINS_TUNNEL
}

if ($env:JENKINS_URL) {
    $Url = $env:JENKINS_URL
}

if ($env:JENKINS_SECRET -and $secret) {
    Write-Warning "Secret is defined twice, in command-line argument and environment variable"
}
elseif ($env:JENKINS_URL) {
    $secret = $env:JENKINS_URL
}

if ($env:JENKINS_AGENT_NAME -and $agentName) {
    Write-Warning "Agent Name is defined twice, in command-line argument and environment variable"
}
elseif ($env:JENKINS_AGENT_NAME) {
    $agentName = $env:JENKINS_AGENT_NAME
}


$params = @("-headless")

if ($Tunnel) {
    $params += @("-tunnel", $Tunnel)
}

$params += ( `
    "-url", $Url, `
    "-workDir", "C:/Jenkins/Agents", `
    $secret, `
    $agentName `
)

function Show-Commandline {
    $args
}

Show-Commandline "java $javaOpts $jnlpProtocolOpts -cp ./slave.jar hudson.remoting.jnlp.Main" @params

# run slave
. java $javaOpts $jnlpProtocolOpts -cp ./slave.jar hudson.remoting.jnlp.Main @params
