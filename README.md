# Lab 2 - Simple Antivirus Daemon

A shell-based antivirus daemon that monitors a directory and quarantines
malicious files, a restore tool to review quarantined files, and a Makefile
to run both.

## 1. Overview and folder hierarchy

    Anti-virus/
    |-- antivirusd.sh   # antivirus daemon (monitors, scans, quarantines)
    |-- restore.sh      # restore tool (review quarantined files)
    |-- Makefile        # targets to run both tools
    |-- README.md       # this file
    |-- .gitignore      # ignores runtime files

Created while running :

- test_dir/ : the monitored directory
- malicious_dir/ : the quarantine directory
- directory-info.last / directory-info.new : directory snapshots used to detect changes

**antivirusd.sh** polls a directory every few seconds. When the `ls -l` output
changes (or on the first run), it scans every file. Malicious files are
printed, copied to the quarantine directory, and deleted from the original
directory.

**restore.sh** lists the quarantined files and lets you pick one by number.
You can restore it to the monitored directory (false positive), delete it
permanently (genuinely malicious), or leave it and go back to the list.

**Makefile** has a `prebuild` step that creates malicious_dir if it does not
exist, plus targets to run each tool.

## 2. Prerequisites (Ubuntu)

Bash and the standard tools (ls, cmp, grep, cp, mv, rm, sleep) come with
Ubuntu. You also need make and git:

    sudo apt update
    sudo apt install make git

Check the installation:

    make --version
    git --version

## 3. How to run

Get the code and make the scripts executable:

    git clone https://github.com/Mohab-Tantawy/Anti-virus.git
    cd Anti-virus
    chmod u+x antivirusd.sh restore.sh
    mkdir -p test_dir

### Run the antivirus daemon

With make:

    make antivirus

Or directly:

    ./antivirusd.sh test_dir malicious_dir 3

- test_dir: directory to monitor (files only, no subdirectories)
- malicious_dir: where quarantined files are copied (created if missing)
- 3: seconds to wait between checks

The daemon prints `<file> is malicious and it is DELETED` for each detected
file, then waits quietly. Stop it with Ctrl+C.

To test it, open a second terminal and run:

    echo "this has a virus" > test_dir/bad.txt
    echo "x" > test_dir/run.exe

### Run the restore tool

Stop the daemon first. The two tools must not run at the same time.

With make:

    make restore

Or directly:

    ./restore.sh test_dir malicious_dir

1. Pick a file by its number (0 quits).
2. Choose 1 to restore it to test_dir, 2 to delete it permanently, or 3 to
   leave it and go back to the list.

### Using make

    make antivirus    # runs prebuild, then ./antivirusd.sh test_dir malicious_dir 3
    make restore      # runs prebuild, then ./restore.sh test_dir malicious_dir

The `prebuild` target is the pre-build step: it runs `mkdir -p malicious_dir`.
Both targets depend on it. Defaults can be overridden:

    make antivirus DIR=mydir MAL_DIR=quarantine INTERVAL=5

## 4. Where the detection lists are defined

Both lists are hardcoded at the top of `antivirusd.sh`:

- `flagged_extension`: exe bat vbs scr ps1
- `flagged_keywords`: virus trojan malware worm ransomware

A file is malicious if its extension matches `flagged_extension`, or if its
contents contain any word from `flagged_keywords` (case-insensitive).
