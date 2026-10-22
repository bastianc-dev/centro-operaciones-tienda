@echo off
setlocal
cd /d "%~dp0"
py -3 scripts\analizar.py >> reports\ejecuciones.log 2>&1
if errorlevel 1 (
    echo Error al generar informe. Revisa reports\ejecuciones.log
    exit /b 1
)
echo Informe actualizado: reports\informe_ultimo.md
