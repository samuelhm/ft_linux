DISK_IMG := ft_linux_disk.img
MOUNT_POINT := disk_mount
QEMU_SCRIPT := run_qemu.sh

.PHONY: run mount umount status

run:
	@bash $(QEMU_SCRIPT)

mount:
	@echo "Checking if disk image is in use..."
	@if lsof $(DISK_IMG) >/dev/null 2>&1; then \
		echo "Error: $(DISK_IMG) is currently in use by:"; \
		lsof $(DISK_IMG); \
		exit 1; \
	fi
	@echo "Checking if QEMU is running..."
	@if pgrep -f "[q]emu-system.*$(DISK_IMG)" >/dev/null 2>&1; then \
		echo "Error: QEMU VM is still running. Shut it down first."; \
		exit 1; \
	fi
	@echo "Checking if already mounted..."
	@if mountpoint -q $(MOUNT_POINT); then \
		echo "Error: $(MOUNT_POINT) is already mounted."; \
		exit 1; \
	fi
	@mkdir -p $(MOUNT_POINT)
	@echo "Mounting $(DISK_IMG) partition 3 to $(MOUNT_POINT)..."
	@sudo guestmount --rw -a $(DISK_IMG) -m /dev/vda3 $(MOUNT_POINT)
	@echo "Mounted successfully."

umount:
	@echo "Checking if $(MOUNT_POINT) is mounted..."
	@if mountpoint -q $(MOUNT_POINT); then \
		echo "Unmounting $(MOUNT_POINT)..."; \
		sudo guestunmount $(MOUNT_POINT); \
		echo "Unmounted successfully."; \
	else \
		echo "$(MOUNT_POINT) is not mounted."; \
	fi

status:
	@echo "=== VM Status ==="
	@if pgrep -f "[q]emu-system.*$(DISK_IMG)" >/dev/null 2>&1; then \
		echo "QEMU VM: RUNNING"; \
		pgrep -af "[q]emu-system.*$(DISK_IMG)"; \
	else \
		echo "QEMU VM: STOPPED"; \
	fi
	@echo ""
	@echo "=== Disk Status ==="
	@if lsof $(DISK_IMG) >/dev/null 2>&1; then \
		echo "Disk image: IN USE"; \
		lsof $(DISK_IMG); \
	else \
		echo "Disk image: FREE"; \
	fi
	@echo ""
	@echo "=== Mount Status ==="
	@if mountpoint -q $(MOUNT_POINT); then \
		echo "$(MOUNT_POINT): MOUNTED"; \
	else \
		echo "$(MOUNT_POINT): NOT MOUNTED"; \
	fi
