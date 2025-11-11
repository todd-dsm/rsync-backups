#!/usr/bin/env bash
# ------------------------------------------------------------------------------
#  PURPOSE: A QnD script for Linux guys abroad. I'm currently sticking it out
#           with the macOS but I don't have to trust Time Machine. Rsync just
#           makes more sense (to me) and I have to use it elsewhere anyway. This
#           works for:
#               *Linux Workstation
#               *The macOS
#               *Linux Servers
# ------------------------------------------------------------------------------
#  PREREQS: a)
#           b)
# ------------------------------------------------------------------------------
#  EXECUTE: ./install-backups.sh --macos
# ------------------------------------------------------------------------------
#set -x


###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
# Variables should be initialized to a default or validated beforehand:
verbose=0
rsync_home="$HOME/.config/rsync"
specf_dest="$HOME/.config/admin/backup"


###----------------------------------------------------------------------------
### Functions
###----------------------------------------------------------------------------
### Turn on debug output if requested
###---
debug_ouput() {
    if [[ "$verbose" -ne '1' ]]; then
        set -x
    fi
}

###---
### Display Help message
###---
show_help()   {
    printf '\n%s\n\n' """
    Please review this help information and try again.
    Description: Copy rsync backup scripts to Linux/macOS User Space, or
                 Copy rsync backup scripts to Linux Server system
    Usage: ./install-backups.sh [OPTION1] [OPTION2]...

    OPTIONS:
    -l, --linux       Copy backup scripts to Linux Workstation user space
                      Example: ./install-backups.sh --linux

    -m, --macos       Copy backup scripts to macOS user space
                      Example: ./install-backups.sh -v -m

    -s, --server      Copy backup scripts to Linux Server system.
                      Example: ./install-backups.sh --verbose --server

    -v, --verbose     Turn on 'set -x' debug output.
    """
}


###---
### Build it!
###---
success_message() {
    myBackupScript="$1"
    myBackupScript="${myBackupScript//$HOME\/}"
    printf '\n%s\n\n' """
        The files supporting backups have been installed!

        Exclusion patterns defined here:
        https://download.samba.org/pub/rsync/rsync.1

        Backups could be scheduled by adding this to crontab
        See this video for help: https://youtu.be/UlVqobmcPuM?t=2m16s
        $ crontab -e

        Then add a job that looks something like this:
        # Nightly backup jobs
        @daily \"\$HOME/${myBackupScript}\" > /dev/null 2>&1

        See: https://crontab.guru/ for more on crontab scheduling options.
    """
}

###---
### Create supporting directoris
###---
mkBackupDirs() {
    [ -d "$rsync_home/logs" ] || mkdir -p "$rsync_home/logs"
    [ -d "$specf_dest" ]      || mkdir -p "$specf_dest"
}

###---
### Workstation config
###---
#workstation_backups() {
#    src_backup_script='sources/linux_backups.sh'
#    specf_dest="$rsync_home/backups"
#    src_excludes='sources/linux_excludes'
#    dst_excludes="$rsync_home/excludes"
#    printf '\n\n%s\n' "Installing backup script, et al."
#    mkBackupDirs
#    yes | cp -pv "$src_backup_script" "$specf_dest"
#    yes | cp -pv "$src_excludes" "$dst_excludes"
#    printf '\n%s\n' "Insuring proper permissions."
#    chmod u+x "$specf_dest"
#    success_message "$specf_dest"
#}

###---
### macOS Config
###---
macos_backups() {
    src_backup_script='sources/macos_backups.sh'
    dst_backup_script="$rsync_home/backups"
    src_excludes='sources/macos_excludes'
    dst_excludes="$rsync_home/excludes"
    src_spec_files='sources/special-backups.conf'
    printf '\n\n%s\n' "Installing backup script, et al."
    mkBackupDirs
    cp -fpv "$src_backup_script" "$dst_backup_script"
    cp -fpv "$src_excludes" "$dst_excludes"
    cp -fpv "$src_spec_files" "$rsync_home"
    printf '\n%s\n' "Insuring proper permissions."
    chmod u+x "$dst_backup_script"
    success_message "$dst_backup_script"
}

###---
### Server Config
###---
#server_backups() {
#    rsync_home="$HOME/.config/rsync"
#    src_backup_script='sources/server_backups.sh'
#    specf_dest="$rsync_home/backups"
#    src_excludes='sources/server_excludes'
#    printf '\n\n%s\n' "Installing backup script, et al."
#    mkBackupDirs "$rsync_home/logs"
#    cp -fpv "$src_backup_script" "$src_excludes" "$rsync_home"
#    printf '\n%s\n' "Insuring proper permissions."
#    chmod u+x "$specf_dest"
#    success_message "$specf_dest"
#}

###---
### These 2 functions only exist to test this script. They should only be used
### when further expanding it.
###---
#print_error_noval() {
#    printf 'ERROR: "--file" requires a non-empty option argument.\n' >&2
#    exit 1
#}
## FUNCTION: confirm the argument value is non-zero and
#test_opts() {
#    myVar=$1
#    if [[ -n "$myVar" ]]; then
#        export retVal="$myVar"
#    else
#        print_error_novas
#    fi
#}


###-----------------------------------------------------------------------------
### MAIN PROGRAM
###-----------------------------------------------------------------------------
### Parse Arguments
###---
#set -x
#echo "$@"
#echo "$#"
while :; do
    case "$1" in
        -h|-\?|--help)
            show_help
            exit
            ;;
        -l | --linux)       # Linux Workstation
            #workstation_backups
            printf '%s\n' "The Linux script isn't quite ready yet."
            shift 2
            break
            ;;
        -m | --macos)       # macOS
            macos_backups
            shift 2
            break
            ;;
        -s | --server)      # Linux Server
            printf '%s\n' "The Server script isn't quite ready yet."
            #server_backups
            #test_opts "$2"
            #echo "$#"
            #echo "$@"
            shift 2
            break
            ;;
        -v | --verbose)
            #verbose=$((verbose + 1))
            debug_ouput
            ;;
        --) # End of all options.
            shift
            break
            ;;
        -?*)
            printf '%s' '  WARN: Unknown option (ignored):' "  '$1'" >&2
            printf '\n%s\n\n' '  Run: ./install-backups.sh --help for more info.'
            exit
            ;;
        *)  # Default case: If no more options then break out of the loop.
            show_help
            break
    esac
    shift
done


###----------------------------------------------------------------------------
### Wrap it up
###----------------------------------------------------------------------------


###---
### fin~
###---
exit 0
