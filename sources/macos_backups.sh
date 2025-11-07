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
#           c) insert USB drive with capacity
# -----------------------------------------------------------------------------
#  EXECUTE: ./backups dry-run
# -----------------------------------------------------------------------------
#   AUTHOR: todd-dsm (github)
# -----------------------------------------------------------------------------
set -euo pipefail

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------
# Toggle dry-run mode
dryRun=""
if [[ "${1:-}" == 'dry-run' ]]; then
    dryRun="--dry-run"
    echo "Running in DRY-RUN mode (no changes will be made)"
else
    echo "Running LIVE backup"
fi
 # assignments
backupHome="$HOME/.config/rsync"
excludeFiles="$backupHome/excludes"
backupVol='/Volumes/storage'
backupDir="backups"
backupDest="$backupVol/$backupDir"
bkupDay="$(date +%A)"
bkupDay="${bkupDay,,}"
dailyBkup="$backupDest/$USER/$bkupDay"
rsyncOptions="--archive --backup --human-readable --verbose --stats \
    --delete --force --ignore-errors --delete-excluded $dryRun \
    --exclude-from=$excludeFiles --backup-dir=$dailyBkup"
loggingParams="--log-file=$backupHome/logs/backup-$bkupDay.log"

# -----------------------------------------------------------------------------
# MAIN PROGRAM
# -----------------------------------------------------------------------------
# PREREQ: Ensure logs directory exists
[ -d "$backupHome/logs" ] || mkdir -p "$backupHome/logs"

# Backup special application configs from external file
specialBackups="$backupHome/special-backups.conf"
specialDest="$HOME/.config/admin/backup"

if [ -f "$specialBackups" ]; then
    echo "Backing up special ~/Library configs"
    mkdir -p "$specialDest"

    while IFS=, read -r program source_path || [ -n "$program" ]; do
        # Skip empty lines and comments
        [[ -z "$program" || $program = \#* ]] && continue

        # prep the names
        source_file="$HOME/$source_path"
        filename="${source_path##*/}"

        if [ -f "$source_file" ]; then
            cp "$source_file" "$specialDest/${program}-${filename}"
            echo "  ✓ $program"
        else
            echo "  ⚠ $program (file not found: $source_path)"
        fi
    done < "$specialBackups"
fi


# -----------------------------------------------------------------------------
# BACKUP ROUTINE
# -----------------------------------------------------------------------------
# PREREQ: Ensure Volume is mounted
if [ ! -d "$backupVol" ]; then
    echo "ERROR: Backup volume not mounted at $backupVol"
    exit 1
fi

# Clear incremental directory from last week
[ -d /tmp/emptydir ] || mkdir -p /tmp/emptydir
[ -d "$dailyBkup" ] || mkdir -p "$dailyBkup"
rsync --delete -a /tmp/emptydir/ "$dailyBkup/"
rmdir /tmp/emptydir

# backup $HOME with logging
if ! rsync $rsyncOptions $loggingParams "$HOME/" "$backupDest/$USER/current"; then
    echo "Backup failed with exit code: $?"
    exit 1
else
    echo "Backup complete: $(date)"
fi

exit 0
