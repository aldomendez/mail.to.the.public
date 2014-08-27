@echo off

cls

title No cierres esta ventana!

echo ""
:: Creamos una unidad temporal
:: pushd "%~dp0"
:: set node = c:\apps\node


cls
:: Iniciamos el trabajo
start /min cmd /c "runner.bat"
