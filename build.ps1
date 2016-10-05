# Nombre del archivo de la solución recibido desde quien ejecuta esta rutina.
$SolutionName = $env:SOLUTION_NAME
$ApiKey = Read-Host 'Ingrese su clave de acceso (opcional)'

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

Write-Host "Empacando..."
Write-Host -ForegroundColor DarkGray "> Creando paquete "
&"$BuildRoot\NuGet.exe" pack $MainProject -IncludeReferencedProjects -outputdirectory "$OutPutDir"

Write-Host -ForegroundColor Green "Clave API: $ApiKey"

if ($ApiKey) {	
	# Ubicando paquete
	Write-Host -ForegroundColor Green "Buscando paquete: $OutPutDir"
	$pkgFiles = [IO.Directory]::GetFiles("$OutPutDir", "*.nupkg")
	$pkgName = ""
	foreach($pkg in $pkgFiles) 
	{ 
		Write-Host -ForegroundColor Green "> Subiendo paquete: $pkg"
		$pkgName = $pkg
	} 
	
	if ($pkgName) {
		Write-Host -ForegroundColor Green "> Subiendo paquete: $pkgName"
		&"$BuildRoot\NuGet.exe" push $pkgName $ApiKey -source https://www.nuget.org/api/v2/package
	}	
}