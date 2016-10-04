Write-Host -ForegroundColor Green "Iniciando compilación..."

# Directorio de la solución.
# $RepositoryRoot = Convert-Path (Get-Location)
$RepositoryRoot = "F:\users\huchim\documents\visual studio 2015\Projects\github\"
$SolutionName = "Jaguar.Core.DAL"
$SolutionPath = Join-Path $RepositoryRoot "$SolutionName\$SolutionName.sln"
# Directorio donde se compilará.
$BuildRoot = Join-Path $RepositoryRoot "$SolutionName\src\$SolutionName\bin\Release"
$BuildLog =  Join-Path $BuildRoot "Build.log"
$MSBuildDir = Join-Path $env:systemroot  "Microsoft.NET\Framework\v4.0.30319"
$MsBuildExe = Join-Path $MSBuildDir "MsBuild.exe"  

# Determinar a dónde va esta variable.
$BuildRoot2 = (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)))
#$KoreBuildRoot = (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))

Write-Host -ForegroundColor Green "RepositoryRoot: $BuildRoot"

if(Test-Path $BuildRoot) {
    del $BuildRoot -Force -Recurse
}

$MSBuildResponseFile = Join-Path $BuildRoot "build.msbuild.rsp"
if(Test-Path $MSBuildResponseFile) {
    del $MSBuildResponseFile
}

function exec($cmd) {
    $cmdName = [IO.Path]::GetFileName($cmd)
    Write-Host -ForegroundColor DarkGray "> $cmdName $args"
    "`r`n>>>>> $cmd $args <<<<<`r`n" >> $KoreBuildLog
    & $cmd @args 2>&1 >> $KoreBuildLog
    $exitCode = $LASTEXITCODE
    if($exitCode -ne 0) {
        throw "'$cmdName $args' failed with exit code: $exitCode. See '$ArtifactsDir\korebuild.log' for details"
    }
}

mkdir $BuildRoot | Out-Null

$MSBuildArguments = @"
/nologo
/p:OutputPath="$BuildRoot"
/fl
/flp:LogFile="$BuildLog";Verbosity=diagnostic;Encoding=UTF-8
"$SolutionPath"
"@

$MSBuildArguments | Out-File -Encoding ASCII -FilePath $MSBuildResponseFile
$args | ForEach { $_ | Out-File -Append -Encoding ASCII -FilePath $MSBuildResponseFile }

Write-Host -ForegroundColor DarkGray "> msbuild $SolutionName.sln $args"

& "$MSBuildDir\MSBuild.exe" `@"$MSBuildResponseFile"

del $MSBuildResponseFile