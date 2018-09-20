/**
 * Routines to handle "subimage" payloads.
 *
 * Copyright (C) Assured Information Security, Inc.
 *      Author: ktemkin <temkink@ainfosec.com>
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a 
 *  copy of this software and associated documentation files (the "Software"), 
 *  to deal in the Software without restriction, including without limitation 
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 *  and/or sell copies of the Software, and to permit persons to whom the 
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in 
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
 *  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 *  DEALINGS IN THE SOFTWARE.
 */

#ifndef __SUBIMAGE_H__
#define __SUBIMAGE_H__

#include <microlib.h>
#include <libfdt.h>

/**
 * Maximum entries in a supported memory table. Up this if we need to work
 * with particularly complex memory tables.
 */
#define MAX_MEM_TABLE_ENTRIES (8)

const void * find_fit_subimage(void *fdt);

/**
 * Ensures that a valid FDT/image is accessible for the system, performing any
 * steps necessary to make the image accessible, and validating the device tree.
 *
 * @return SUCCESS, or an FDT error code.
 */
int ensure_image_is_accessible(const void *image);

/**
 * Finds the chosen node in the Discharged FDT, which contains
 * e.g. the location of our final payload.
 */
int find_node(const void * image, const char * path);

/**
 * Finds the extents (start, length) of a given image, as passed from our
 * bootloader via the FDT.
 *
 * @param fdt The FDT passed from the previous-stage bootloader.
 * @param image_node The bootloader node corresponding to the relevant image.
 * @param description String description of the image, for error messages.
 * @param out_location Out argument; if non-null, will be populated with the
 *    starting location of the relevant image.
 * @param out_size Out argument; if non-null, will be populated with the
 */
int get_image_extents(const void *fdt, int image_node,
    const char *description, void **out_location, size_t *out_size);

/**
 * Main task for loading the system's device tree.
 */
void load_device_tree(void *fdt);

/**
 * Relocate the Linux kernel to the start of RAM. This is necessary for the
 * Linux start-of-day code to work properly if we don't modify TEXT_OFFSET
 * during its build process.
 *
 * @param kernel The kernel to be relocated.
 * @param size_t The size of the kernel.
 */
void * relocate_kernel(const void *kernel, size_t size, void *start_of_ram);

/**
 * Launch an executable kernel image. Should be the last thing called by
 * Discharge, as it does not return.
 *
 * @param kernel The kernel to be executed.
 * @param fdt The device tree to be passed to the given kernel.
 */
void launch_kernel(const void *kernel, const void *fdt);

// Launch linux from FIT image with embedded device tree
void launch_linux(void * fit_image);

// Launch linux from FIT image with embedded device tree
void launch_linux_secondary(void * entry_addr);

/**
 * Adjust the target FDT's memory to exclude the provided region. This allows
 * the stub to carve out memory for itself that e.g. Linux knows not to touch.
 *
 * @param fdt The FDT to be updated.
 * @param start_addr The start of the memory region to be excluded.
 * @param end_addr The end of the memory region to be excluded.
 * @param out_start_of_ram Out arugument. Will be popualted with the address of the first available RAM.
 *
 * @return SUCCESS, or an error code on failure
 */
int update_fdt_to_exclude_memory(void *fdt, uintptr_t start_addr,
    uintptr_t end_addr, void **out_start_of_ram);

/**
 * Converts a 32-bit devicetree location (e.g. our subimage location)
 * into a full 64-bit address.
 */
void * location_from_devicetree(uint32_t metalocation);

/**
 * Fetches the information necessary to load a subcomponent into memory,
 * querying the properites from the provided FIT image.
 *
 * @param image The image from which components are to be loaded.
 * @param path The string path to the component of the FIT image, e.g.
 *    "/images/kernel@0"
 * @param out_load_location Out argument; receives a pointer to the physical
 *    address to which the subcomponent wants to be loaded.
 * @param out_data_location Out argument; receives a pointer to the physical
 *    address at which the data to be loaded is currently resident.
 * @param out_size Out argument; receives the size of the subcomponent.
 * @param node_offset Optional out argument. If non-null, receives the location
 *    of the node that describes the given subcomponent, for furhter processing.
 *
 * @return SUCCESS on success, or an error code on failure.
 */
int get_subcomponent_information(const void *image, const char *path,
    void **out_load_location, void const**out_data_location, int *out_size,
    int * node_offset);

/**
 * Loads an subimage component into its final execution location, and returns a
 * pointer to the completed binary. Performs only basic sanity checking.
 *
 * @param image The image from which the blob should be extracted.
 * @param path The path to the node that represents the given image.
 * @param out_size If non-NULL, this out argument will be popualted with the
 *    loaded image's size.
 * @return The address of the component, or NULL on error.
 */
void * load_image_component(const void *image, const char *path, int *out_size);

void * load_image_component_verbosely(const void * image,
    const char * path, const char * description, int * size);

#endif
