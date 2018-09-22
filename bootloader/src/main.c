#include <microlib.h>
#include "boot.h"
#include "bootloader.h"

void bootloader_main(void * fdt)
{
    bfignored(fdt);

    // TODO: Register these functions using cmake + register_modules()
    boot_add_prestart_fn(print_banner);
    boot_add_prestart_fn(verify_environment);
    boot_add_prestart_fn(init_el2);
    boot_add_prestart_fn(init_platform_info);

    boot_set_start_fn(launch_bareflank);

    boot_add_poststart_fn(switch_to_el1);
    // boot_add_poststart_fn(return_to_previous_stage_bootloader);
    // boot_add_poststart_fn(boot_linux);

    // Execute the boot process
    boot_ret_t ret = boot_start();
    panic();
}

