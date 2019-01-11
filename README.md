# Bareflank Aarch64 Bootloader Extension

This repository is a work-in-progress aarch64 bootloader extension for the
[Bareflank Hypervisor SDK](https://github.com/Bareflank/hypervisor).
Mainline Bareflank does not offically support any versions of the ARM
architecture yet, so this extension is being used to try and add support
for 64-bit ARMv8-A (aarch64).

Virtualization on ARM requires participation from a bootloader component to
setup an EL2 environment for a VMM at boot time. The goal of this extension is
to provide this necessary bootloader integration for a Bareflank-based VMM.

Hardware support will initially target the NVIDIA Jetson TX1/TX2 development
kit. Eventually, the hope is to add support for some more readily available
environments like Raspberry Pi 3 and QEMU.

## Dependencies

Ubuntu:

```
sudo apt-get install gcc-aarch64-linux-gnu
```

## Building

The quick way to build: (replace '\<full_path_to_this_repo>' with a real path) 
```
git clone --recursive https://github.com/jaredwright/bootloader
mkdir build && cd build
cmake ../bootloader/hypervisor -DCONFIG=/<full_path_to_this_repo>/config.cmake
make
```
