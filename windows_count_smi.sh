#!/bin/bash


set -u
set -e


function display_help_short()
{
  echo "
  
Displays the count of SMI (System Management Interrupts) / SMM (System Management Mode) in Windows.
It also saves a log file to show average events per hour.

Options:
 -g: show log file
 -h: display help
 -H: installation / tutorials
 
Stats:    
 -s: minimum events to save file
 -S: minimum events to show to screen
 -m: Show passage of time (minutes) with a dot
 
 
 IMPORTANT: use -H for installation and tutorial help!
 
"
  
 
}

 
function display_help_full()
{
  display_help_short

  echo "
    
a) Pre-requisites:
  - WSL
  - Windows Kernel Debugger:
    - install windows SDK, select ONLY 'Debugging Tools for Windows'
    - https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/
  
  
b) To INSTALL this script:
  - Disable secure boot in BIOS
  - Enable debug in windows kernel  (bcdedit.exe -debug on)
    - https://alfredmyers.com/2017/11/26/the-system-does-not-support-local-kernel-debugging/
  - Reboot
  
  
c) To measure SMI LATENCY impact:
  - Run IDTL (In Depth Latency Tests) with HIGH_LEVEL IRQL
  - https://www.resplendence.com/latencymon_idlt
  - https://www.resplendence.com/latencymon_cpustalls
  
  
c2) To use Windows Performance Analyser (WPR/WPA) and the Event Tracing for Windows (ETW):
  - Tutorial1: https://superuser.com/questions/527401/troubleshoot-high-cpu-usage-by-the-system-process
    - if you get error 0x80071069: get more free disk space
  - Driver verifier info: https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/driver-verifier?redirectedfrom=MSDN#how_to_control_dv  
  - tutorial2: https://www.sysnative.com/forums/threads/how-to-diagnose-and-fix-high-dpc-latency-issues-with-wpa-windows-vista-7-8.5721/ 
  
 
d) About the Intel register that counts SMIs:
  - MSR register info:
    - https://stackoverflow.com/questions/50790715/is-there-a-way-to-determine-that-smm-interrupt-has-occured/
    - See chapter 34 of https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-3c-part-3-manual.pdf
 
  - How-to read the MSR in windows:
    - rdmsr: https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/rdmsr--read-msr-
    - Old info about PI: https://kevinwlocke.com/bits/2017/03/27/checking-msrs-for-x2apic-in-windows/
     
 
e) Disabling windows Telemetry
  - main article: https://www.neweggbusiness.com/smartbuyer/windows/should-you-disable-windows-10-telemetry/
    - python program: https://github.com/10se1ucgo/DisableWinTracking
    - other program: https://www.reddit.com/r/computertechs/comments/3kn4cf/mtrt_microsoft_telemetry_removal_tool_v10/
    - group policies list: https://docs.microsoft.com/en-us/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services#BKMK_WiFiSense
    - ultimate windows tweaker - security and privacy tab
     
 - to install group policy on windows 10 home:
   - microsoft: https://www.itechtics.com/enable-gpedit-windows-10-home/  / powershell script / then gpedit.msc 
   - open source: https://github.com/Fleex255/PolicyPlus#download
   
   
e) How to find the BIOS update history in Dell:
  - Dell update logs: C:\ProgramData\Dell\UpdateService\Log  
  - Activity.log:
    - log format: https://www.dell.com/support/manuals/ie/en/iebsdt1/dell-command-update-v2.3/dcu_ug_2.3/activity-log?guid=guid-31fdd315-57c4-48d5-9847-a3f9f1dd86d7&lang=en-us
    - iconv -f UTF-16LE -t UTF-8 ./Activity.log  -o - | tr [:upper:] [:lower:] | awk '/timestamp/{a=$0} /installing/{ print a, $0; }' |  sed -e 's/<[^>]*>/ /g;s/t/ /;s/\./ /' | dos2unix > activity.txt
    - cat activity.txt | grep -i installing 
  - service.log:
    - cat Service.log | grep -i installing

    
f) How to find the Dell Support Assist log:
  - log: C:\ProgramData\Dell\SARemediation\log
  - cat DellSupportAssistRemedationService.log | egrep -i '\*process|audio'
    - this service makes a full PCI inventory every 30minutes (!)
  - tickets:
    - dell ticket:  https://www.dell.com/community/XPS/Dell-XPS-15-9560-BIOS-0-18-0-causes-SECONDS-of-SMI-latency-worse/m-p/7477967/highlight/false#M48840
    - 9560 owners thread:  http://forum.notebookreview.com/threads/xps-15-9560-owners-thread.800611/page-452#post-10988303
    - 9570 owners thread: http://forum.notebookreview.com/threads/xps-15-9570-owners-thread.817008/page-292
    - reddit: https://www.reddit.com/r/Dell/comments/ey06bu/dell_xps_15_9560_bios_smi_problems_seconds_of_smi/
    
    
g) Using the WPA     
    
"

}

# todo: add usb device dump, versions, etc


function pass()
{
  local dummy=1

}

function global()
{
  # this is a global variable 
  pass
}



function returns()
{
  # this is a global variable that contains the return string from this function
  pass
}

function private()
{ 
  # this is a global variable that is supposed to only be used inside a function
  pass
}

function die()
{
  echo "$@"
  exit 1

}


function get_smi_count()
{
  local to_exec
  local output
  returns counter
  
  kernel_debugger_dir="/mnt/c/Program Files (x86)/Windows Kits/10/Debuggers/x64"
  kernel_debugger_file="kd.exe"

  to_exec="${kernel_debugger_dir}/${kernel_debugger_file}"

  RET=0
  output="$(  "${to_exec}" -kl -c "RDMSR 0x34;q" 2>&1 )" || RET=$?
  
  if [ $RET -ge 1 ]; then
    echo "$output"
    echo ""
  
    echo "******"
    die "ERROR: Cannot call KD. Please confirm this WSL terminal has windows administrator priviledges (ie, not sudo!), and kernel is enabled for debugging"
  fi
  
  #time="$( echo "$output" | grep "msr\[34\]"  | sed 's/`/ /' | awk --non-decimal-data '{ printf("%d", "0x"$NF ); }' )"
  counter="$( echo "$output" | grep "msr\[34\]"  | sed 's/`/ /' | awk --non-decimal-data '{ printf("%d", "0x"$NF ); }' )"
  
  get_date
}

function get_date()
{
  returns now
  
  now="$( date +"%s.%N" )"
}

function convert_human_date()
{
  local epoch_date="$1"
  local human_date
  
  human_date="$( date --date "@${epoch_date}"  +%H:%M:%S.%N  )"
  echo "$human_date"
}

function convert_human_date_full()
{
  local epoch_date="$1"
  local human_date
  
  human_date="$( date --date "@${epoch_date}"  --iso-8601=ns  )"
  echo "$human_date"
}
 
 
function show_last_log()
{
  $0 -g | tail -n 5

} 

function start_program()
{
  global start_time
  
  
  
  
  min_passage_time_seconds="$(( 60 * min_passage_time_minutes ))"

  get_date
  start_time="$now"
  last_refresh="$now"
  
  if [ "$min_to_report_screen" -gt "$min_to_report_stats" ]; then
    die "Min_screen is bigger than Min_stats"
  fi
  
  
  echo ""
  echo "SMI WSL counter"
  echo "  started at: $( convert_human_date $start_time )"
  echo "  will append stats to: $stats_file"

  echo ""  
  echo "Config:"
  echo "  min_to_report_screen:     $min_to_report_screen"
  echo "  min_to_report_stats:      $min_to_report_stats"
  echo "  min_passage_time_minutes: $min_passage_time_minutes"

  echo ""
  echo "Last log:"
  show_last_log
  
  echo ""
  echo "Running, use 'q' to quit:"
  echo ""
  
  dump_stats_start 
}


function end_program()
{
  global start_time
  
  get_date
  stop_time="$now"
  
  time_elapsed_s=$( hrtime_subtract "$now" "$start_time" )
  time_elapsed_h=$( hrdelta_divide "$time_elapsed_s" 3600 ) 
  
  dump_stats_stop
  
  echo "End time: $( convert_human_date $stop_time )"
  echo "stats file: ${stats_file}"
  echo "Analysis duration: ${time_elapsed_s} seconds"
  echo "Analysis duration: ${time_elapsed_h} hours"

  echo ""
  exit 0
}

function log_screen()
{
  global now delta

  echo "$( convert_human_date $now ): $@"
}


function dump_human_smi()
{
  global now delta
  
  log_screen "$delta SMI events seen this second"
 
}

function dump_stats_stop()
{
  dump_stats_string "STOP"

}


function dump_stats_start()
{

  dump_stats_string "START"

}

function dump_stats_string()
{
  global now  delta
  local command="$1"
  local test_desc="$test_description"
  
  echo ""
  echo "$( convert_human_date_full $now ) $now $command '$test_desc'" >> "$stats_file"
  echo ""
 
}


function dump_stats_smi()
{
  global now  delta
  
  echo "$( convert_human_date_full $now ) $now SMI $delta" >> "$stats_file"

}

function hrdelta_divide()
{
  local a="$1"
  local b="$2"
  local precision=1

  ret="$( echo "$a" "$b" | awk '{ret=($1/$2); printf("%.1f", ret)}'; )"
  echo "$ret"

}


function hrtime_subtract()
{
  local a
  local b
  local ret
  
  a="$1"
  b="$2"
  
  ret="$( echo "$a" "$b" | awk '{print int($1-$2)}' )"
  echo "$ret"

}


function show_passage_of_time()
{
  local time_elapsed
  private last_refresh
  
  time_elapsed=$( hrtime_subtract "$now" "$last_refresh" )
  #echo "$time_elapsed $now $last_refresh"
  
  if [ "$time_elapsed" -ge "$min_passage_time_seconds" ]; then
    #echo -n "."
    log_screen "."
  
    last_refresh="$now"
  fi
  
}


stats_file="$HOME/windows_home/smi_count.stats"

last_counter=0
counter=0
sleep_time="0.1"            # not used!
min_to_report_screen=10
min_to_report_screen=1
min_to_report_stats=30

min_passage_time_minutes=5

get_smi_count
last_counter="$counter"
test_description="none"
has_test_description=0

while [ "$#" -ge 1 ]; do
  case "$1" in
  -h|--help)
    display_help_short
    exit 0
    ;;
    
  -d)
    set -x
    ;;
    
  -H|--full_help)
    display_help_full
    exit 0
    ;;
    
  -s)
    min_to_report_stats="$2"
    shift
    ;;
    
  -S)
    min_to_report_screen="$2"
    shift
    ;;
    
  -m)
    min_passage_time_minutes="$2"
    shift
    ;;
    
  
    
  -g)
    cat "$stats_file" | grep SMI | sed 's/T/ /'
    exit 0
    ;;
    
  -*)
    die "unknown option"
    ;;
    
  *)
    test_description="$1"
    has_test_description=1
    ;;
  esac
  
  shift 1
done
 
if [ $has_test_description -eq 0 ]; then
  read -p "Please input your test description:  " test_description
  
fi

start_program

while true ; do
  
  #sleep 1
  get_smi_count
  delta=$((  ${counter} - ${last_counter} ))
  
  if [ $delta -ge $min_to_report_screen ]; then
    dump_human_smi
  fi

  if [ $delta -ge $min_to_report_stats ]; then
    dump_stats_smi
  fi

  show_passage_of_time
  
  last_counter="${counter}"
  
  RET=0
  read -t 0.1 -n 1 answer    || RET=$?
  
  if [[ $RET -eq 0 && "$answer" == "q" ]]; then
    break
  fi
  
done

end_program
 
 
exit 0


13:52:05.061906500: 42 SMI events seen this second
14:07:05.002522400: 42 SMI events seen this second
14:22:05.829169000: 42 SMI events seen this second
14:37:05.991508000: 42 SMI events seen this second
14:45:27.461490100: 194 SMI events seen this second
14:52:04.874453000: 42 SMI events seen this second
15:07:04.724955500: 42 SMI events seen this second


 
 