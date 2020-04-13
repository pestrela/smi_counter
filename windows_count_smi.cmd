@echo off

echo ""
echo "SMI counter - batch file version"
echo ""

:loop
"c:\Program Files (x86)\Windows Kits\10\Debuggers\x64\kd.exe" -kl -c "RDMSR 0x34; q" | find "msr"

set /P name="Do something, and then press 'enter' to read the MSI again"
goto loop

