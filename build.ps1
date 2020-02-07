param (
    [Parameter(Mandatory = $false)]
    [switch] $NuGet,
    [Parameter(Mandatory = $false)]
    [switch] $SkipTests
)

# Build script configuration
$configuration = "Release"
$sgen = "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6 Tools\sgen.exe" 

$projects = @(
    @{root = '.\src\UblSharp'; csproj = 'UblSharp.csproj'; sgen = @("net20", "net35", "net40")},
    @{root = '.\src\UblSharp.Validation'; csproj = 'UblSharp.Validation.csproj'},
    @{root = '.\src\UblSharp.Generator.Core'; csproj = 'UblSharp.Generator.Core.csproj'},
    @{root = '.\src\UblSharp.SEeF'; csproj = 'UblSharp.SEeF.csproj'},
    @{root = '.\src\UblSharp.SCSN'; csproj = 'UblSharp.SCSN.csproj'}
)

# End configuration

# includes
. "$PSScriptRoot\build\build-functions.ps1"

Push-Location $(Split-Path $Script:MyInvocation.MyCommand.Path)

# version suffix info
$tag = $(git tag -l --points-at HEAD)
$branch = $(git rev-parse --abbrev-ref HEAD)
$revision = @{ $true = "{0:00000}" -f [convert]::ToInt32("0" + $env:APPVEYOR_BUILD_NUMBER, 10); $false = "local" }[$env:APPVEYOR_BUILD_NUMBER -ne $NULL];
$suffix = @{ $true = "local"; $false = "ci$revision"}[$revision -eq "local"]
# When suffix is not local, assume appveyor build. When also on a tag, it's a release package, make sure suffix stays empty
$suffix = @{ $true = ""; $false = "$suffix"}[$suffix -ne "local" -and $tag -ne $NULL]
$commitHash = $(git rev-parse --short HEAD)
$buildSuffix = @{ $true = "$($suffix)-$($commitHash)"; $false = "$($branch)-$($commitHash)" }[$suffix -ne ""]
$versionsuffix = @{ $true = "--version-suffix=$suffix"; $false = "" }[$suffix -ne ""]

# clean artifacts
if (Test-Path .\artifacts) { Remove-Item .\artifacts -Force -Recurse }
New-Item -ItemType directory -Path .\artifacts | Out-Null

# Build projects
foreach ($project in $projects) {
    $projectFile = $(Join-Path $project['root'] $project['csproj'])
    
    Write-Host "Building $projectFile... with version suffix $buildSuffix"
    
    exec { & dotnet restore $projectFile }
    exec { & dotnet build "$projectFile" -c Release --version-suffix=$buildSuffix --no-dependencies --no-incremental /nologo }
}

# Generate XmlSerializers assemblies (in parallel)
"net20", "net35", "net40", "net45" | ForEach-Object {
    $do_sgen = {
        param($sgen, $file)
        & $sgen /assembly:$file /verbose /force
    }

    Start-Job -Name "sgen-$_" $do_sgen -ArgumentList ($sgen, [System.IO.Path]::GetFullPath("$PSScriptRoot\src\UblSharp\bin\$configuration\$_\UblSharp.dll"))
}

While (Get-Job -State "Running") { Start-Sleep 1 }

Get-Job | Receive-Job
Remove-Job *

If ($SkipTests -eq $false) {
    # build tests first
    exec { & dotnet restore .\src\UblSharp.Tests\UblSharp.Tests.csproj }
    exec { & dotnet build .\src\UblSharp.Tests\UblSharp.Tests.csproj -c Release --no-dependencies }

    # manually copy sgen assemblies to test bin directory
    # hack: hard-coded platform name, note that we have a 'net45' sgen assembly, but the test project is a 'net46' project.
    Copy-Item -Path ".\src\UblSharp\bin\$configuration\net45\UblSharp.XmlSerializers.dll" -Destination ".\src\UblSharp.Tests\bin\$configuration\net46\" -Force

    # Build/Run tests
    exec { & dotnet test .\src\UblSharp.Tests\UblSharp.Tests.csproj -c Release --no-build }
}

# Create packages  
foreach ($project in $projects) {   
    $projectFile = $(Join-Path $project['root'] $project['csproj'])
    exec { & dotnet pack $projectFile -c Release --no-build $versionsuffix --include-symbols -o "$PSScriptRoot\artifacts" }
}

Pop-Location
