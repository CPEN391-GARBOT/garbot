#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <limits.h>
#include <sys/mman.h>

#define LW_REGS_BASE ( 0xff200000 )
#define LW_REGS_SPAN ( 0x00200000 )
#define LW_REGS_MASK ( LW_REGS_SPAN - 1 )

#define BUTTON_BASE 0x50
#define REAL_LED_BASE 0x00
#define CONV_OFFSET 0x30a0
#define POOLING_OFFSET 0x3080
#define DENSE_OFFSET 0x30c0

#define HPS_BRIDGE_BASE ( 0xc0000000 )
#define HPS_BRIDGE_SPAN ( 0x04000000 )
#define HPS_BRIDGE_MASK ( LW_REGS_SPAN - 1 )
#define SDRAM_OFFSET 0x0
#define PHOTO_OFFSET 0x00500000
#define FIRST_BUFFER 0x00600000
#define SECOND_BUFFER 0x00700000

#define FINAL_ABSOLUTE_MASK 0x7fff
#define FINAL_SIGN_MASK 0x8000

#define GARBAGE 1
#define COMPOST 2
#define PAPER 3
#define RECYCLING 4

#define NUM_WEIGHTS 3515932 / 4
#define NUM_PIXEL_VALUES 196608 / 4


/**
 * File writes file located at ./weights.bin into memory at the base of the SDRAM
 * Returns -1 if error occurs, 0 on success
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
	for (x = 0; x < NUM_WEIGHTS; x++) {
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

	FILE * binFile = fopen("./garbage.bin", "r");
	if (binFile == NULL) {
		printf( "ERROR: could not open our bin file ....\n" );
		close(fd);
		return( -1 );
	}

	//iterate over entire photo, note need to make size not hardcoded magic num...
	for (x = 0; x < NUM_PIXEL_VALUES; x++) {
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
	volatile unsigned int *sdram_addr_virtual=NULL;
	volatile unsigned int *photo_addr_virtual=NULL;
	volatile unsigned int *first_addr_virtual=NULL;
	volatile unsigned int *second_addr_virtual=NULL;

	volatile unsigned int *convolution_virtual=NULL;
	volatile unsigned int *pooling_virtual=NULL;
	volatile unsigned int *dense_virtual=NULL;

	int sdram_addr_physical;
	int photo_addr_physical;
	int first_addr_physical;
	int second_addr_physical;


	void *virtual_base_HW;
	void *virtual_base_LW;
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

	// get virtual address of the base of LW bus
	virtual_base_LW = mmap( NULL, LW_REGS_SPAN, ( PROT_READ | PROT_WRITE ),
		MAP_SHARED, fd, LW_REGS_BASE );
	if( virtual_base_LW == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return(-1);
	}


	// Get virtual address
	sdram_addr_virtual=(unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET ) & (
			HPS_BRIDGE_MASK ) ));
	photo_addr_virtual=(unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET + PHOTO_OFFSET ) & (
			HPS_BRIDGE_MASK ) ));
	first_addr_virtual = (unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET + FIRST_BUFFER ) & (
			HPS_BRIDGE_MASK ) ));
	second_addr_virtual = (unsigned int *)(virtual_base_HW + (( SDRAM_OFFSET + SECOND_BUFFER ) & (
			HPS_BRIDGE_MASK ) ));


	convolution_virtual = (unsigned int *)(virtual_base_LW + (( CONV_OFFSET ) & (
			HPS_BRIDGE_MASK ) ));
	pooling_virtual = (unsigned int *)(virtual_base_LW + (( POOLING_OFFSET ) & (
			HPS_BRIDGE_MASK ) ));
	dense_virtual = (unsigned int *)(virtual_base_LW + (( DENSE_OFFSET ) & (
			HPS_BRIDGE_MASK ) ));


	sdram_addr_physical = HPS_BRIDGE_BASE + SDRAM_OFFSET;
	photo_addr_physical = HPS_BRIDGE_BASE + SDRAM_OFFSET + PHOTO_OFFSET;
	first_addr_physical = HPS_BRIDGE_BASE + SDRAM_OFFSET + FIRST_BUFFER;
	second_addr_physical = HPS_BRIDGE_BASE + SDRAM_OFFSET + SECOND_BUFFER;


	/* Call convolutional network where we have a 3x128x128 photo located at photo_addr
	 *
	 *
	 * Weights are located at sdram_addr_physical, where we have (3x3x3x64x4 bytes = 6,912 bytes)
	 *
	 * Read from photo, write to first_addr_physical


	*(convolution_virtual+1) = photo_addr_physical;
	*(convolution_virtual+2) = sdram_addr_physical;
	*(convolution_virtual+3) = first_addr_physical;
	*(convolution_virtual+4) = 3;
	*(convolution_virtual+5) = 64;
	*(convolution_virtual+6) = 128;
	*(convolution_virtual+0) = 0;
*/

	/**
	 * Call max pooling layer where
	 *  -we read from first_addr_physical
	 *  -we write to second_addr_physical
	 *  -64 layers
	 * 	-126 row size
	 */

	*(pooling_virtual+1) = first_addr_physical;
	*(pooling_virtual+2) = second_addr_physical;
	*(pooling_virtual+3) = 64;
	*(pooling_virtual+4) = 126;
	*(pooling_virtual+0) = 0;


	/**
	 * Call convolution where
	 * input is at second_addr_physical
	 * output is first_addr_physical
	 * weights offset: (3x3x3x64 + 64) x 4bytes/weight = 7168bytes = 0x1c00
	 *


	*(convolution_virtual+1) = second_addr_physical;
	*(convolution_virtual+2) = sdram_addr_physical + 0x1c00;
	*(convolution_virtual+3) = first_addr_physical;
	*(convolution_virtual+4) = 64;
	*(convolution_virtual+5) = 64;
	*(convolution_virtual+6) = 63;
	*(convolution_virtual+0) = 0;
	*/

	/**
	 * Call max pooling layer where
	 *  -we read from first_addr_physical
	 *  -we write to second_addr_physical
	 *  -64 layers
	 * 	-61 row size
	 */

	*(pooling_virtual+1) = first_addr_physical;
	*(pooling_virtual+2) = second_addr_physical;
	*(pooling_virtual+3) = 64;
	*(pooling_virtual+4) = 61;
	*(pooling_virtual+0) = 0;

	/**
	 * Call convolution where
	 * input is at second_addr_physical
	 * output is first_addr_physical
	 * weights offset: (3x3x3x64 + 64 + 3x3x64x64 + 64) * 4bytes/weight = 154880bytes = 0x25d00
	 *


	*(convolution_virtual+1) = second_addr_physical;
	*(convolution_virtual+2) = sdram_addr_physical + 0x25d00;
	*(convolution_virtual+3) = first_addr_physical;
	*(convolution_virtual+4) = 64;
	*(convolution_virtual+5) = 64;
	*(convolution_virtual+6) = 30;
	*(convolution_virtual+0) = 0;
	*/

	/**
	 * Call max pooling layer where
	 *  -we read from first_addr_physical
	 *  -we write to second_addr_physical
	 *  -64 layers
	 * 	-28 row size
	 */

	*(pooling_virtual+1) = first_addr_physical;
	*(pooling_virtual+2) = second_addr_physical;
	*(pooling_virtual+3) = 64;
	*(pooling_virtual+4) = 28;
	*(pooling_virtual+0) = 0;

	/**
	 * Call dense layer where
	 *  -read from second buffer
	 *  -write to first buffer
	 *  -weights offset: (3x3x3x64 + 64 + 3x3x64x64 + 64 + 3x3x64x64 + 64) * 4bytes/weight = 302592bytes = 0x49e00
	 *  -biases offset: (3x3x3x64 + 64 + 3x3x64x64 + 64 + 3x3x64x64 + 64 + 12544x64) * 4bytes/weight = 3513856bytes = 0x359e00
	 *  -activation length = 12544*64
	 */


	*(dense_virtual+1) = sdram_addr_physical + 0x359e00;
	*(dense_virtual+2) = sdram_addr_physical + 0x49e00;
	*(dense_virtual+3) = second_addr_physical;
	*(dense_virtual+4) = first_addr_physical;
	*(dense_virtual+5) = 12544*64;
	*(dense_virtual+0) = 0;


	/**
	 * Call dense layer where
	 *  -read from first buffer
	 *  -write to second buffer
	 *  -weights offset: (3x3x3x64 + 64 + 3x3x64x64 + 64 + 3x3x64x64 + 64 + 12544x64 + 64) * 4bytes/weight = 3514112bytes = 0x359f00
	 *  -biases offset: (3x3x3x64 + 64 + 3x3x64x64 + 64 + 3x3x64x64 + 64 + 12544x64 + 64 + 64x7) * 4bytes/weight = 3515904bytes = 0x35a600
	 *  -activation length = 64 * 7
	 */

	*(dense_virtual+1) = sdram_addr_physical + 0x35a600;
	*(dense_virtual+2) = sdram_addr_physical + 0x359f00;
	*(dense_virtual+3) = first_addr_physical;
	*(dense_virtual+4) = second_addr_physical;
	*(dense_virtual+5) = 64*7;
	*(dense_virtual+0) = 0;

	/**
	 *  Now just find the max of the first 7 numbers in second buffer
	 *  If max is index 5, return garbage
	 *  If max is index 1,2,4 return recycling
	 *  If max is index 0,3 return mixed paper
	 *  If max is index 6, return compost
	 */
	int x;
	int value;
	int maxValue = INT_MIN;
	int maxIndex = 0;

	for (x = 0; x < 7; x++) {
		unsigned int absolute = *(second_addr_virtual + x) & FINAL_ABSOLUTE_MASK;

		if (*(second_addr_virtual + x) & FINAL_SIGN_MASK) {
			//this number is negative
			value = -1 * absolute;
		} else {
			value = absolute;
		}

		if (value > maxValue) {
			maxValue = value;
			maxIndex = x;
		}
	}

	if (maxIndex == 5) {
		close( fd );
		return GARBAGE;
	} else if (maxIndex == 6) {
		close( fd );
		return COMPOST;
	} else if ((maxIndex == 0) || (maxIndex == 3)) {
		close( fd );
		return PAPER;
	} else {
		close( fd );
		return RECYCLING;
	}


}


/**
 *  Waits for a button push, then returns result of pushing said button.
 *
 *  Returns -1 on error, 1 on garbage, 2 on compost, 3 on paper, 4 on recycling
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
	virtual_base_LW = mmap( NULL, LW_REGS_SPAN, ( PROT_READ | PROT_WRITE ),
		MAP_SHARED, fd, LW_REGS_BASE );
	if( virtual_base_LW == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return(-1);
	}


	//Get address of buttons
	buttons =(unsigned int *)(virtual_base_LW + (( BUTTON_BASE ) & (
		LW_REGS_MASK ) ));

	//sleep(1);

	while(*buttons == 0xf) {
		continue;
	}

	if ((*buttons & 0x8) == 0) {
		close(fd);
		return GARBAGE;
	} else if ((*buttons & 0x4) == 0) {
		close(fd);
		return COMPOST;
	} else if ((*buttons & 0x2) == 0) {
		close(fd);
		return PAPER;
	} else if ((*buttons & 0x1) == 0) {
		close(fd);
		return RECYCLING;
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
	virtual_base_LW = mmap( NULL, LW_REGS_SPAN, ( PROT_READ | PROT_WRITE ),
		MAP_SHARED, fd, LW_REGS_BASE );
	if( virtual_base_LW == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return(-1);
	}


	//Get address of buttons
	leds =(unsigned int *)(virtual_base_LW + (( REAL_LED_BASE ) & (
		LW_REGS_MASK ) ));

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
	virtual_base_LW = mmap( NULL, LW_REGS_SPAN, ( PROT_READ | PROT_WRITE ),
		MAP_SHARED, fd, LW_REGS_BASE );
	if( virtual_base_LW == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return(-1);
	}


	//Get address of buttons
	leds =(unsigned int *)(virtual_base_LW + (( REAL_LED_BASE ) & (
		LW_REGS_MASK ) ));

	*leds = 0x0;

	return 0;
}

/**
 * Read the weight/value at sdram_base + offset
 *
 * Returns value in memory
 */
int read_sdram(int offset) {
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


	return *(sdram_addr + offset);
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
