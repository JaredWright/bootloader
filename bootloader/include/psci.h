#ifndef PSCI_H
#define PSCI_H

#include <stdint.h>

// Utilities for interacting with the Power State Coordination Interface v1.0
void print_psci_features(void);
void print_psci_affinity_info(void);
int32_t do_psci_cpu_on(uint64_t core_id, uint64_t context);
void do_psci_cpu_off(void);
int32_t do_psci_cpu_suspend(uint64_t power_state, uint64_t context_id);

#endif
