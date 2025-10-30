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
#  EXECUTE: ./install-backups.sh --opt1 --opt2
# ------------------------------------------------------------------------------
#     TODO: 1) Clean this thing up; so gross.
#           2) Add sources for Linux Workstation & Linux Server
# ------------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# ------------------------------------------------------------------------------
#set -x

###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
# Variables should be initialized to a default or validated beforehand:
verbose=0


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

        However, you still need to schedule it to run by editng the crontab.
        See this video for help: https://youtu.be/UlVqobmcPuM?t=2m16s
        $ crontab -e

        Then add a job that looks something like this:
        # Nightly backup jobs
        @daily \"\$HOME/${myBackupScript}\"   >  /dev/null 2>&1

        See: https://crontab.guru/ for more on crontab scheduling options.
    """
}

###---
### Build it!
###---
mkBackupDirs() {
    backupPaths="$1"
    printf '\n%s\n' "Checking directories for backup script home"
    if [[ ! -d "$backupPaths" ]]; then
        printf '%s\n' "  Creating rsync backup script home..."
        mkdir -p "$backupPaths"
    else
        printf '%s\n' """
        It already exists!
        Check yourself before you overwrite something important:
        """
        printf '%s\n' "${backupPaths%/*}"
        ls -lh --color "${backupPaths%/*}"
        printf '%s\n' ""
        exit
    fi
}

###---
### Workstation config
###---
#workstation_backups() {
#    rsyncHome="$HOME/.config/rsync"
#    instBackupScript='sources/linux_backups.sh'
#    destBackupScript="$rsyncHome/backups"
#    instExcludes='sources/linux_excludes'
#    destExcludes="$rsyncHome/excludes"
#    printf '\n\n%s\n' "Installing backup script, et al."
#    mkBackupDirs "$rsyncHome/logs"
#    yes | cp -pv "$instBackupScript" "$destBackupScript"
#    yes | cp -pv "$instExcludes" "$destExcludes"
#    printf '\n%s\n' "Insuring proper permissions."
#    chmod u+x "$destBackupScript"
#    success_message "$destBackupScript"
#}

###---
### macOS Config
###---
macos_backups() {
    rsyncHome="$HOME/.config/rsync"
    instBackupScript='sources/macos_backups.sh'
    instExcludes='sources/macos_excludes'
    instSpecFiles='sources/special-backups.conf'
    printf '\n\n%s\n' "Installing backup script, et al."
    mkBackupDirs "$rsyncHome/logs"
    cp -fpv "$instBackupScript" "$instExcludes" "$instSpecFiles" "$rsyncHome"
    printf '\n%s\n' "Insuring proper permissions."
    chmod u+x "$destBackupScript"
    success_message "$destBackupScript"
}

###---
### Server Config
###---
#server_backups() {
#    rsyncHome="$HOME/.config/rsync"
#    instBackupScript='sources/server_backups.sh'
#    destBackupScript="$rsyncHome/backups"
#    instExcludes='sources/server_excludes'
#    printf '\n\n%s\n' "Installing backup script, et al."
#    mkBackupDirs "$rsyncHome/logs"
#    cp -fpv "$instBackupScript" "$instExcludes" "$rsyncHome"
#    printf '\n%s\n' "Insuring proper permissions."
#    chmod u+x "$destBackupScript"
#    success_message "$destBackupScript"
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
