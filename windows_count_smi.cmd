@echo off

@echo.
@echo "SMI counter - batch file version"
@echo.

:loop

@echo.
@echo Date: %date% %time%
"c:\Program Files (x86)\Windows Kits\10\Debuggers\x64\kd.exe" -kl -c "RDMSR 0x34; q" | find "msr"

set /P name="press CTRL+C to exit, Enter to measure again"
goto loop

