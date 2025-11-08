# rsync-backups

The rsync script for macOS backups. All you need to get started is an inexpensive USB flash drive and about 15 minutes.

## Getting Started

### Format the Drive

If you only work on macOS then this is the most flexible option:

1. Open the macOS Disk Utility
2. highlight your device and
3. format with these options:

```shell
Name: storage
Format: APFS
Scheme: GUID Partition Map
```

Validate that the volume mounts on the system:

```shell
% mount | sort
/dev/disk1s1 on /System/Volumes/iSCPreboot (apfs, local, journaled, nobrowse)
/dev/disk1s2 on /System/Volumes/xarts (apfs, local, noexec, journaled, noatime, nobrowse)
/dev/disk1s3 on /System/Volumes/Hardware (apfs, local, journaled, nobrowse)
...
/dev/disk5s1 on /Volumes/storage (apfs, local, nodev, nosuid, journaled, noowners) <- success!
```

```shell
% ls -l /Volumes
total 0
drwxr-xr-x 3 root    96 Jun 11  2022  Data
lrwxr-xr-x 1 root     1 Oct 31 07:59 'Macintosh HD' -> /
drwxrwxr-x 5 $USER  160 Oct 24 09:05  storage <- success!
```

There is a longer explanation on [macOS Storage options] if needed.

### Install the Backup Script

Clone this repo and execute:

`% ./install-backups.sh --macos`

*NOTE: This may support other OSs someday (but probably not).*

The script places these files here:

```shell
% tree ~/.config/rsync
/Users/$USER/.config/rsync
├── backups
├── excludes
├── logs
│   └── backup-friday.log
└── special-backups.conf

2 directories, 4 files
```

NOTE: the files added to `special-backups.conf` will be included in backups while the `excludes` list will, of course, omit files/paths from backups; edit these files to suit your needs. There's a more in-depth [description of exceptions] elsewher.

## Execute Backups

It's probably best to test everything first; execute:

```shell
% ~/.config/rsync/backups dry-run 2>&1 | tee /tmp/backups.log
```

After that you can drop the `dry-run` and it will backup your `$HOME`. If you don't have many files don't be alarmed - it likely flew right by and actually worked :-)

## Schedule Backups

Edit the chrontab file to schedule the backups: `crontab -e`

Paste this into the crontab:

`@daily "$HOME/.config/rsync/backups" > /dev/null 2>&1`

If you don't change anything you'll be:

* backing-up 7 days a week at midnight

* the first one is full (current), subsequent back-ups are incremental (days of the week)

* The latest stuff is always in the 'current' directory; everything you need to recover will be there. Here are some helpful resources:
  * Editing the [crontab file]
  * Setting [another schedule]; one that's right for you.

It should look like this after a few runs:

```shell
% tree -d -L 1 /Volumes/storage/backups/$USER
/Volumes/storage/backups/$USER
├── current <- latest; restore from here
├── friday
├── monday
├── tuesday
└── wednesday
```

I generally just run it a few times per month.

Cheers,

TT

<!-- docs/refs -->

[macOS Storage options]:https://github.com/todd-dsm/rsync-backups/blob/master/docs/disk-formatting-guide.md
[description of exceptions]:https://github.com/todd-dsm/rsync-backups/blob/master/docs/exceptions.md
[crontab file]:https://youtu.be/UlVqobmcPuM?t=2m16s
[another schedule]:https://crontab.guru/
