.section ".text"

/*
 * Mock linux-kernel header to trick previous stage bootloaders that we're Linux
 */
.globl _header
_header:
        b       _bootloader_start
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
 * Bareflank bootloader start of day code.
 * This is the first code that executes after we're launched by the previous
 * stage bootloader. Used only to set up a sane C environment for 
 * bootloader_main()
 *
 * x0 = Address of a flattened device tree or .fit image passed in from
 *      prevoius stage bootloader
 */
.global _bootloader_start
_bootloader_start:
    // Reminder: x0 needs to be preserved (needed by bootloader_main())
    // Setup the bootloader's stack (used for execution in both EL2 and EL1)
    ldr     x1, =bootloader_stack_end
    mov     sp, x1

    // Run the bootloader's main routine. This shouldn't return.
    b       bootloader_main

    // We shouldn't ever reach here; trap.
1:  b       1b
