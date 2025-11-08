# macOS Disk Utility Formatting Guide

## Use Case Comparison

| Use Case | Format | Scheme | Notes |
|----------|--------|--------|-------|
| **Native macOS Only** | APFS | GUID Partition Map | Modern, fast, snapshots support |
| | Mac OS Extended (Journaled) | GUID Partition Map | Legacy macOS format, still reliable |
| **macOS + Windows** | exFAT | GUID Partition Map | Best cross-platform, no file size limits |
| | MS-DOS (FAT32) | Master Boot Record | Universal but 4GB file size limit |
| **macOS + Linux** | exFAT | GUID Partition Map | Works with exfat-utils on Linux |
| | ext4 | GUID Partition Map | Native Linux, needs macFUSE on macOS |

## Native macOS Storage

First, plugin the USB flash drive and determine the disk index number:

```shell
diskutil list external
/dev/disk4 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *125.8 GB   disk4
```

On my system the *physical* disk is `disk4`; however yours may be different. The others (internal) are managed by macOS; ignore and never modify them. At this point we have a functional device but we still can't use it for storage yet.

## macOS Native

If you only work on macOS and never have to deal with Linux or Windows then this is the default option.

```shell
Name: storage
Format: APFS
Scheme: GUID Partition Map
```

```shell
diskutil eraseDisk APFS storage disk4
```

### Validate Expected Results

The (physical) `disk4` has been formated and a logical (synthesized) Volume has been created.

```shell
% diskutil list external
/dev/disk4 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *125.8 GB   disk4
   1:                        EFI EFI                     209.7 MB   disk4s1
   2:                 Apple_APFS Container disk5         125.6 GB   disk4s2

/dev/disk5 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +125.6 GB   disk5
                                 Physical Store disk4s2
   1:                APFS Volume storage                 79.3 GB    disk5s1
```

And, we see that the logical volume is mounted:

```shell
% mount | sort
/dev/disk1s1 on /System/Volumes/iSCPreboot (apfs, local, journaled, nobrowse)
/dev/disk1s2 on /System/Volumes/xarts (apfs, local, noexec, journaled, noatime, nobrowse)
/dev/disk1s3 on /System/Volumes/Hardware (apfs, local, journaled, nobrowse)
/dev/disk3s1s1 on / (apfs, sealed, local, read-only, journaled)
...
/dev/disk5s1 on /Volumes/storage (apfs, local, nodev, nosuid, journaled, noowners)
```

This is what success looks like.

*NOTE: For those that care about such things, there is a brief explanation of macOS storage mechanics below.*

## macOS + Windows OR macOS + Linux

Universal storage between non-like systems.

```shell
Name: storage
Format: exFAT
Scheme: GUID Partition Map
```

```shell
diskutil eraseDisk exFAT storage disk4
```

Note: Linux requires exfat-fuse and exfat-utils packages

## Important Notes

- **APFS** for macOS-only usage
- Always use **GUID Partition Map** for modern systems
- **exFAT** is the best universal format for modern systems
- **FAT32** has 4GB per-file size limit (avoid for backups)
- **ext4** requires third-party drivers on macOS (macFUSE + extFS)
- **Master Boot Record** only needed for booting from USB

## How macOS Organizes Storage

APFS Disk Hierarchy Explained

`Physical Hardware > Container > Volume`

1. Physical Disk (disk4)

What it is: The actual USB hardware (SMI USB DISK Media)
Role: The physical storage device with GUID Partition Map
Capacity: 125.83 GB raw storage

2. APFS Container (disk5)

This is a logical space manager created inside `disk4`.
Role: Manages storage pool that can hold multiple APFS volumes
Relationship: `disk5` exists within the partition on `disk4`
Think of it as: A warehouse that can contain multiple rooms.

3. APFS Volume (disk5s1 - "storage")

The actual/usable filesystem you see in Finder
Role: Where your files live
Relationship: disk5s1 is a volume inside container disk5
Mount point: /Volumes/storage
Think of it as: A room within the warehouse

### The Hierarchy

```shell
disk4 (Physical USB - 125.83 GB)
  └── disk5 (APFS Container)
       └── disk5s1 (APFS Volume "storage" - 125.62 GB usable)
```

APFS Container Benefits:

Space sharing: Multiple volumes can dynamically share the same container space
Snapshots: Time Machine snapshots live in the container
Encryption: Container-level encryption protects all volumes
Flexibility: Add/remove volumes without repartitioning

Example with multiple volumes:

```shell
disk4 (Physical - 500 GB)
  └── disk5 (Container - 500 GB pool)
       ├── disk5s1 (Volume "Documents")
       ├── disk5s2 (Volume "Photos")
       └── disk5s3 (Volume "Backups")
```

All three volumes share the 500 GB pool dynamically and grows as needed. This is the standard modern macOS setup - efficient and flexible, *elegant*.
