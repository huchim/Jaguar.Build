# Nombre del archivo de la solución recibido desde quien ejecuta esta rutina.
$SolutionName = $env:SOLUTION_NAME

# Directorio de la solución.
$RepositoryRoot = Convert-Path (Get-Location)
$BuildRoot = Join-Path $RepositoryRoot "\src\$SolutionName\bin\Release"
$SolutionPath = Join-Path $RepositoryRoot "$SolutionName.sln"

# Herramientas
$BuildLog =  Join-Path $BuildRoot "Build.log"
$MSBuildDir = Join-Path $env:systemroot  "Microsoft.NET\Framework\v4.0.30319"


Write-Host -ForegroundColor Green "Creando la carpeta de destino..."

if(Test-Path $BuildRoot) {
    del $BuildRoot -Force -Recurse
}

mkdir $BuildRoot | Out-Null

Write-Host -ForegroundColor Green "Iniciando compilación..."
$MSBuildResponseFile = Join-Path $BuildRoot "build.msbuild.rsp"
if(Test-Path $MSBuildResponseFile) {
    del $MSBuildResponseFile
}

$MSBuildArguments = @"
/nologo
/p:OutputPath="$BuildRoot"
/fl
/flp:LogFile="$BuildLog";Verbosity=diagnostic;Encoding=UTF-8
"$SolutionPath"
"@

$MSBuildArguments | Out-File -Encoding ASCII -FilePath $MSBuildResponseFile
$args | ForEach { $_ | Out-File -Append -Encoding ASCII -FilePath $MSBuildResponseFile }

Write-Host -ForegroundColor DarkGray "> msbuild $SolutionName.sln "

& "$MSBuildDir\MSBuild.exe" `@"$MSBuildResponseFile"

del $MSBuildResponseFile