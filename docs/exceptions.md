# Backup Exceptions

The page outlines two override mechanisms:

* The `excludes` file, and
  * This file defines file or directories that will be omitted from backups.
* The `special-backups.conf` configuration file.
* This file defines files in non-backup directories that still need to be backed up.

## The Excludes File

I run a lot of experiments and, as a result, I need to exclude a lot of stuff. You have my `excludes` file; not everything in this file will be necessary for you.

If you see something important to you is not beingbacked up then just comment or remove the line causing the restriction.

## The Special Backups Config

This is the inverse of the excludes file; this will ensure that important files are backed up from locations we typically don't want to include. Example:

The `Library` directory holds files and directores that would simply be re-created by reinstalling an application; there's rarely ever a reason to backup anything under it...

Except a few things, one being my Cursor config file. If I lost that, I would be very unhappy. So, in this comma separated file:

I've defined the name in the first column `cursor` and the file location (minus `$HOME`) in the second column.

```shell
% cat ~/.config/rsync/special-backups.conf
# backup random files and follow the format; $HOME is assumed
cursor,Library/Application Support/Cursor/User/settings.json
foo,bar/baz.ext
```

The next special (example) program, `foo` is driven by a config that needs to be backed up from location `bar/baz.ext`, and so on.

## The Restoration

These files will be copied from their specified locations to:

```shell

% ll ~/.config/admin/backup
-rw-r--r--  1 USER 2241 Nov  8 08:25 cursor-settings.json
-rw-r--r--  1 USER    0 Nov  8 08:25 foo-bar.baz
-rw-r--r--  1 USER 3944 Sep 11  2022 zshrc
```

Afterwards, the backup will run and these files are transfered to the storage device `/Volumes/storage/backups/USER/current/.config/admin/backup`, where they will be safe.
