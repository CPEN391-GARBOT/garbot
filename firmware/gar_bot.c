#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define HW_REGS_BASE ( 0xff200000 )
#define HW_REGS_SPAN ( 0x00200000 )
//#define HW_REGS_SPAN ( 0x00005000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

#define LED_PIO_BASE 0x2040
#define BUTTON_BASE 0x10
#define REAL_LED_BASE 0x20

#define HPS_BRIDGE_BASE ( 0xc0000000 )
#define HPS_BRIDGE_SPAN ( 0x04000000 )
#define HPS_BRIDGE_MASK ( HW_REGS_SPAN - 1 )
#define SDRAM_OFFSET 0x0
#define PHOTO_OFFSET 0x01000000

/**
 * File writes file located at ./weights.bin into memory at the base of the SDRAM
 * Returns -1 if error occurs, 0 on success
 *
 * Status: seems to work, poor code quality
 *
 */
int load_weights(void) {
	volatile unsigned int *sdram_addr=NULL;
	void *virtual_base_HW;
	int fd;

	// Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( -1 );
	}


	// get virtual addr of the HPS-FPGA bus
	virtual_base_HW = mmap( NULL, HPS_BRIDGE_SPAN, ( PROT_READ | PROT_WRITE ),
			MAP_SHARED, fd, HPS_BRIDGE_BASE );
	if( virtual_base_HW == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return(-1);
	}

	// Get address of SDRAM
	sdram_addr=(unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET ) & (
			HPS_BRIDGE_MASK ) ));

	unsigned char buffer;
	int x = 0;

	FILE * binFile = fopen("./weights.bin", "r");
	if (binFile == NULL) {
		printf( "ERROR: could not open our bin file ....\n" );
		close(fd);
		return( -1 );
	}

	//iterate over entire weights file, note need to make size not hardcoded magic num...
	for (x = 0; x < 3515932; x++) {
		fread(&buffer, sizeof(char), 1, binFile);
		*(sdram_addr + x) = buffer;
	}

	close(fd);
	fclose(binFile);
	return 0;
}


/**
 * File writes photo located at ./photo.bin into memory at the PHOTO_OFFSET in SDRAM
 * Returns -1 if error occurs, 0 on success
 * Very similar to load_weights()
 *
 * Status: seems to work, poor code quality
 *
 */
int load_photo() {
	volatile unsigned int *photo_addr=NULL;
	void *virtual_base_HW;
	int fd;

	// Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( -1 );
	}


	// get virtual addr of the HPS-FPGA bus
	virtual_base_HW = mmap( NULL, HPS_BRIDGE_SPAN, ( PROT_READ | PROT_WRITE ),
			MAP_SHARED, fd, HPS_BRIDGE_BASE );
	if( virtual_base_HW == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return(-1);
	}

	// Get address of photo base in SDRAM
	photo_addr=(unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET + PHOTO_OFFSET ) & (
			HPS_BRIDGE_MASK ) ));


	unsigned char buffer;
	int x = 0;

	FILE * binFile = fopen("./photo.bin", "r");
	if (binFile == NULL) {
		printf( "ERROR: could not open our bin file ....\n" );
		close(fd);
		return( -1 );
	}

	//iterate over entire photo, note need to make size not hardcoded magic num...
	for (x = 0; x < 196608; x++) {
		fread(&buffer, sizeof(char), 1, binFile);
		*(photo_addr + x) = buffer;
	}

	close(fd);
	fclose(binFile);

	return 0;
}

/**
 * Call this function to
 */
int start_accelerators(void) {
	//start the first ones
	//start them all
	//ext.
}


/**
 *  Waits for a button push, then returns result of pushing said button.
 *
 *  Returns -1 on error, 0 on garbage, 1 on recycling, 2 on paper, 3 on compost
 */
int wait_on_buttons(void) {
	volatile unsigned int *buttons=NULL;
	void *virtual_base_LW;
	int fd;

	// Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( -1 );
	}

	printf( "Starting 1st mmap()...\n" );

	// get virtual addr that maps to physical
	virtual_base_LW = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ),
		MAP_SHARED, fd, HW_REGS_BASE );
	if( virtual_base_LW == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return(-1);
	}


	//Get address of buttons
	buttons =(unsigned int *)(virtual_base_LW + (( BUTTON_BASE ) & (
		HW_REGS_MASK ) ));

	//sleep(1);

	while(*buttons == 0xf) {
		continue;
	}

	if ((*buttons & 0x8) == 0) {
		close(fd);
		return 0;
	} else if ((*buttons & 0x4) == 0) {
		close(fd);
		return 1;
	} else if ((*buttons & 0x2) == 0) {
		close(fd);
		return 2;
	} else if ((*buttons & 0x1) == 0) {
		close(fd);
		return 3;
	}

	close(fd);
	return -1;
}


int send_wifi_response(void) {
	//may god help us all
	return 0;
}


int turn_leds_on(void) {
	volatile unsigned int *leds=NULL;
	void *virtual_base_LW;
	int fd;

	// Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( -1 );
	}

	printf( "Starting 1st mmap()...\n" );

	// get virtual addr that maps to physical
	virtual_base_LW = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ),
		MAP_SHARED, fd, HW_REGS_BASE );
	if( virtual_base_LW == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return(-1);
	}


	//Get address of buttons
	leds =(unsigned int *)(virtual_base_LW + (( REAL_LED_BASE ) & (
		HW_REGS_MASK ) ));

	//printf("The value of the led pointer %p\n", leds);
	//printf("The value of the led pointer + 1 %p\n", leds+1);


	*leds = 0x3ff;

	return 0;
}

int turn_leds_off(void) {
	volatile unsigned int *leds=NULL;
	void *virtual_base_LW;
	int fd;

	// Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( -1 );
	}

	printf( "Starting 1st mmap()...\n" );

	// get virtual addr that maps to physical
	virtual_base_LW = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ),
		MAP_SHARED, fd, HW_REGS_BASE );
	if( virtual_base_LW == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return(-1);
	}


	//Get address of buttons
	leds =(unsigned int *)(virtual_base_LW + (( REAL_LED_BASE ) & (
		HW_REGS_MASK ) ));

	//printf("The value of the led pointer %p\n", leds);
	//printf("The value of the led pointer + 1 %p\n", leds+1);


	*leds = 0x0;

	return 0;
}



int main(void) {
	//once during setup
	//load_weights();

	//for each photo
	//load_photo();
	//start_accelerators();
	wait_on_buttons();
	turn_leds_on();
	//send_wifi_response();

}

/*int main(void)
{
    volatile unsigned int *h2p_lw_led_addr=NULL;
    volatile unsigned int *sdram_addr=NULL;
    volatile unsigned int *buttons=NULL;
    void *virtual_base;
    void *virtual_base_HW;
    int fd;
    int bin;

    // Open /dev/mem
    if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
        printf( "ERROR: could not open \"/dev/mem\"...\n" );
        return( 1 );
    }

    // Open /media/fat_partition/swag.bin
    //if( ( bin = open( " /media/fat_partition/swag.bin", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
    //        printf( "ERROR: could not open our bin file ....\n" );
    //        close(fd);
    //        return( 1 );
    //}

    printf( "Starting 1st mmap()...\n" );

    // get virtual addr that maps to physical
    virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ),
        MAP_SHARED, fd, HW_REGS_BASE );
    if( virtual_base == MAP_FAILED ) {
        printf( "ERROR: mmap() failed...\n" );
        close( fd );
        close( bin );
        return(1);
    }

    printf( "Got past 1st mmap()...\n" );


    printf( "Starting 2nd mmap()...\n" );

        // get virtual addr that maps to physical
    virtual_base_HW = mmap( NULL, HPS_BRIDGE_SPAN, ( PROT_READ | PROT_WRITE ),
            MAP_SHARED, fd, HPS_BRIDGE_BASE );
        if( virtual_base_HW == MAP_FAILED ) {
            printf( "ERROR: mmap() failed...\n" );
            close( fd );
            close( bin );
            return(1);
        }

    printf( "Got past 2nd mmap()...\n" );


    // Get the address that maps to the LEDs
    h2p_lw_led_addr=(unsigned int *)(virtual_base + (( REAL_LED_BASE ) & (
    HW_REGS_MASK ) ));

    //Get address of buttons
    buttons =(unsigned int *)(virtual_base + (( BUTTON_BASE ) & (
        HW_REGS_MASK ) ));

    // Get address of SDRAM
    sdram_addr=(unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET ) & (
    		HPS_BRIDGE_MASK ) ));


    //printf( "Got address...%p\n", h2p_lw_led_addr );

    printf("About to write to memory\n");

    //int a = 0x0;
    //int b = 0x50;

    //*sdram_addr = a;
    //*(sdram_addr + 1) = b;

    //printf("About to read from memory\n");

    //printf("a is %x\n", *sdram_addr);
    //printf("b is %x\n", *(sdram_addr+1));
    unsigned char buffer;
    int x = 0;
    FILE * binFile = fopen("/media/fat_partition/swag.bin", "r");
    if (binFile == NULL) {
    	printf( "ERROR: could not open our bin file ....\n" );
    	close(fd);
    	return( 1 );
    }

    printf("about to do loop\n");
    for (x = 0; x < 6; x++) {
    	fread(&buffer, sizeof(char), 1, binFile);
    	printf("char is %c\n", buffer);
    	*(sdram_addr + x) = buffer;
    }

    printf("finished loop\n");
    printf("sdram has %c\n", *(sdram_addr));
    printf("sdram has %c\n", *(sdram_addr+1));
    printf("sdram has %c\n", *(sdram_addr+2));
    printf("sdram has %c\n", *(sdram_addr+3));
    printf("sdram has %c\n", *(sdram_addr+4));
    printf("sdram has %c\n", *(sdram_addr+5));






    int v = 0x5; // arbitrary value

    *h2p_lw_led_addr = v; // write the value to component
    printf("value is now %x\n", *(h2p_lw_led_addr+1));

    // increment what is in the component
    *(h2p_lw_led_addr+1) = 0; // does not matter what you write
    printf("value is now %x\n", *(h2p_lw_led_addr+1));

    // increment it again
    *(h2p_lw_led_addr+1) = 0; // does not matter what you write
    printf("value is now %x\n", *(h2p_lw_led_addr+1));

    // get the value in reverse bit order
    printf("reverse bit order %x\n", *(h2p_lw_led_addr));

    // get the complement of the value
    printf("complement is %x\n", *(h2p_lw_led_addr+2));

    // Add 1 to the PIO register
    //*h2p_lw_led_addr = *h2p_lw_led_addr + 1;



    while(1) {
    	sleep(1);
    	printf("value of push buttons is %x\n", *buttons);
    	*h2p_lw_led_addr = *h2p_lw_led_addr + 1;
    }




    printf( "Starting munmap()...\n" );

    if( munmap( virtual_base, HW_REGS_SPAN ) != 0 ) {
        printf( "ERROR: munmap() failed...\n" );
        close( fd );
        close( bin );
        return( 1 );
    }

    printf( "Finished munmap()...\n" );

    close( fd );
    close( bin );
    return 0;
}*/