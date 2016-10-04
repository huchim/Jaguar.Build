# Nombre del archivo de la solución recibido desde quien ejecuta esta rutina.
$SolutionName = $env:SOLUTION_NAME

# Directorio de la solución.
$RepositoryRoot = Convert-Path (Get-Location)
$BuildRoot = Join-Path $RepositoryRoot ".build"
$OutPutDir = Join-Path $RepositoryRoot "\src\$SolutionName\bin\Release"
$SolutionPath = Join-Path $RepositoryRoot "$SolutionName.sln"
$MainProject = Join-Path $RepositoryRoot "\src\$SolutionName\$SolutionName.csproj"

# Herramientas
$BuildLog =  Join-Path $OutPutDir "Build.log"
$MSBuildDir = Join-Path $env:systemroot  "Microsoft.NET\Framework\v4.0.30319"


Write-Host -ForegroundColor Green "Creando la carpeta de destino..."

if(Test-Path $OutPutDir) {
    del $OutPutDir -Force -Recurse
}

mkdir $OutPutDir | Out-Null

Write-Host -ForegroundColor Green "Iniciando compilación..."
$MSBuildResponseFile = Join-Path $OutPutDir "build.msbuild.rsp"
if(Test-Path $MSBuildResponseFile) {
    del $MSBuildResponseFile
}

$MSBuildArguments = @"
/nologo
/p:OutputPath="$OutPutDir"
/fl
/flp:LogFile="$BuildLog";Verbosity=diagnostic;Encoding=UTF-8
"$SolutionPath"
"@

$MSBuildArguments | Out-File -Encoding ASCII -FilePath $MSBuildResponseFile
$args | ForEach { $_ | Out-File -Append -Encoding ASCII -FilePath $MSBuildResponseFile }

Write-Host -ForegroundColor DarkGray "> msbuild $SolutionName.sln "

&"$MSBuildDir\MSBuild.exe" `@"$MSBuildResponseFile"


del $MSBuildResponseFile

if(!(Test-Path "$MainProject.nuspec")) {
    Write-Host "$BuildRoot\NuGet.exe"
	Write-Host -ForegroundColor DarkGray "> Creando paquete "
	&"$BuildRoot\NuGet.exe" spec $MainProject
}
