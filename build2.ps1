# Nombre del archivo de la solución recibido desde quien ejecuta esta rutina.
$SolutionName = $env:SOLUTION_NAME
$ApiKey = $env:API_KEY

if (!$ApiKey)
{
	$ApiKey = Read-Host 'Ingrese su clave de acceso (opcional)'
}

# Directorio de la solución.
$RepositoryRoot = Convert-Path (Get-Location)
$BuildRoot = Join-Path $RepositoryRoot ".build"
$OutPutDir = Join-Path $RepositoryRoot "\src\$SolutionName\bin\Release"
$MainProject = Join-Path $RepositoryRoot "\src\$SolutionName\"

Write-Host -ForegroundColor Green "Creando la carpeta de destino..."

if(Test-Path $OutPutDir) {
    del $OutPutDir -Force -Recurse
}

mkdir $OutPutDir | Out-Null
cd $MainProject

Write-Host "Empacando..."
Write-Host -ForegroundColor DarkGray "> Creando paquete "
&"dotnet.exe" pack -o "$OutPutDir"

Write-Host -ForegroundColor Green "Clave API: $ApiKey"

if ($ApiKey) {	
	# Ubicando paquete
	Write-Host -ForegroundColor Green "Buscando paquete: $OutPutDir"
	$pkgFiles = [IO.Directory]::GetFiles("$OutPutDir", "*.nupkg")
	$pkgName = ""
	foreach($pkg in $pkgFiles) 
	{ 
		if ($string -notcontains '*.symbols.*') { 
			Write-Host -ForegroundColor Green "> Subiendo paquete: $pkg"
			$pkgName = $pkg
		}
	} 
	
	if ($pkgName) {
		Write-Host -ForegroundColor Green "> Subiendo paquete: $pkgName"
		&"$BuildRoot\NuGet.exe" push $pkgName $ApiKey -source https://www.nuget.org/api/v2/package
	}	
}

cd $RepositoryRoot