@echo off
title Sincronizar cambios de repositorio Airbus a USB
REM Creado por Álvaro Mora

:LOCALGIT
REM Pedir al usuario la ruta que contiene los repositorios en su USB
setlocal enabledelayedexpansion
:ASKPATH
set /p localgitpath=Introduce la ruta contenedora de repositorios en tu USB:
if not exist "!localgitpath!" (
    echo La ruta "!localgitpath!" no existe. Por favor, inténtalo de nuevo.
    goto ASkPATH
)
goto REPO

:REPO
REM Listar carpetas de C:\ProgramData\workspace que contengan una carpeta .git dentro
set "workspace=C:\ProgramData\workspace"
set "repos="
for /d %%D in ("%workspace%\*") do (
    if exist "%%D\.git" (
        set "repos=!repos! %%~nxD"
    )
)

if "!repos!"=="" (
    echo No se encontraron repositorios con una carpeta .git en "%workspace%".
    goto SALIR
)

echo Repositorios disponibles:
set i=0
for %%R in (!repos!) do (
    set /a i+=1
    echo !i!. %%R
    set "repo[!i!]=%%R"
)

set /p choice=Selecciona el número del repositorio:
set "repo=!repo[%choice%]!"

if not exist "%localgitpath%\%repo%.git" (
    goto CLONE
)

goto ACCION

:ACCION
echo.
echo 1. Push
echo 2. Pull
echo 3. Seleccionar otro repositorio
echo 4. Salir
set /p accion=Elige una opción:
if "%accion%"=="1" goto PUSH
if "%accion%"=="2" goto PULL
if "%accion%"=="3" goto REPO
if "%accion%"=="4" goto SALIR
echo Opción no válida. Inténtalo de nuevo.
goto ACCION

:CLONE
REM Clona el repositorio existente en el ordenador al USB
echo Clonando repositorio descubierto...
git clone --bare "%workspace%\%repo%" "%localgitpath%\%repo%.git"
goto ACCION

:PUSH
REM Realiza push desde el repositorio local al repositorio bare en el USB
echo Subiendo cambios...
pushd "%workspace%\%repo%"
git push --mirror "%localgitpath%\%repo%.git"
popd
goto ACCION

:PULL
REM Realiza pull desde el repositorio bare en el USB al repositorio local
echo Bajando cambios...
pushd "%workspace%\%repo%"
git pull "%localgitpath%\%repo%.git" main
popd
goto ACCION

:SALIR
echo Saliendo...
pause
exit