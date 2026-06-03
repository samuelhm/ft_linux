# ft_linux — How to Train Your Kernel v3.6

Construcción de una distribución Linux desde cero (LFS 13.0 systemd) como base para proyectos de kernel.

## Requisitos del ejercicio

| Requisito | Implementación |
|-----------|---------------|
| Kernel ≥ 4.0 con login del estudiante | `6.18.10-shurtado` |
| Hostname con login del estudiante | `shurtado` |
| Bootloader | GRUB 2.14 |
| Init / gestión central | systemd 259 |
| Al menos 3 particiones | GPT: vda1 (boot), vda2 (swap), vda3 (root) |
| FHS compliant | `/bin → usr/bin`, `/lib → usr/lib`, estándar LFS |
| Cargador de módulos | udev (systemd-udevd) |
| Conexión a Internet | systemd-networkd + DHCP |
| Descarga de código fuente | wget 1.25.0 |

## Particionado

| Partición | Tamaño | Tipo | Punto de montaje |
|-----------|--------|------|------------------|
| vda1 | 512 MB | EFI System | /boot |
| vda2 | 4 GB | Linux swap | swap |
| vda3 | 55 GB | Linux root | / |

## Compilación de Glibc (3 pases)

El manual LFS establece que glibc se compila en 3 pases durante la construcción del toolchain:

1. **Pase 1 (cross-compilation):** Se compila una versión mínima de glibc usando el compilador cruzado. Solo proporciona las funciones esenciales para que el resto de herramientas puedan enlazarse.

2. **Pase 2 (transición):** Una vez que gcc puede compilar código para la arquitectura destino con las bibliotecas del pase 1, se recompila glibc con más funcionalidad. Esta versión ya soporta threading, locales, y la mayoría de las APIs POSIX.

3. **Pase 3 (final):** Con el toolchain completo (gcc + glibc maduros), se compila la versión definitiva de glibc con todas las opciones habilitadas: soporte completo de locales, nscd, sln, timezone data, etc.

Este proceso es necesario porque glibc es circularmente dependiente de sí misma: necesitas una glibc funcional para compilar glibc. Los 3 pases rompen esta dependencia circular incrementalmente.

## Paquetes obligatorios compilados desde fuente

Siguiendo la lista del enunciado v3.6:

| Paquete | Paquete | Paquete |
|---------|---------|---------|
| Acl | Attr | Autoconf |
| Automake | Bash | Bc |
| Binutils | Bison | Bzip2 |
| Check | Coreutils | DejaGNU |
| Diffutils | Eudev | E2fsprogs |
| Expat | Expect | File |
| Findutils | Flex | Gawk |
| GCC 15.2.0 | GDBM | Gettext |
| Glibc 2.43 | GMP | Gperf |
| Grep | Groff | GRUB |
| Gzip | Iana-Etc | Inetutils |
| Intltool | IPRoute2 | Kbd |
| Kmod | Less | Libcap |
| Libpipeline | Libtool | M4 |
| Make | Man-DB | Man-pages |
| MPC | MPFR | Ncurses |
| Patch | Perl | Pkg-config |
| Procps | Psmisc | Readline |
| Sed | Shadow | Sysklogd |
| Sysvinit | Tar | Tcl |
| Texinfo | Time Zone Data | Udev-lfs Tarball |
| Util-linux | Vim | XML::Parser |
| Xz Utils | Zlib | |

**Adicionales para la evaluación:**
- wget 1.25.0 (descarga de código fuente)
- sudo 1.9.16p2 (gestión de privilegios)
- OpenSSH 10.2p1 (acceso remoto)
- CA certificates (HTTPS)
- git 2.49.0 (control de versiones)
- cmake 4.2.0 (build system)
- gdb 16.2 (debugger)
- strace 7.0 (syscall tracer)
- htop 3.4.0 (monitor de procesos)

## Bonus: Entorno gráfico Wayland

| Capa | Paquete | Versión |
|------|---------|---------|
| Protocolo | wayland, wayland-protocols | 1.23.1 / 1.42 |
| Mesa | mesa (gallium softpipe) | 25.0.3 |
| Compositor | wlroots → sway | 0.18.3 → 1.10.1 |
| Terminal | foot | 1.20.2 |
| Launcher | fuzzel | 1.11.1 |
| Renderizado | cairo, pango, harfbuzz, glib, libpng | varios |

Se compiló mesa con `softpipe` (renderizado software, sin aceleración HW). El driver `swrast_dri.so` se obtuvo del host (Arch Linux) por incompatibilidad de la build de mesa para Wayland puro con los drivers DRI.

## Virtualización

QEMU 11.0.1 con KVM, 12 vCPUs, 16 GB RAM, disco raw 60 GB, virtio-gpu 1280×720. Acceso SSH por `localhost:2222` → VM:22.

## Estructura del repositorio

```
ft_linux/
├── ft_linux_disk.img              # Disco virtual 60 GB
├── ft_linux_disk_final.img.tar.xz # Imagen comprimida para entrega
├── run_qemu.sh                    # Script de arranque QEMU
├── Makefile                       # run, mount, umount, status
├── kernel-config-6.18.10-shurtado # Config del kernel
├── remove-la.sh                   # Limpia archivos .la tras cada install
├── AGENTS.md                      # Documentación para agentes AI
└── README.md                      # Este archivo
```
