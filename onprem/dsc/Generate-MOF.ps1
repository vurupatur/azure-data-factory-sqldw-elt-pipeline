Param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
    [System.IO.FileInfo]$DscScript
)

$ErrorActionPreference = "Stop"
# dot source!
. $DscScript.FullName

$DscConfigurationFunction = Get-ChildItem function: | `
    Where-Object {$_.ScriptBlock.File -eq $DscScript -and $_.CommandType -eq "Configuration"}# | `
    #Select-Object $_.Name
$ignoredParameters = @("InstanceName", "DependsOn", "PsDscRunAsCredential", "OutputPath", "ConfigurationData", "Verbose", `
    "Debug", "ErrorAction", "WarningAction", "InformationAction", "ErrorVariable", "WarningVariable", `
    "InformationVariable", "OutVariable", "OutBuffer", "PipelineVariable")

$parameters = $DscConfigurationFunction.Parameters.Values | Where-Object {$ignoredParameters -notcontains $_.Name} | `
    Select-Object @{Name="Name";Expression={$_.Name}}, @{Name="Value";Expression={
        $value = $null
        if ($_.ParameterType -is "System.Management.Automation.PSCredential") {
            Write-Host "credential"
        }
        switch ($_.ParameterType) {
            {$_ -eq [System.Management.Automation.PSCredential]} { $value = New-Object -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @("none", (ConvertTo-SecureString -String "none" -AsPlainText -Force)) }
            {$_ -eq [System.String]} { $value = "Generated" }
        }
        return $value
    }} | ForEach-Object -Begin {$h=@{}} -Process {$h."$($_.Name)"=$_.Value} -End {$h}

$configData = @{
    AllNodes = @(
        @{
            NodeName="*"
            PSDscAllowPlainTextPassword=$true
        },
        @{
            NodeName="localhost"
        }
    )
}

$sqlUserCredentials = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList @("none", (ConvertTo-SecureString -String "none" -AsPlainText -Force))

Write-Host "Generating MOF..." -InformationAction "Continue" -ForegroundColor Green
# $arguments = @()
# $arguments += ("-ConfigurationData", "`"$configData`"")
# $arguments += ("SqlUserCredentials", "`"$sqlUserCredentials`"")
$arguments = @{
    ConfigurationData=$configData
    SqlUserCredentials=$sqlUserCredentials
}

$parameters += @{ConfigurationData=$configData}
#& $DscConfigurationFunction.Name $(@{})
& $DscConfigurationFunction.Name @parameters | Out-Null
#Invoke-Expression -Command "$($DscConfigurationFunction.Name) -ConfigurationData `$configData -SqlUserCredentials `$sqlUserCredentials" | Out-Null
Write-Host "Publishing AzureRmVMDscConfiguration..." -InformationAction "Continue" -ForegroundColor Green
Publish-AzureRmVMDscConfiguration $DscScript.FullName -OutputArchivePath "$($DscScript.FullName).zip" -Force
Write-Host "Publishing complete." -InformationAction "Continue" -ForegroundColor Green
