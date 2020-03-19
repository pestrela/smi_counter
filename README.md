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
   
Note: run "windows_count_smi.sh -H" for more help text and links.
   
# Results

## Example of an audio glitch

here: [example_audio_glitch.mp3](example_audio_glitch.mp3) / [alternative link](https://www.dropbox.com/s/16fa74u45qw846y/example_audio_glitch.mp3?dl=0)

## 0) UPDATE

* Previously I recommended to disable the services. 
  * This is not enough. Something reactivated the services some week(s) later.
* **New recommendation:** Un-Install **all** Dell sofware with has "support" in the title.

![dell_support_assist3](dell_support_assist3.jpg?raw=true "Dell SMI")


## a) Dell SupportAssist problems

The service "Dell SupportAssist" causes SECONDS of latency every 30 minutes (XPS 15-9560/BIOS 1.18.0)
 
 
**Issue:**
* the Dell SupportAssist service does a **deep PIC scan** for inventory purposes every 30 minutes. 
* This causes 192x ring-2 SMI interrupts that lock the laptop for whole seconds. SMIs run below the kernel and a possible hypervisor.
* This Dell service was already preinstalled in  my XPS 15-9560 laptop


**Environment:**
* Dell XPS 15-9560
* BIOS: 1.18.0, 1.16.0 and 1.12.1 were tested
* SupportAssist: 3.4.1 + 5.0.1.10874
* Windows 10 home: 18363
* All latest drivers and services from Dell ([link](https://www.dell.com/support/home/ie/en/iedhs1/product-support/product/xps-15-9560-laptop/drivers))


**Fixes:**
* ~~**Services**: Disabling this service in **services.msc** avoids the issue completely.~~
  * Something re-enables the service after some weeks. [Instead, uninstall the software completely.](#0-update) 
* **Lower Priority:** no effect at all (see "ring -2" concept, below)


**windows_count_smi log:**
* 2020-02-22 13:19:28,504033800+00:00 1582377568.504033800 SMI 192
* 2020-02-22 13:49:29,709938000+00:00 1582379369.709938000 SMI 192
* 2020-02-22 14:19:31,464194900+00:00 1582381171.464194900 SMI 192
* 2020-02-22 14:49:32,292745300+00:00 1582382972.292745300 SMI 192

**C:\ProgramData\Dell\SARemediation\log\DellSupportAssistRemedationService.log**
* 20-02-22 13:19:26,938 [4] [ERROR] Failed to detect audio playing. #StackInfo#
* 20-02-22 13:49:28,208 [4] [ERROR] Failed to detect audio playing. #StackInfo#
* 20-02-22 14:19:29,470 [4] [ERROR] Failed to detect audio playing. #StackInfo#
* 20-02-22 14:49:30,732 [4] [ERROR] Failed to detect audio playing. #StackInfo#

## b) Other Dell services problems

* Some other of the Dell services causes 42x SMIs every 15 minutes
  * **Recommendation:** disable all Dell services to avoid SMIs
* If you install the DellSupportAssist GUI, you can configure a weekly hardware scan
  * However I haven't seen any difference on the 192x and 42x SMI problems


**windows_count_smi log:**
* 2020-02-27 10:38:44,527207400+01:00 1582796324.527207400 SMI 42
* 2020-02-27 10:53:44,372286700+01:00 1582797224.372286700 SMI 42
* 2020-02-27 11:08:45,207355200+01:00 1582798125.207355200 SMI 42
* 2020-02-27 11:23:44,360058300+01:00 1582799024.360058300 SMI 42
* 2020-02-27 11:38:44,490156400+01:00 1582799924.490156400 SMI 42


## Tickets

* [Dell Ticket](https://www.dell.com/community/XPS/Dell-SupportAssist-causes-SECONDS-of-latency-every-30m-XPS-15/m-p/7501047)
* [Dell Drivers](https://www.dell.com/support/home/ie/en/iedhs1/product-support/product/xps-15-9560-laptop/drivers)
* [9560 owners thread](http://forum.notebookreview.com/threads/xps-15-9560-owners-thread.800611/page-452#post-10988303/)
* [9570 owners thread](http://forum.notebookreview.com/threads/xps-15-9570-owners-thread.817008/page-292)
* [reddit](https://www.reddit.com/r/Dell/comments/ey06bu/dell_xps_15_9560_bios_smi_problems_seconds_of_smi/)



------------------------
------------------------
    
# Summary Slides
    
## Ring -2 Concept 
  
![dell_support_assist1](dell_support_assist1.jpg?raw=true "Dell SMI")

## WPA (windows performance analyser)

![dell_support_assist2](dell_support_assist2.jpg?raw=true "Dell SMI")

## Services to disable

![dell_support_assist3](dell_support_assist3.jpg?raw=true "Dell SMI")



