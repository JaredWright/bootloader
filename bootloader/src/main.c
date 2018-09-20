#include <stdint.h>
#include <microlib.h>

#include <libfdt.h>
#include <cache.h>
#include <bftypes.h>

#include "image.h"
#include "regs.h"
#include "psci.h"

void setup_el2_registers(void);
void switch_to_el1(void * fdt);

/**
 * C entry point for execution at EL1.
 */
void main_el1(void * fdt);

/**
 * Reference to the EL2 vector table.
 * Note that the type here isn't reprsentative-- we just need the address of the label.
 */
extern uint64_t el2_vector_table;


/**
 * Print our intro message
 */
void intro(uint32_t el)
{
    bootloader_printf("_______ _     _ _     _ __   _ ______  _______  ______        _______ __   _ _______\n");
    bootloader_printf("   |    |_____| |     | | \\  | |     \\ |______ |_____/ |      |_____| | \\  | |______\n");
    bootloader_printf("   |    |     | |_____| |  \\_| |_____/ |______ |    \\_ |_____ |     | |  \\_| |______\n");
    bootloader_printf("                                         --insert pony ascii here--                 \n");
    bootloader_printf("");
    bootloader_printf("\n\nInitializing Bareflank stub...\n");
    bootloader_printf("  current execution level:               EL%u\n", el);
    bootloader_printf("  hypervisor applications supported:     %s\n", (el == 2) ? "YES" : "NO");
    bootloader_printf("  mmu is:                                %s\n", (get_el2_mmu_status()) ? "ON" : "OFF");

}

/**
 * Core section of the Bareflank stub-- sets up the hypervisor from up in EL2.
 */
void main_el2(void *fdt)
{
    bfignored(fdt);
    uint32_t el = get_current_el();
    intro(el);
    if (el != 2) {
        bootloader_panic("The bareflank stub must be launched from EL2!");
    }
    //
    // set_vbar_el2(&el2_vector_table);
    // setup_el2_registers();
    // print_el2_registers();
    //
    // printf("\nSwitching to EL1...\n");
    // switch_to_el1(fdt);
}

void main_secondary_cpu(void * kernel_entry_point)
{
    bfignored(kernel_entry_point);
    // uint32_t el = get_current_el();
    // uint32_t coreid = get_core_id();
    //
    // printf("\n*********** CPU 0x%016x Enabled ***********\n", coreid);
    // printf("  Exception level: %u\n", el);
    // printf("  Kernel Secondary Entry Point: 0x%p\n", kernel_entry_point);
    //
    // set_vbar_el2(&el2_vector_table);
    // setup_el2_registers();
    // print_el2_registers();
    //
    // switch_to_el1(kernel_entry_point);
}

/**
 * Secondary section of the Bareflank stub, executed once we've surrendered
 * hypervisor privileges.
 */
void main_el1(void * fit_image)
{
    bfignored(fit_image);
    // Validate that we're in EL1.
    // uint32_t el = get_current_el();
    // if(el == 1) {
    //     printf("Now executing from EL%d!\n", el);
    // } else {
    //     panic("Executing with more privilege than we expect!");
    // }
    //
    // // Core 0 (the bootstrap processor)
    // if(get_core_id() == 0) {
    //     launch_linux(fit_image);
    // }
    // // Cores 1, 2, and 3
    // else {
    //     launch_linux_secondary(fit_image);
    // }
    //
    // // If we've made it here, we failed to boot, and we can't recover.
    // panic("The Bareflank stub terminated without transferring control to Linux!");
}

