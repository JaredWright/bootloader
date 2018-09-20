.section ".text"

/*
 * x0 contains the FDT blob PA, which we don't use
 */
.globl _header
_header:
        b       _booloader_start// branch to bootloader start
        .long   0               // reserved
        .quad   0               // Image load offset from start of RAM
        .quad   0x2000000       // Image size to be processed, little endian (32MiB, default for Pixel C)
        .quad   0               // reserved
        .quad   0               // reserved
        .quad   0               // reserved
        .quad   0               // reserved
        .byte   0x41            // Magic number, "ARM\x64"
        .byte   0x52
        .byte   0x4d
        .byte   0x64
        .word   0                 // reserved


/**
 * Simple macro to help with generating vector table entries.
 */ 
.macro  ventry  label
    .align  7
    b       \label
.endm

/*
 * Vector table for interrupts/exceptions that reach EL2.
 */
.align  11
.global el2_vector_table;
el2_vector_table:
        ventry _unhandled_vector                // Synchronous EL2t
        ventry _unhandled_vector                // IRQ EL2t
        ventry _unhandled_vector                // FIQ EL2t
        ventry _unhandled_vector                // Error EL2t

        ventry _unhandled_vector                // Synchronous EL2h
        ventry _unhandled_vector                // IRQ EL2h
        ventry _unhandled_vector                // FIQ EL2h
        ventry _unhandled_vector                // Error EL2h

        ventry _handle_hypercall                // Synchronous 64-bit EL0/EL1
        ventry _unhandled_vector                // IRQ 64-bit EL0/EL1
        ventry _unhandled_vector                // FIQ 64-bit EL0/EL1
        ventry _unhandled_vector                // Error 64-bit EL0/EL1

        ventry _unhandled_vector                // Synchronous 32-bit EL0/EL1
        ventry _unhandled_vector                // IRQ 32-bit EL0/EL1
        ventry _unhandled_vector                // FIQ 32-bit EL0/EL1
        ventry _unhandled_vector                // Error 32-bit EL0/EL1

/**
 * Start of day code. This is the first code that executes after we're launched
 * by the bootloader. We use this only to set up a C environment.
 */
.global _booloader_start
_booloader_start:
        // Reminder: do not clobber x0, as it contains the location of our
        // Flattened Device Tree / FDT. If you need to use x0, stash the value
        // (e.g. on the stack), and then put it back before main.
        // msr     DAIFClr, 0xF  /* Enable all interrupts */

        // Create a simple stack for the bfstub, while executing in EL2.
        // ldr     x1, =el2_stack_end
        // mov     sp, x1

        // Clear out our binary's bss.
        // stp     x0, x1, [sp, #-16]!
        // bl      _clear_bss
        // ldp     x0, x1, [sp], #16

        // Run the main routine. This shouldn't return.
        b       main_el2

        // We shouldn't ever reach here; trap.
1:      b       1b

.global _start_core_1
_start_core_1:
        // Setup stack for core 1 in EL2 (each core gets its own stack)
        ldr     x1, =el2_core1_stack_end
        mov     sp, x1

        // Run the main routine. This shouldn't return.
        b       main_secondary_cpu

        // We shouldn't ever reach here; trap.
1:      b       1b

.global _start_core_2
_start_core_2:
        // Setup stack for core 2 in EL2 (each core gets its own stack)
        ldr     x1, =el2_core2_stack_end
        mov     sp, x1

        // Run the main routine. This shouldn't return.
        b       main_secondary_cpu

        // We shouldn't ever reach here; trap.
1:      b       1b

.global _start_core_3
_start_core_3:
        // Setup stack for core 3 in EL2 (each core gets its own stack)
        ldr     x1, =el2_core3_stack_end
        mov     sp, x1

        // Run the main routine. This shouldn't return.
        b       main_secondary_cpu

        // We shouldn't ever reach here; trap.
1:      b       1b

.global setup_el2_registers
setup_el2_registers:

        // Set the hypervisor control register to trap SMC calls, and allow for
        // 64-bit guests in EL1
        mov     x2, #0x80080000
        msr     hcr_el2, x2

        // Enable instruction cache and data cache
        // TODO: This is technically not allowed without the MMU turned on
        mrs     x2, sctlr_el2
        mov     x3, #0x1004
        orr     x2, x2, x3
        msr     sctlr_el2, x2

        ret

/*
 * Switch down to EL1 and then execute the second half of our stub.
 * Implemented in assembly, as this manipulates the stack.
 *
 * Obliterates the stack, but leaves the rest of memory intact. This should be
 *  fine, as we should be hiding the EL2 memory from the rest of the system.
 *
 * x0: The location of the device tree to be passed into EL0.
 */
.global switch_to_el1
switch_to_el1:

        // Set up a post-EL1-switch return address and target guest state
        ldr     x2, =_post_el1_switch
        msr     elr_el2, x2
        mov     x2, #0x3c5     // EL1_SP1 | D | A | I | F
        msr     spsr_el2, x2

        // Reset the stack pointer to the very end of the stack, so it's
        // fresh and clean for when we jump back up into EL2.
        ldr     x2, =el2_stack_end
        mov     sp, x2

        // Switch down to EL1
        eret

/*
 * Entry point after the switch to EL1.
 *
 * x0: The location of the device tree.
 * x2: The C code to return to after the EL1 switch.
 */
.global _post_el1_switch
_post_el1_switch:

        // Create a simple stack for the bfstub to use while at EL1.
        ldr     x2, =el1_stack_end
        mov     sp, x2

        // msr     DAIFClr, 0xF  /* Enable all interrupts */

        // Run the main routine. This shouldn't return.
        b       main_el1

        // We shouldn't ever reach here; trap.
1:      b       1b


/**
 * Push and pop 'psuedo-op' macros that simplify the ARM syntax to make the below pretty.
 */
.macro  push, xreg1, xreg2
    stp     \xreg1, \xreg2, [sp, #-16]!
.endm
.macro  pop, xreg1, xreg2
    ldp     \xreg1, \xreg2, [sp], #16
.endm

/**
 * Macro that saves registers onto the stack when entering an exception handler--
 * effectively saving the guest state. Once this method is complete, *sp will
 * point to a struct guest_state.
 *
 * You can modify this to save whatever you'd like, but:
 *   1) We can only push in pairs due to armv8 architecture quirks.
 *   2) Be careful not to trounce registers until after you've saved them.
 *   3) r31 is your stack pointer, and doesn't need to be saved. You'll want to
 *      save the lesser EL's stack pointers separately.
 *   4) Make sure any changes you make are reflected both in _restore_registers_
 *      and in struct guest_state, or things will break pretty badly.
 */
.macro  save_registers
        // General purpose registers x1 - x30
        push    x29, x30

        /* PSCI call is Fast Call(atomic), so mask DAIF */
        // mrs x29, DAIF
        // stp x29, xzr, [sp, #-16]!
        // ldr x29, =0x3C0
        // msr DAIF, x29

        push    x27, x28
        push    x25, x26
        push    x23, x24
        push    x21, x22
        push    x19, x20
        push    x17, x18
        push    x15, x16
        push    x13, x14
        push    x11, x12
        push    x9,  x10
        push    x7,  x8
        push    x5,  x6
        push    x3,  x4
        push    x1,  x2

        // x0 and the el2_esr
        mrs     x20, esr_el2
        push    x20, x0

        // the el1_sp and el0_sp
        mrs     x0, sp_el0
        mrs     x1, sp_el1
        push    x0, x1

        // the el1 elr/spsr
        mrs     x0, elr_el1
        mrs     x1, spsr_el1
        push    x0, x1

        // the el2 elr/spsr
        mrs     x0, elr_el2
        mrs     x1, spsr_el2
        push    x0, x1

        // sctlr for el1
        mrs     x0, vbar_el1
        mrs     x1, sctlr_el1
        push    x0, x1

        // If you add more registers here, don't forget to update the
        // guest_state struct!

.endm

/**
 * Macro that restores registers when returning from EL2.
 * Mirrors save_registers.
 */
.macro restore_registers
        // sctlr for el1
        pop     x0, x1
        msr     vbar_el1, x0
        msr     sctlr_el1, x1

        // the el2 elr/spsr
        pop     x0, x1
        msr     elr_el2, x0
        msr     spsr_el2, x1

        // the el1 elr/spsr
        pop     x0, x1
        msr     elr_el1, x0
        msr     spsr_el1, x1

        // the el1_sp and el0_sp
        pop     x0, x1
        msr     sp_el0, x0
        msr     sp_el1, x1

        // x0, and the el2_esr
        // Note that we don't restore el2_esr, as this wouldn't
        // have any meaning.
        pop    x20, x0

        // General purpose registers x1 - x30
        pop    x1,  x2
        pop    x3,  x4
        pop    x5,  x6
        pop    x7,  x8
        pop    x9,  x10
        pop    x11, x12
        pop    x13, x14
        pop    x15, x16
        pop    x17, x18
        pop    x19, x20
        pop    x21, x22
        pop    x23, x24
        pop    x25, x26
        pop    x27, x28

        /* restore DAIF */
        // ldp x29, xzr, [sp], #16
        // msr DAIF, x29

        pop    x29, x30
.endm

/*
 * Handler for any vector we're not equipped to handle.
 */
_unhandled_vector:
        // TODO: Save interrupt state and turn off interrupts.
        save_registers

        // Point x0 at our saved registers, and then call our C handler.
        mov     x0, sp
        bl    unhandled_vector

        restore_registers
        eret

/*
 * Handler for any synchronous event coming from the guest (any trap-to-EL2).
 * This _stub_ only uses this to handle hypercalls-- hence the name.
 */
_handle_hypercall:
        // TODO: Save interrupt state and turn off interrupts.

        save_registers

        // Point x0 at our saved registers, and then call our C handler.
        mov     x0, sp
        bl    handle_hypercall

        restore_registers
        eret

/*
 * Handoff from bareflank to Linux on primary bootstrap CPU
 *
 * x0: The location of the Linux kernel
 * x1: The device tree to pass to Linux
 */
.global _launch_linux
_launch_linux:
        mov     x4, x0

        mov     x0, x1
        mov     x1, #0
        mov     x2, #0
        mov     x3, #0

        blr      x4
        // We shouldn't ever reach here; trap.
1:      b       1b

/*
 * Handoff from bareflank to Linux on secondary CPUs
 *
 * x0: The location of the Linux kernel secondary entry point
 */
.global _launch_linux_secondary
_launch_linux_secondary:
        mov     x4, x0

        mov     x0, #0
        mov     x1, #0
        mov     x2, #0
        mov     x3, #0

        blr      x4
        // We shouldn't ever reach here; trap.
1:      b       1b

.global _launch_guest
_launch_guest:
        blr     x2

        // Signal to the VMM that the guest is finished executing,
        // which eventually calls _teardown_guest
        hvc     #0xDEAD

        // We shouldn't ever reach here; trap.
1:      b       1b

