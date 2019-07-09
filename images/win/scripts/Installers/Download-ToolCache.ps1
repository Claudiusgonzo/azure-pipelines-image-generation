################################################################################
##  File:  Download-ToolCache.ps1
##  Team:  CI-Build
##  Desc:  Download tool cache
################################################################################

Function InstallTool
{
    Param
    (
        [System.Object]$ExecutablePath
    )

    Write-Host $ExecutablePath.DirectoryName
    Set-Location -Path $ExecutablePath.DirectoryName
    Get-Location | Write-Host
    if (Test-Path 'tool.zip')
    {
        Expand-Archive 'tool.zip' -DestinationPath '.'
    }
    cmd.exe /c 'install_to_tools_cache.bat'
}

$SourceUrl = "https://vstsagenttools.blob.core.windows.net/tools"

$Dest = "C:/"

$Path = "hostedtoolcache/windows"

$env:Path = "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy;" + $env:Path

Write-Host "Started AzCopy from $SourceUrl to $Dest"

AzCopy /Source:$SourceUrl /Dest:$Dest  /S /V /Pattern:$Path

$ToolsDirectory = $Dest + $Path

$current = Get-Location
Set-Location -Path $ToolsDirectory

Get-ChildItem -Recurse -Depth 4 -Filter install_to_tools_cache.bat | ForEach-Object {
    InstallTool($_)
}

Set-Location -Path $current

setx AGENT_TOOLSDIRECTORY $ToolsDirectory /M

#junction point from the previous Python2 directory to the toolcache Python2
$python2Dir = (Get-Item -Path ($ToolsDirectory + '/Python/2.7*/x64')).FullName
cmd.exe /c mklink /d "C:\Python27amd64" "$python2Dir"