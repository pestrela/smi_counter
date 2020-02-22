# Windows SMI counter

This is a wrapper for the Kernel Debugger to count SMI interrupts.\
SMIs are special interrupts issued by the BIOS at any time todo special operations. This locks the whole computer including all cores and the whole OS.
https://en.wikipedia.org/wiki/System_Management_Mode

## Download

[windows_count_smi.sh](windows_count_smi.sh)


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
   

# Results


**UPDATE:** the SMIs latency problem returned even on BIOS 0.12.1. It happens every 30minutes,

It is perfectly correlated with DellSupportAssistRemedationService that does a full PCI inventory every 30m. Disabling this service avoids the problem (again!). 

----

**windows_count_smi log:**

* 2020-02-22 13:19:28,504033800+00:00 1582377568.504033800 SMI 192
* 2020-02-22 13:49:29,709938000+00:00 1582379369.709938000 SMI 192
* 2020-02-22 14:19:31,464194900+00:00 1582381171.464194900 SMI 192
* 2020-02-22 14:49:32,292745300+00:00 1582382972.292745300 SMI 192

**DellSupportAssistRemedationService.log**

* 20-02-22 13:19:26,938 [4] [ERROR] Failed to detect audio playing. #StackInfo#
* 20-02-22 13:49:28,208 [4] [ERROR] Failed to detect audio playing. #StackInfo#
* 20-02-22 14:19:29,470 [4] [ERROR] Failed to detect audio playing. #StackInfo#
* 20-02-22 14:49:30,732 [4] [ERROR] Failed to detect audio playing. #StackInfo#



## a) BIOS 0.18.0 SMI problems
[Dell Ticket](https://www.dell.com/community/XPS/Dell-XPS-15-9560-BIOS-0-18-0-causes-SECONDS-of-SMI-latency-not/td-p/7477967)
  
![dell_smi_heavy_problems](dell_smi_heavy_problems.jpg?raw=true "Dell SMI")

## b) Changing Brightness

![SMI measurer control](dell_smi_counter.jpg?raw=true "Dell SMI")



   
    

    
