# CPU hogs over time - lightweight logger

## Summary

These are instructions on how to make a LIGHTWEIGHT log of heavy processes that consume 100% CPU.

Heavy processes that consume 100% CPU for up to minutes are windows search, windows installs and windows defender. 
Less obvious cases are Chrome testing and Windows telemetry. 
This is a very good list to understand these processes: https://www.howtogeek.com/268337/what-is-this-process-and-why-is-it-running/

In general you see these processes in Task manager. However this lacks a time series log for later inspection.\
An extremely powerful, but quite complex and heavy solution is to use the Windows Performance Tools.\

Below a much simpler approach to approximate this using Process Monitor.

original idea : https://superuser.com/questions/453909/log-cpu-by-process-over-time


## Step by Step instructions

Please follow these instructions how to generate a LIGHTWEIGHT 100% processes CPU graph.
By default this gets 15K events per second;\
with some configuration you can get this to only ~300 events per second (=1M per hour), so that you can run this for a long time.

  
### Installation
* download process monitor (https://docs.microsoft.com/en-us/sysinternals/downloads/procmon)
* start it (1st time), then use the following shortcuts in sequence:

### Configuration:

* CTRL+E: Stop capture 
* CTRL+X: remove packets
* CTRL+R: Reset filter
* Toolbar:
  * DISABLE all events on the very right side of the toolbar (ie, 4x icons) all type of events (4x icons on very right side of tab bar)
  * ENABLE the last type of event (very last icon on tab bar - see picture)
* Menus: 
  * Filter / Drop filtered packets = ON
  * options / history depth: 10 Million
  * Options / Profiling events OFF
     
### Capture:
* CTRL+E: Start capturing
  * very important: confirm that you are getting about ~300 events per second.
  * if you are getting more
* Run a CPU-heavy for some seconds for testing purposes:  
  * ie: powerMAX, cpu-z benchmark tab, etc 
* CTRL+E: Stop capturing

### Analysis:
* Tools / Process activity summary
  * in the new window, sort by CPU
  * Double click process to see a detailed timeline
* Column detail, "user time" string
  * this will be the accumulated user time. In my 8-logical cores machines this grows 8s for every 1 second of real time
  * out of scope: CPU parking - see this link to DISABLE that. https://coderbag.com/product/quickcpu

## Picture

Configuration export: [ProcmonConfiguration.pmc](ProcmonConfiguration.pmc)

!light_monitor![light_monitor.jpg?raw=true "light_monitor.jpg"]

