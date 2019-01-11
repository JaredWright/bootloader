#
# Bareflank Hypervisor
# Copyright (C) 2015 Assured Information Security, Inc.
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

include(${CMAKE_CURRENT_LIST_DIR}/scripts/cmake/config/default.cmake)
include(${BOOTLOADER_SOURCE_CMAKE_DIR}/validate.cmake)
include(${BOOTLOADER_SOURCE_CMAKE_DIR}/targets.cmake)

include_dependency(BOOTLOADER_SOURCE_DEPENDS_DIR dtc)
include_dependency(BOOTLOADER_SOURCE_DEPENDS_DIR libfdt)

add_subproject(
    bootloader vmm
    DEPENDS bfvmm
    DEPENDS bfintrinsics
    DEPENDS dtc
    DEPENDS libfdt
    SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/bootloader/src
    TOOLCHAIN ${SOURCE_TOOLCHAIN_DIR}/gcc_aarch64_vmm.cmake
)
