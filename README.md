# rsync-backups

Various reusable rsync scripts for Linux and macOS.

You are more than welcome to use thist stuff to backup your system(s), I do. Here's what you have to know:

1. It's not done yet; only the macOS backup is deemed "solid" and even that can change.

2. I backup to a USB 3 drive available at `/Volumes/storage/`.

* Anyone that uses this will as well.

* To determine the name of your backup volume (backupVol) just plug it in and:

`ls -l /Volumes/` you'll see everything listed under that directory. Let's say it's called `myusb`. You would set that by: (for example)

Using [sed] to replace `'usbDrive'` with the name of your volume:

`sed -i '/backupVol/ s/usbDrive/myusb/g' sources/macos_backups.sh`

3. You'll want to specify a directory (backupDir) within that volume.

`mkdir -p /Volumes/myusb/backups`

Then set that in the same file as well; use sed to replace `'test'` with your backup directory name.

`sed -i '/backupDir/ s/test/mybackups/g' sources/macos_backups.sh`

After that you can just execute the script based on the OS below. It goes pretty quick. Don't be alarmed - it actually worked :-)

## macOS

`./install-backups.sh --macos`

## Linux (Workstation)

`./install-backups.sh --linux`

## Server (Linux)

`./install-backups.sh --server`

The output in the terminal will tell you the rest.

## The crontab

To edit the chrontab file: `crontab -e`

Paste this into the crontab:

`@daily "$HOME/.config/rsync/backups"   >  /dev/null 2>&1`

If you don't change anything you'll be:

* backing-up 7 days a week at midnight

* the first one is full, subsequent back-ups are incremental

* The latest stuff is always in the 'current' directory; everything you need to recover will be there. Here are some helpful resources:
  * Editing the [crontab file]
  * Setting [another schedule]; one that's right for you.

Cheers,

TT

[sed]:http://sed.sourceforge.net/sed1line.txt
[crontab file]:https://youtu.be/UlVqobmcPuM?t=2m16s
[another schedule]:https://crontab.guru/
