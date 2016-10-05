# Jaguar.Build

Este repositorio contiene rutinas para poder compilar o desplegar un paquete a la galería de [Nuget](http://www.nuget.org), estas estas contenidas en el archivo [build.ps1](https://github.com/huchim/Jaguar.Build/blob/master/build.ps1).

## Instalación

En esta primera versión, la rutina ha sido diseñada pensando en proyectos que sigan la siguiente estructura:

    + custom.ps1
    + src\
    +    SolutionName\
    +    SolutionName\SolutionName.csproj
    +    SolutionName.sln
    + .build\ (carpeta donde debe de ir el contenido de este repositorio)


Donde `custom1.ps1` contiene lo siguiente:

    $env:SOLUTION_NAME = "Jaguar.Core.DAL"
    &".build.ps1"
    
El nombre "Jaguar.Core.DAL" es el nombre del proyecto.
    
## Ejecutar

En la consola de PowerShell debes de correr el comando `custom.ps1`

    > .\custom.ps1
    > 
    > Ingrese su clave de acceso (opcional):  nuget-api-key
    > Subiendo paquete Jaguar.Core.DAL.1.0.0.31597.nupkg

Si no agrega ninguna clave, no se subirá ningún paquete.

## Limitaciones

Esta rutina es un inicio para luego poder compilar automáticamente los proyectos por algún servidor de compilación, y que este suba a nuget el paquete de manera automática, pero aún le falta mucho.
