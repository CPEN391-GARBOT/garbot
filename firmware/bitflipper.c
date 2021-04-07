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

int main(void)
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
}
