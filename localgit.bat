@echo off
setlocal enabledelayedexpansion
title Sincronizador de cambios - Configuracion inicial
REM Creado por Álvaro Mora

REM Descomentar las dos lineas inferiores para omitir configuracion inicial
REM set localgitpath=D:\repos
REM goto CHECKACTUALREPO

REM Pedir al usuario la ruta que contiene los repositorios en su USB
set /p localgitpath=Introduce la ruta contenedora de repositorios en tu USB: 
goto CHECKACTUALREPO

:CHECKACTUALREPO
title Sincronizar cambios de repositorio Airbus a USB (!localgitpath!)
if not exist "!localgitpath!" (
    echo La ruta "!localgitpath!" no existe.
    goto SALIR
)
cls
REM Comprobar si la carpeta desde donde se ha ejecutado la terminal es un repositorio Git
if exist "%cd%\.git" (
    echo La ruta desde la que has ejecutado este programa es un repositorio git:
    echo %cd%
    set ok=s
    set /p ok=Deseas utilizar este repositorio? [S/N] 
    if /i "!ok!"=="s" (
        for %%a in ("%cd%") do (
            set "base=%%~dpa"
            set "repo=%%~nxa"
        )
        set "workspace=!base:~0,-1!"
        goto CONFIRMAR
    )
    if /i "!ok!"=="n" goto SELECTREPO
    echo.
    echo Opcion no valida. Intentalo de nuevo.
    timeout -t 1 > NUL
    goto CHECKACTUALREPO
)
goto SELECTREPO

:SELECTREPO
cls
REM Listar carpetas de workspace que contengan una carpeta .git dentro
set "workspace=C:\ProgramData\workspace"
set "repos="
for /d %%D in ("!workspace!\*") do (
    if exist "%%D\.git" (
        set "repos=!repos! %%~nxD"
    )
)

if "!repos!"=="" (
    echo No se encontraron repositorios en "!workspace!".
    goto SALIR
)

:CHOOSEREPO
echo.
echo +------- SELECTOR DE REPOSITORIOS -------+
echo Repositorios disponibles:
set i=0
for %%R in (!repos!) do (
    set /a i+=1
    echo !i!. %%R
    set "repo[!i!]=%%R"
)
echo 0. Salir
echo +----------------------------------------+

set selectRepo=
set /p selectRepo=Selecciona el numero del repositorio o introduce una ruta absoluta: 
if "!selectRepo!"=="0" goto SALIR
if exist "!selectRepo!\.git" (
    if "!selectRepo:~-1!"=="\" set "selectRepo=!selectRepo:~0,-1!"
    for %%a in ("!selectRepo!") do (
        set "base=%%~dpa"
        set "repo=%%~nxa"
    )
    set "workspace=!base:~0,-1!"
    goto CONFIRMAR
)
for /L %%n in (1,1,!i!) do (
    if "!selectRepo!"=="%%n" (
        set "repo=!repo[%selectRepo%]!"
        goto CONFIRMAR
    )
)
echo.
echo Opcion no valida. Introduce un numero del 0 al !i! o una ruta absoluta a otro repositorio.
goto CHOOSEREPO

:MOSTRARCONFIG
echo.
echo **  PEPOSITORIO ORIGINAL  "!workspace!\!repo!"
echo **    REPOSITORIO USB     "!localgitpath!\!repo!.git"
exit /b

:CONFIRMAR
cls
call :MOSTRARCONFIG
set ok=s
set /p ok=Es correcta la configuracion? [S/N] 
if /i "!ok!"=="s" (
    if not exist "!localgitpath!\!repo!.git" (
        goto CLONAR
    )
    echo Ya existe este repositorio descubierto. Omitiendo clonacion...
    goto ACCION
)
if /i "!ok!"=="n" goto SELECTREPO
echo.
echo Opcion no valida. Intentalo de nuevo.
timeout -t 1 > NUL
goto CONFIRMAR

:ACCION
echo.
echo +-------------- MENU PRINCIPAL --------------+
echo Acciones disponibles:
echo 1. Push - Subir cambios de todas las ramas
echo 2. Pull - Bajar cambios de la rama actual
echo 3. Pull All - Bajar cambios de todas las ramas
echo 4. Seleccionar otro repositorio
echo 0. Salir
echo Pulsa Enter sin escibir nada para limpiar
set accion=
set /p accion=Elige una opcion: 
echo +--------------------------------------------+
if "!accion!"=="" (
    cls
    call :MOSTRARCONFIG
    goto ACCION
)
if "!accion!"=="0" goto SALIR
if "!accion!"=="1" goto PUSH
if "!accion!"=="2" goto PULL
if "!accion!"=="3" goto WARNINGPULLALL
if "!accion!"=="4" goto SELECTREPO
echo.
echo Opcion no valida. Introduce un numero del 0 al 4.
goto ACCION

:CLONAR
REM Clona el repositorio existente en el ordenador al USB
echo.
echo El repositorio descubierto no existe.
echo +------------ MENU PRINCIPAL ------------+
echo Acciones disponibles:
echo 1. Clonar - Copiar repositorio a USB
echo 2. Seleccionar otro repositorio
echo 0. Salir
set accion=
set /p accion=Elige una opcion: 
echo +----------------------------------------+
if "!accion!"=="0" goto SALIR
if "!accion!"=="1" (
    echo.
    git clone --bare "!workspace!\!repo!" "!localgitpath!\!repo!.git"
    goto PUSH
)
if "!accion!"=="2" goto SELECTREPO
echo.
echo Opcion no valida. Introduce un numero del 0 al 2.
timeout -t 1 > NUL
cls
call :MOSTRARCONFIG
goto CLONAR

:PUSH
REM Realiza push (todas las ramas) desde el repositorio local al repositorio bare en el USB
echo.
echo Subiendo cambios a todas las ramas...
pushd "!workspace!\!repo!"
git push --mirror "!localgitpath!\!repo!.git"
popd
goto ACCION

:PULL
REM Realiza pull (rama actual) desde el repositorio bare en el USB al repositorio local
echo.
echo Consultando rama actual...
pushd "!workspace!\!repo!"
for /f "tokens=*" %%b in ('git branch --show-current') do (
    echo Bajando cambios desde la rama %%b...
    git pull "!localgitpath!\!repo!.git" %%b
)
popd
goto ACCION

:WARNINGPULLALL
echo Asegurate de que no tengas NINGUN cambio sin guardar (commit o stash es suficiente)
set ok=n
set /p ok=Confirmas que no tienes ningun cambio sin guardar que pueda ser sobreescrito? [S/N] 
if /i "!ok!"=="s" goto PULLALL
if /i "!ok!"=="n" goto ACCION
echo.
echo Opcion no valida. Intentalo de nuevo.
timeout -t 1 > NUL
goto WARNINGPULLALL

:PULLALL
REM Realiza pull (todas las ramas) desde el repositorio bare en el USB al repositorio local
echo Bajando cambios de todas las ramas...
pushd "%workspace%\%repo%"
REM Traer referencias actualizadas del USB
git fetch "%localgitpath%\%repo%.git"
REM Guardar rama actual para volver cuando finalice el proceso
for /f "tokens=*" %%b in ('git branch --show-current') do (
    set "ramaactual=%%b"
)
REM Obtener todas las ramas locales y hacer pull en cada una
for /f "tokens=*" %%b in ('git branch --format="%%(refname:short)"') do (
    echo Actualizando rama: %%b
    git checkout %%b
    git pull "%localgitpath%\%repo%.git" %%b
)
git checkout !ramaactual!
popd
goto ACCION

:SALIR
echo.
echo Saliendo...
timeout -t 2 > NUL
exit