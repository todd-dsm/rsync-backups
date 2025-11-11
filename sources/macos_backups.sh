#!/usr/bin/env bash
#  PURPOSE: backup "$HOME" files to $backupDest with:
#               * 7 day rotating incremental backup 
#               * incrementals are named after the day of the week
#               * "current" is always a full backup with the latest files.
#           Inspired by:
#               tridge@linuxcare.com
#               http://rsync.samba.org/examples.html
# -----------------------------------------------------------------------------
#  PREREQS: a) gnu bash 4.x
#           b) rsync
#           c) USB drive with capacity
# -----------------------------------------------------------------------------
#  EXECUTE: ~/.config/rsync/backups dry-run
# -----------------------------------------------------------------------------
set -euo pipefail

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------
# Toggle dry-run mode
dryRun=""
if [[ "${1:-}" == 'dry-run' ]]; then
    dryRun="--dry-run"
    printf '\n%s\n' "Running in DRY-RUN mode (no changes will be made)"
else
    printf '\n%s\n' "Running LIVE backup"
fi

# assignments
rsync_home="$HOME/.config/rsync"
specf_conf="$rsync_home/special-backups.conf"                                  
specf_dest="$HOME/.config/admin/backup"                                           
excludeFiles="$rsync_home/excludes"
backupVol='/Volumes/storage'
backupDir="backups"
backupDest="$backupVol/$backupDir"
bkupDay="$(date +%A)"
bkupDay="${bkupDay,,}"
dailyBkup="$backupDest/$USER/$bkupDay"
rsyncOptions="--archive --backup --human-readable --verbose --stats \
    --delete --force --ignore-errors --delete-excluded $dryRun \
    --exclude-from=$excludeFiles --backup-dir=$dailyBkup"
loggingParams="--log-file=$rsync_home/logs/backup-$bkupDay.log"

                                                                                   
# ----------------------------------------------------------------------------- 
# MAIN PROGRAM                                                                     
# ----------------------------------------------------------------------------- 
# PREREQ: Ensure Volume is mounted
if [ ! -d "$backupVol" ]; then
    printf '\n%s\n' "ERROR: Backup volume not mounted at $backupVol"
    exit 1
fi

# PREREQ: Ensure logs directory exists                                             
[ -d "$rsync_home/logs" ] || mkdir -p "$rsync_home/logs"                           
[ -d "$specf_dest" ] || mkdir -p "$specf_dest"                                   


# ----------------------------------------------------------------------------- 
# process special files
# ----------------------------------------------------------------------------- 
printf '\n%s\n' "Backing up special files:"
while IFS=, read -r program source_path || [ -n "$program" ]; do
    # Skip empty lines and comments
    [[ -z "$program" || $program = \#* ]] && continue
    
    # prep the names
    source_file="$HOME/$source_path"
    filename="${source_path##*/}"
    
    if [ -f "$source_file" ]; then
        cp "$source_file" "$specf_dest/${program}-${filename}"
        printf '%s\n' "  $program"
    else
        printf '%s\n' "  $program (file not found: $source_path)"
    fi
done < "$specf_conf"


# -----------------------------------------------------------------------------
# BACKUP ROUTINE
# -----------------------------------------------------------------------------
# Clear incremental directory from last week
[ -d /tmp/emptydir ] || mkdir -p /tmp/emptydir
[ -d "$dailyBkup" ]  || mkdir -p "$dailyBkup"
rsync --delete -a /tmp/emptydir/ "$dailyBkup/"
rmdir /tmp/emptydir


# backup $HOME with logging
printf '\n%s\n' "Backing up $HOME:"
if ! rsync $rsyncOptions $loggingParams "$HOME/" "$backupDest/$USER/current"; then
    printf '\n%4s%s\n\n' '' "Backup failed with exit code: $?"
    exit 1
else
    printf '\n%4s%s\n\n' '' "Backup complete: $(date)"
fi

exit 0
