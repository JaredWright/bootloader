/**
 * Bareflank EL2 boot stub: register access primitives
 * A simple program that sets up EL2 for later use by the Bareflank hypervsior.
 *
 * Copyright (C) Assured Information Security, Inc.
 *      Author: Kate J. Temkin <k@ktemkin.com>
 *
 * <insert license here>
 */

#ifndef __REGS_H__
#define __REGS_H__

#include "exceptions.h"

/**
 * Access to system registers.
 */
#define WRITE_SYSREG(sysreg, val, type) \
    asm volatile ("msr        "#sysreg", %0\n" : : "r"((type)(val)))
#define READ_SYSREG(sysreg, val, type) \
    asm volatile ("mrs        %0, "#sysreg"\n" : "=r"((type)(val)))

#define READ_SYSREG_32(sysreg, val)   READ_SYSREG(sysreg, val, uint32_t)
#define WRITE_SYSREG_32(sysreg, val)  WRITE_SYSREG(sysreg, val, uint32_t)

#define READ_SYSREG_64(sysreg, val)   READ_SYSREG(sysreg, val, uint64_t)
#define WRITE_SYSREG_64(sysreg, val)  WRITE_SYSREG(sysreg, val, uint64_t)


/**
 * Returns the system's current Execution Level (EL).
 */
inline static uint32_t get_current_el(void) {
    uint32_t val;

    // Read the CurrentEl register, and extract the bits that tell us our EL.
    READ_SYSREG_32(CurrentEl, val);
    return val >> 2;
}

/**
 * Returns the ID (affinity) of the current core
 */
inline static uint64_t get_core_id(void)
{
    uint64_t reg64 = 0;
    READ_SYSREG_64(mpidr_el1, reg64);
    return reg64 & 0xF;
}

/**
 * Sets the base address of the EL2 exception table.
 */
inline static void set_vbar_el2(void * address) {
    WRITE_SYSREG_64(vbar_el2, (uint64_t)address);
}


/**
 * Sets the address to 'return to' when leaving EL2.
 */
inline static void set_elr_el2(void * address) {
    WRITE_SYSREG_64(elr_el2, (uint64_t)address);
}

/**
 * Sets PSTATE when leaving EL2.
 */
inline static void set_spsr_el2(uint64_t val) {
    WRITE_SYSREG_64(spsr_el2, val);
}


/**
 * Returns the MMU status bit from the SCTLR register.
 */
inline static uint32_t get_el2_mmu_status(void) {
    uint32_t val;

    // Read the CurrentEl register, and extract the bits that tell us our EL.
    READ_SYSREG_32(sctlr_el2, val);
    return val & 1;
}

inline static void print_el2_registers(void)
{
    uint64_t reg64 = 0;
    printf("\nEL2 Register Configuration:\n", reg64);

    READ_SYSREG_64(esr_el2, reg64);
    printf("  Exception Syndrome Register:                   0x%016x\n", reg64);

    READ_SYSREG_64(hcr_el2, reg64);
    printf("  Hypervisor Control Register:                   0x%016x\n", reg64);

    READ_SYSREG_64(hacr_el2, reg64);
    printf("  Hypervisor Auxilliary Control Register:        0x%016x\n", reg64);

    READ_SYSREG_64(elr_el2, reg64);
    printf("  Exception Link Register (EL2):                 0x%016x\n", reg64);

    READ_SYSREG_64(spsr_el2, reg64);
    printf("  Saved Program Status Register (EL2):           0x%016x\n", reg64);

    READ_SYSREG_64(sctlr_el2, reg64);
    printf("  System Control Register (EL2):                 0x%016x\n", reg64);

    READ_SYSREG_64(vbar_el2, reg64);
    printf("  Vector Base Address Register (EL2):            0x%016x\n", reg64);

    READ_SYSREG_64(tcr_el2, reg64);
    printf("  Translation Control Register (EL2):            0x%016x\n", reg64);

    READ_SYSREG_64(ttbr0_el2, reg64);
    printf("  Translation Table Base Address Register 0 (EL2): 0x%016x\n", reg64);
}

/**
 * Simple debug function that prints all of our saved registers.
 */
inline static void print_guest_state(struct guest_state *regs)
{
    printf("\nGuest State:\n");
    // print x0-29
    for(int i = 0; i < 30; i += 2) {
        printf("x%d:\t0x%p\t", i,     regs->x[i]);
        printf("x%d:\t0x%p\n", i + 1, regs->x[i + 1]);
    }

    // print x30; don't bother with x31 (SP), as it's used by the stack that's
    // storing this stuff; we really care about the saved SP anyways
    printf("x30:\t0x%p\n", regs->x[30]);

    // Special registers.
    printf("pc:\t0x%p\tcpsr:\t0x%p\n", regs->pc, regs->cpsr);
    printf("sp_el1:\t0x%p\tsp_el0:\t0x%p\n", regs->sp_el1, regs->sp_el0);
    printf("elr_el1:0x%p\tspsr_el1:0x%p\n", regs->elr_el1, regs->spsr_el1);
}

inline static void print_obnoxious_banner(void)
{
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
    printf("******************************************\n");
}

#endif
