#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <limits.h>
#include <sys/mman.h>

int load_weights(void);
int load_photo();
int start_accelerators(void);
int wait_on_buttons(void);
int turn_leds_on(void);
int turn_leds_off(void);
int read_sdram(int offset);
