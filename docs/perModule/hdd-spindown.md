# HDD Spindown
It's a common practice to stop HDD disks that are not used after a certain amount of time. It allows to save power and reduce noise. This module does exactly that.

## Options
- `enable` -> enable this module
  
  -> default: `false`

- `timeoutSeconds` -> number of seconds after what idle HDDs will be stopped
  
  -> default: `1200` seconds (20min)

> [!TIP]
> It's commonly accepted that stopping and restarting a disk too often can reduce it's lifetime to an extent.<br>
> The actual 1200s (20min) default timeout suits well for a personal home server / NAS type setup, where you either use it or not, and appreciate having less noise/power consumption. (This is what this flake targets).
> 
> For a setup hosting a web app or some service that often and regularly use disks at random times, it's advised to set it to at least 3600s (1h).
