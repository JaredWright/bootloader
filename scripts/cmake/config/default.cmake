#
# Bareflank Hypervisor
# Copyright (C) 2018 Assured Information Security, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

set(BOOTLOADER_SOURCE_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR}/../../..
    CACHE INTERNAL
    "Bootloader source root directory"
)

set(BOOTLOADER_SOURCE_CMAKE_DIR ${BOOTLOADER_SOURCE_ROOT_DIR}/scripts/cmake
    CACHE INTERNAL
    "Bootloader cmake scripts directory"
)

set(BOOTLOADER_DEVICE_TREE_DIR ${BOOTLOADER_SOURCE_ROOT_DIR}/scripts/device_tree
    CACHE INTERNAL
    "Bootloader device tree directory"
)

set(BOOTLOADER_SOURCE_CONFIG_DIR ${CMAKE_CURRENT_LIST_DIR}
    CACHE INTERNAL
    "Bootloader cmake configuration directory"
)

set(BOOTLOADER_SOURCE_DEPENDS_DIR ${BOOTLOADER_SOURCE_CMAKE_DIR}/depends
    CACHE INTERNAL
    "Bootloader cmake dependencies directory"
)

# ------------------------------------------------------------------------------
# Configs
# ------------------------------------------------------------------------------

add_config(
    CONFIG_NAME ENABLE_BUILD_BOOTLOADER
    CONFIG_TYPE BOOL
    DEFAULT_VAL ON
    DESCRIPTION "Build the bareflank bootloader"
)

add_config(
    CONFIG_NAME BUILD_IMAGE_FORMAT
    CONFIG_TYPE STRING
    DEFAULT_VAL bin
    DESCRIPTION "The target image format"
    OPTIONS bin fit shellcode
)

add_config(
    CONFIG_NAME DEVICE_TREE_SOURCE
    CONFIG_TYPE FILE
    DEFAULT_VAL ${BOOTLOADER_DEVICE_TREE_DIR}/jetson-tx1-with-kernel-commandline.dts
    DESCRIPTION "The device tree source file to be used with this bootloader"
)

add_config(
    CONFIG_NAME FLASH_DEV
    CONFIG_TYPE FILE
    DEFAULT_VAL /dev/sdb1
    DESCRIPTION "The device node to use for 'make flash' target"
)

add_config(
    CONFIG_NAME FLASH_MOUNT
    CONFIG_TYPE PATH
    DEFAULT_VAL /media/jetson
    DESCRIPTION "Path to mount FLASH_DEV to during 'make flash' target"
    SKIP_VALIDATION
)

add_config(
    CONFIG_NAME FLASH_PATH
    CONFIG_TYPE PATH
    DEFAULT_VAL boot
    DESCRIPTION "Path to flash bootloader.bin on target device ${FLASH_DEV}"
    SKIP_VALIDATION
)

# ------------------------------------------------------------------------------
# Links
# ------------------------------------------------------------------------------

set(DTC_URL "https://github.com/dgibson/dtc/archive/v1.4.6.zip"
    CACHE INTERNAL FORCE
    "Device tree compiler/libfdt URL"
)

set(DTC_URL_MD5 "540fb180485cd98b73800d39f2993a29"
    CACHE INTERNAL FORCE
    "Device tree compiler/libfdt URL MD5 hash"
)

set(SHOULDER_URL "https://github.com/jaredwright/shoulder/archive/23cbb6828d751d0bb9893d5351c6e4a01e49bd88.zip"
    CACHE INTERNAL FORCE
    "Shoulder URL"
)

set(SHOULDER_URL_MD5 "2856b9747a6058cc46b60616f1744739"
    CACHE INTERNAL FORCE
    "Shoulder URL MD5 hash"
)
