#!/bin/bash
# Optimized for AMD Ryzen AI 7 350 (8C/16T, 30GB RAM, KVM/AMD-V)
# Boots from CD-ROM (ISO) first, falls back to disk

IO_THREAD="iothread1"
DISK_ID="root"

qemu-system-x86_64 \
  -name "ft_linux (shurtado)" \
  -enable-kvm \
  -cpu host,topoext=on \
  -smp 12,cores=6,threads=2,sockets=1 \
  -k es \
  -m 16G \
  -machine type=q35,accel=kvm,hpet=off \
  -rtc base=utc,clock=host \
  -global kvm-pit.lost_tick_policy=discard \
  -object iothread,id=${IO_THREAD} \
  -device virtio-blk-pci,drive=${DISK_ID},iothread=${IO_THREAD},num-queues=12 \
  -drive if=none,id=${DISK_ID},file=ft_linux_disk.img,format=raw,cache=none,aio=io_uring \
  -boot order=d \
  -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22 \
  -vga virtio \
  -display gtk \
  -device virtio-tablet \
  -audiodev none,id=audionone \
  "$@"
