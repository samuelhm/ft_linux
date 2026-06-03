#!/bin/bash
# Optimizado para Intel Core i5-8500 (6C/6T, 8GB RAM) en Ubuntu
# Ruta de disco absoluta en /sgoinfre

IO_THREAD="iothread1"
DISK_ID="root"
DISK_PATH="/sgoinfre/students/shurtado/ft_linux_disk.qcow2"

qemu-system-x86_64 \
  -name "ft_linux (shurtado)" \
  -enable-kvm \
  -cpu host \
  -smp 4,cores=4,threads=1,sockets=1 \
  -m 4G \
  -machine type=q35,accel=kvm,hpet=off \
  -rtc base=utc,clock=host \
  -global kvm-pit.lost_tick_policy=discard \
  -object iothread,id=${IO_THREAD} \
  -device virtio-blk-pci,drive=${DISK_ID},iothread=${IO_THREAD},num-queues=4 \
  -drive if=none,id=${DISK_ID},file=${DISK_PATH},format=qcow2,cache=writeback,aio=threads \
  -boot order=d \
  -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22 \
  -vga virtio \
  -display gtk,zoom-to-fit=off \
  -device virtio-tablet \
  -audiodev none,id=audionone \
  "$@"
