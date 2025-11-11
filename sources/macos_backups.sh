#!/usr/bin/env bash
#  PURPOSE: backup "$HOME" files to $backup_dest with:
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
dry_run=""
if [[ "${1:-}" == 'dry-run' ]]; then
    dry_run="--dry-run"
    printf '\n%s\n' "Running in DRY-RUN mode (no changes will be made)"
else
    printf '\n%s\n' "Running LIVE backup"
fi

# assignments
rsync_home="$HOME/.config/rsync"
specf_conf="$rsync_home/special-backups.conf"                                  
specf_dest="$HOME/.config/admin/backup"                                           
exclude_list="$rsync_home/excludes"
backup_vol='/Volumes/storage'
backup_dir="backups"
backup_dest="$backup_vol/$backup_dir"
bkup_day="$(date +%A)"
bkup_day="${bkup_day,,}"
daily_bkup="$backup_dest/$USER/$bkup_day"
log_opts="--log-file=$rsync_home/logs/backup-$bkup_day.log"
rsync_opts="--archive --backup --human-readable --verbose --stats \
    --delete --force --ignore-errors --delete-excluded $dry_run \
    --exclude-from=$exclude_list --backup-dir=$daily_bkup"

                                                                                   
# ----------------------------------------------------------------------------- 
# MAIN PROGRAM                                                                     
# ----------------------------------------------------------------------------- 
# PREREQ: Ensure Volume is mounted
if [ ! -d "$backup_vol" ]; then
    printf '\n%s\n' "ERROR: Backup volume not mounted at $backup_vol"
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
[ -d "$daily_bkup" ]  || mkdir -p "$daily_bkup"
rsync --delete -a /tmp/emptydir/ "$daily_bkup/"
rmdir /tmp/emptydir


# backup $HOME with logging
printf '\n%s\n' "Backing up $HOME:"
if ! rsync $rsync_opts $log_opts "$HOME/" "$backup_dest/$USER/current"; then
    printf '\n%4s%s\n\n' '' "Backup failed with exit code: $?"
    exit 1
else
    printf '\n%4s%s\n\n' '' "Backup complete: $(date)"
fi

exit 0
