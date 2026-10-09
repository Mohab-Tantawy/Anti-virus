DIR = test_dir
MAL_DIR = malicious_dir
INTERVAL = 3

.PHONY: all antivirus restore rebuild

all: antivirus

prebuild:
	mkdir -p $(MAL_DIR)

antivirus: prebuild
	./antivirusd.sh $(DIR) $(MAL_DIR) $(INTERVAL)

restore: prebuild
	./restore.sh $(DIR) $(MAL_DIR)

