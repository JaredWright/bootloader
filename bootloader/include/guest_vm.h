#ifndef GUEST_VM_H
#define GUEST_VM_H

#include "exceptions.h"

void guest_main(coordinate_data_t * in, coordinate_data_t * out);

void unhandled_guest_vector(void);

#endif
