
# Anti-virus
# Lab 2 - Simple Antivirus Daemon

Usage: ./antivirusd.sh dir malicious_dir interval-secs

Detection lists are hardcoded at the top of antivirusd.sh:
- flagged_extension: exe bat vbs scr ps1
- flagged_keywords: virus trojan malware worm ransomware
