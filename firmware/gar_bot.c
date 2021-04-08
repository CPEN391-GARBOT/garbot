#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define HW_REGS_BASE ( 0xff200000 )
#define HW_REGS_SPAN ( 0x00200000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

#define BUTTON_BASE 0x10
#define REAL_LED_BASE 0x20

#define HPS_BRIDGE_BASE ( 0xc0000000 )
#define HPS_BRIDGE_SPAN ( 0x04000000 )
#define HPS_BRIDGE_MASK ( HW_REGS_SPAN - 1 )
#define SDRAM_OFFSET 0x0
#define PHOTO_OFFSET 0x00100000
#define FIRST_BUFFER 0x00200000
#define SECOND_BUFFER 0x00300000

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

	unsigned int buffer;
	int x = 0;

	FILE * binFile = fopen("./weights.bin", "r");
	if (binFile == NULL) {
		printf( "ERROR: could not open our bin file ....\n" );
		close(fd);
		return( -1 );
	}

	//iterate over entire weights file, note need to make size not hardcoded magic num...
	for (x = 0; x < 3515932 / 4; x++) {
		fread(&buffer, sizeof(int), 1, binFile);
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


	unsigned int buffer;
	int x = 0;

	FILE * binFile = fopen("./photo.bin", "r");
	if (binFile == NULL) {
		printf( "ERROR: could not open our bin file ....\n" );
		close(fd);
		return( -1 );
	}

	//iterate over entire photo, note need to make size not hardcoded magic num...
	for (x = 0; x < 196608 / 4; x++) {
		fread(&buffer, sizeof(int), 1, binFile);
		*(photo_addr + x) = buffer;
	}

	close(fd);
	fclose(binFile);

	return 0;
}

/**
 * Call this function to start accelerators
 */
int start_accelerators(void) {
	volatile unsigned int *sdram_addr=NULL;
	volatile unsigned int *photo_addr=NULL;
	volatile unsigned int *first_addr=NULL;
	volatile unsigned int *second_addr=NULL;
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
	sdram_addr=(unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET ) & (
			HPS_BRIDGE_MASK ) ));

	//photo_addr=(unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET + PHOTO_OFFSET ) & (
	//		HPS_BRIDGE_MASK ) ));
	photo_addr = HPS_BRIDGE_BASE + SDRAM_OFFSET + PHOTO_OFFSET;

	//first_addr = (unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET + FIRST_BUFFER ) & (
	//		HPS_BRIDGE_MASK ) ));

	first_addr = HPS_BRIDGE_BASE + SDRAM_OFFSET + FIRST_BUFFER;

	//second_addr = (unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET + SECOND_BUFFER ) & (
	//		HPS_BRIDGE_MASK ) ));

	second_addr = HPS_BRIDGE_BASE + SDRAM_OFFSET + SECOND_BUFFER;

	/* Call convolutional network where we have a 3x128x128 photo located at photo_addr 
	 * (3x128x128x4bytes/num = 196,608 bytes)
	 * 
	 * Weights are located at sdram_addr, where we have (3x3x3x64x4 bytes = 6,912 bytes)
	 * 
	 * Read from photo, write to first buffer
	 */

	/**
	 * Call max pooling layer where 
	 *  -we read from first buffer
	 *  -we write to second buffer
	 *  -64 layers
	 * 	-126 row size
	 */

	/**
	 * Call convolution where
	 * input is at second buffer
	 * output is first buffer
	 * weights are located at base + 0x700
	 * 
	 */

	/**
	 * Call max pooling layer where 
	 *  -we read from first buffer
	 *  -we write to second buffer
	 *  -64 layers
	 * 	-61 row size
	 */

	/**
	 * Call convolution where
	 * input is at second buffer
	 * output is first buffer
	 * weights are located at base + 0x21780
	 * 
	 */

	/**
	 * Call max pooling layer where 
	 *  -we read from first buffer
	 *  -we write to second buffer
	 *  -64 layers
	 * 	-28 row size
	 */

	/**
	 * Call dense layer where 
	 *  -read from second buffer
	 *  -write to first buffer
	 *  -weights found at base + 0x2a7c0
	 *  -biases found at base + ee7c0
	 *  -activation length = 12544*64
	 */


	/**
	 * Call dense layer where 
	 *  -read from first buffer
	 *  -write to second buffer
	 *  -weights found at base + 0xee800
	 *  -biases found at base + ee9c0
	 *  -activation length = 64 * 7
	 */

	/**
	 *  Now just find the max of the first 7 numbers in second buffer
	 *  If max is index 5, return garbage
	 *  If max is index 1,2,4 return recycling
	 *  If max is index 0,3 return mixed paper
	 *  If max is index 6, return compost
	 */


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


/**
 * Turn leds on
 * 
 * Returns -1 on memory error, 0 on success
 */
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

	*leds = 0x3ff;

	return 0;
}

/**
 * Turn leds off
 * 
 * Returns -1 on memory error, 0 on success
 */
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

