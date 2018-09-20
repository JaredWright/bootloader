OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
ENTRY(_header)
SECTIONS
{
    /* Load/entry point (where the previous stage bootloader will place us) */
    . = 0xf0000000;

    . = ALIGN(4);
    .text : {
    PROVIDE(lds_bfstub_start = .);
        *entry.o (.text)
        *(.text)
    }

    . = ALIGN(8);
    .rodata : {
        *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.rodata*)))
    }

    . = ALIGN(8);
    .data : {
        *(.data)
    }

    /* Uninitialised data */
    . = ALIGN(8);
    PROVIDE(lds_bss_start = .);
    .bss (NOLOAD) : {
        *(.bss) . = ALIGN(8);
    }
    PROVIDE(lds_bss_end = .);

    /* EL2 stack */
    . = ALIGN(16);
    . += 0x10000; /* 64 KiB stack */
    PROVIDE(el2_stack_end = .);

    /* EL2 core 1 stack */
    . = ALIGN(16);
    . += 0x10000; /* 64 KiB stack */
    el2_core1_stack_end = .;

    /* EL2 core 2 stack */
    . = ALIGN(16);
    . += 0x10000; /* 64 KiB stack */
    el2_core2_stack_end = .;

    /* EL2 core 3 stack */
    . = ALIGN(16);
    . += 0x10000; /* 64 KiB stack */
    el2_core3_stack_end = .;

    /* Crypto Guest VM stack */
    . = ALIGN(16);
    . += 0x10000; /* 64 KiB stack */
    crypto_guest_stack_end = .;

    /* Page align the end of the bfstub */
    . = ALIGN(512);
    PROVIDE(lds_el2_bfstub_end = .);

    /* EL1 stack */
    . = ALIGN(16);
    . += 0x10000; /* 64 KiB stack */
    el1_stack_end = .;

    lds_bfstub_end = .;

    /DISCARD/ : { *(.dynstr*) }
    /DISCARD/ : { *(.dynamic*) }
    /DISCARD/ : { *(.plt*) }
    /DISCARD/ : { *(.interp*) }
    /DISCARD/ : { *(.gnu*) }

}

