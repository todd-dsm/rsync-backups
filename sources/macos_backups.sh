#!/usr/bin/env bash
# MAC: BACKUP TO LOCAL STORAGE WITH 7 DAY INCREMENTAL
# This script does personal backups to $backupDest. You will end up
# with a 7 day rotating incremental backup. The incrementals will go
# into subdirectories named after the day of the week, and the current
# full backup goes into a directory called "current".
# EXECUTE: 'backup --dry-run'   to test it; else it will actually backup.
# tridge@linuxcare.com
# http://rsync.samba.org/examples.html
set -x

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
### Exclusion List
declare dryRun="$1"
declare backupHome="$HOME/.config/rsync"
declare excludeFiles="$backupHome/excludes"
declare backupVol='/Volumes/storage'                # The Volume
declare backupDir="backups"                         # Directory under Volume
declare backupDest="$backupVol/$backupDir"
#declare myHost="$(hostname)"
declare bkupDay="$(date +%A)"
declare bkupDay="${bkupDay,,}"
declare dailyBkup="$backupDest/$USER/$bkupDay"
### Add --dry-run while testing
declare rsyncOptions="--archive --backup --human-readable --verbose --stats  \
	--delete --force --ignore-errors --delete-excluded $dryRun           \
        --exclude-from=$excludeFiles --backup-dir=$dailyBkup -a"
declare loggingParams=--log-file="$backupHome/logs/backup-$(date +%F-%a.log)"


###----------------------------------------------------------------------------
### The Backup Routine
###----------------------------------------------------------------------------
### Clear incremental dirs from last week
###---
[ -d /tmp/emptydir ] || mkdir -p /tmp/emptydir
[ -d "$dailyBkup"  ] || mkdir -p "$dailyBkup"
rsync --delete -a /tmp/emptydir/ "$dailyBkup/"
rmdir /tmp/emptydir


###---
### Backup "$HOME" with logging
###---
[ ! -d "$dailyBkup" ] || mkdir -p "$dailyBkup"
sudo rsync $rsyncOptions "$loggingParams" "$HOME/" "$backupDest/$USER/current"

exit 0
