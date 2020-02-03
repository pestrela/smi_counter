# Windows SMI counter

This program displays the count of SMI interrupts in Windows. It is a wrapper to the windows kernel debugger.
This program also saves a log file to show average events per hour.

SMI are System Management Interrupts of Intel CPUS that that the BIOS uses to perform special operations 
https://en.wikipedia.org/wiki/System_Management_Mode

## Download

[windows_count_smi.sh]


## Pre-requisites:

* Windows 10
* WSL
* Windows Kernel Debugger:
   * install windows SDK, select ONLY 'Debugging Tools for Windows'
   * https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/

## Installation

* Disable secure boot in BIOS
* Enable debug in windows kernel  (bcdedit.exe -debug on)
  * https://alfredmyers.com/2017/11/26/the-system-does-not-support-local-kernel-debugging/
* Reboot
  
## Operation

* start WSL window in administrator mode
* windows_count_smi.sh [test_descrption]
* To measure SMI LATENCY impact:
  * Run IDTL (In Depth Latency Tests) with HIGH_LEVEL IRQL
  * https://www.resplendence.com/latencymon_idlt
  * https://www.resplendence.com/latencymon_cpustalls
   
# SMI Measurements results

## BIOS problems
[Dell Ticket](https://www.dell.com/community/XPS/Dell-XPS-15-9560-BIOS-0-18-0-causes-SECONDS-of-SMI-latency-not/td-p/7477967)
  
![dell_smi_heavy_problems](dell_smi_heavy_problems.jpg?raw=true "Dell SMI")

## Changing Brightness

![SMI measurer control](dell_smi_counter.jpg?raw=true "Dell SMI")



   
    

    