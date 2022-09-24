#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
    if(argc==1){
        printf(1, "Error no param\n");
    }
    else if(argc >2){
        printf(1, "Too many params\n");
    }
    else{
        int t = atoi(argv[1]);
        printf(1, "Now sleep %d clock ticks\n", t);
        sleep(t);
    }
    exit();
}