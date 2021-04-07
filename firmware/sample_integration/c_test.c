#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

//enum garbageTypes {Metal, Plastic, Glass, Compost, Garbage, Cardboard};

int main(void) {
    while(1) {
        int sleepTime = (rand() % 4) + 1; //generate random number between 1-4 representing seconds inbetween each "photo"
        //int sleepTime = 1;
        sleep(sleepTime);

        int garbageIdentifier = (rand() % 6); //generate random number representing selected garbage

        switch(garbageIdentifier) {
            case 0:
                printf("Metal detected\n");
                break;
            case 1:
                printf("Plastic detected\n");
                break;
            case 2:
                printf("Glass detected\n");
                break;
            case 3:
                printf("Compost detected\n");
                break;
            case 4:
                printf("Garbage detected\n");
                break;
            case 5:
                printf("Cardboard detected\n");
                break;
        }

        fflush(stdout);
    }

    return 0;
}