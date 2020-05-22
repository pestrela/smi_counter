# Windows SMI counter

**This is a wrapper for the Kernel Debugger to count SMI interrupts in Windows 10.**

SMIs are special interrupts issued to the BIOS to perform special low-level operations.\
These events lock the whole computer - including all cores and the whole Operating System.

SMIs can happen at any time and are completely invisible to the OS *except* for a special CPU register.\
Because they are hidden, this confuses tools like LatencyMon/DPClatency which will put the blame in random drivers instead.

In linux the special register can be read with "sudo turbostat --msr 0x34".\
In windows 10 you will have to install the microsoft debugging SDK and enable the debug boot flag.

more info:
https://en.wikipedia.org/wiki/System_Management_Mode

   
## Download

You can run this tool with or without WSL.\
The WSL version is recommended because it offers much more features.\
The non-WSL version is very simple for manual use.

* WSL version: [windows_count_smi.sh](windows_count_smi.sh)
* non-WSL version: [windows_count_smi.cmd](windows_count_smi.cmd)


## Pre-requisites:

* Windows 10

## Installation

1. Install the microsoft "windows kernel debugger" program:
   * install windows SDK, select ONLY 'Debugging Tools for Windows'
   * https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/
1. Disable secure boot in BIOS
1. Enable debug in windows kernel  (bcdedit.exe -debug on)
   * https://alfredmyers.com/2017/11/26/the-system-does-not-support-local-kernel-debugging/
1. Reboot

## Operation (NON-WSL version)


1. start a regular CMD window in Administrator mode
1. run "windows_count_smi.cmd"

![smi_counter_non_wsl_version](smi_counter_non_wsl_version.jpg?raw=true )

## Operation (WSL version)

1. Install WSL (guide)[https://docs.microsoft.com/en-us/windows/wsl/install-win10]
1. start WSL window in administrator mode
1. run "windows_count_smi.sh"
1. To measure SMI LATENCY impact:
   * Run IDTL (In Depth Latency Tests) with HIGH_LEVEL IRQL
   * https://www.resplendence.com/latencymon_idlt
   * https://www.resplendence.com/latencymon_cpustalls
   
Note1: run "windows_count_smi.sh -H" for more help text, tutorials and links. [link](https://github.com/pestrela/smi_counter/blob/master/windows_count_smi.sh) \
Note2: some advanced analysis requires WPR/WPA/ETW. [This](https://superuser.com/questions/527401/troubleshoot-high-cpu-usage-by-the-system-process) is the best tutorial I've seen, including A LOT of examples 

![smi_counter_wsl_version](smi_counter_wsl_version.jpg?raw=true )

# Results

## Example of an audio glitch

here: [example_audio_glitch.mp3](pics/example_audio_glitch.mp3) / [alternative link](https://www.dropbox.com/s/16fa74u45qw846y/example_audio_glitch.mp3?dl=0)

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



