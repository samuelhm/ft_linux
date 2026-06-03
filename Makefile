DISK_DIR := /sgoinfre/students/shurtado
DISK_IMG := ft_linux_disk.qcow2
DISK_PATH := $(DISK_DIR)/$(DISK_IMG)
TAR_FILE := $(DISK_DIR)/ft_linux_delivery.tar.gz
MOUNT_POINT := disk_mount
QEMU_SCRIPT := run_qemu.sh
QEMU_42_SCRIPT := run_qemu_42.sh

.PHONY: all help run 42run 42backup 42restore 42compress 42decompress 42shasumcheck mount umount status

all: help

help:
	@echo "====================================================================="
	@echo "                       FT_LINUX MAKEFILE HELP                        "
	@echo "====================================================================="
	@echo "Uso: make [comando]"
	@echo ""
	@echo "Comandos disponibles:"
	@echo "  help            - Muestra este menú de ayuda."
	@echo ""
	@echo "--- Arranque ---"
	@echo "  run             - Inicia la máquina virtual estándar ($(QEMU_SCRIPT))."
	@echo "  42run           - Inicia la máquina virtual para evaluación ($(QEMU_42_SCRIPT))."
	@echo ""
	@echo "--- Gestión de Evaluaciones (Snapshots y Compresión) ---"
	@echo "  42backup        - Crea un snapshot interno ('final') en el disco qcow2."
	@echo "  42restore       - Restaura el disco al estado del snapshot 'final'."
	@echo "  42compress      - Comprime el disco en $(TAR_FILE) dentro de sgoinfre."
	@echo "  42decompress    - Descomprime el disco desde el archivo .tar.gz."
	@echo "  42shasumcheck   - Verifica que la firma SHA-1 del .tar.gz sea correcta."
	@echo ""
	@echo "--- Herramientas del Sistema ---"
	@echo "  mount           - Monta la partición 3 (root) del disco en $(MOUNT_POINT)."
	@echo "  umount          - Desmonta la partición del disco de forma segura."
	@echo "  status          - Muestra si la VM está encendida y si el disco está en uso."
	@echo "====================================================================="

run:
	@bash $(QEMU_SCRIPT)

42run:
	@bash $(QEMU_42_SCRIPT)

42backup:
	@echo "Creating internal snapshot 'final'..."
	@qemu-img snapshot -c "final" $(DISK_PATH)
	@echo "Snapshot 'final' created successfully inside $(DISK_IMG)."

42restore:
	@echo "Restoring disk image from snapshot 'final'..."
	@qemu-img snapshot -a "final" $(DISK_PATH)
	@echo "Disk image restored successfully."

42compress:
	@echo "Compressing disk image into $(TAR_FILE)..."
	@tar -czf $(TAR_FILE) -C $(DISK_DIR) $(DISK_IMG)
	@echo "Compression completed successfully."

42decompress:
	@echo "Decompressing disk image..."
	@tar -xzf $(TAR_FILE) -C $(DISK_DIR)
	@echo "Decompression completed successfully."

42shasumcheck:
	@echo "Calculating SHA-1 checksum..."
	@shasum -c sum.sha1
	@echo "SHA-1 checksum verified successfully."

mount:
	@echo "Checking if disk image is in use..."
	@if lsof $(DISK_PATH) >/dev/null 2>&1; then \
		echo "Error: $(DISK_PATH) is currently in use by:"; \
		lsof $(DISK_PATH); \
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
	@sudo guestmount --rw -a $(DISK_PATH) -m /dev/vda3 $(MOUNT_POINT)
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
	@if lsof $(DISK_PATH) >/dev/null 2>&1; then \
		echo "Disk image: IN USE"; \
		lsof $(DISK_PATH); \
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
