DISK_IMG := ft_linux_disk.qcow2
MOUNT_POINT := disk_mount
QEMU_SCRIPT := run_qemu.sh
QEMU_42_SCRIPT := run_qemu_42.sh

.PHONY: run mount umount status

run:
	@bash $(QEMU_SCRIPT)

42run:
	@bash $(QEMU_42_SCRIPT)

42decompress:
	@echo "Decompressing ft_linux_disk.qcow2.gz..."
	tar -xvOf /sgoinfre/students/shurtado/ft_linux_disk_final.qcow2.tar.xz | cp --sparse=always /dev/stdin /sgoinfre/students/shurtado/ft_linux_disk.qcow2
	@echo "Decompression complete. You can now run 'make 42run' to start the VM with the decompressed image."

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
	@if sudo mountpoint -q $(MOUNT_POINT) 2>/dev/null; then \
		echo "Error: $(MOUNT_POINT) is already mounted."; \
		exit 1; \
	fi
	@mkdir -p $(MOUNT_POINT)
	@echo "Mounting $(DISK_IMG) partition 3 to $(MOUNT_POINT)..."
	@sudo guestmount --rw -a $(DISK_IMG) -m /dev/vda3 $(MOUNT_POINT)
	@echo "Mounted successfully."

umount:
	@if sudo mountpoint -q $(MOUNT_POINT) 2>/dev/null; then \
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
	@if sudo mountpoint -q $(MOUNT_POINT) 2>/dev/null; then \
		echo "$(MOUNT_POINT): MOUNTED"; \
	else \
		echo "$(MOUNT_POINT): NOT MOUNTED"; \
	fi
