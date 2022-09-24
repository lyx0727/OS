#include "types.h"
#include "stat.h"
#include "user.h"

int
main()
{
    int p_son[2], p_par[2];
    pipe(p_son);
    pipe(p_par);
    if(fork() == 0){
        close(p_par[1]);
        close(p_son[0]);
        char buf[2];
        read(p_par[0], buf, 1);
        close(p_par[0]);
        printf(1, "%d: received ping\n",getpid());
        write(p_son[1], buf, 2);
        close(p_son[1]);
    } 
    else{
        close(p_son[1]);
        close(p_par[0]);
        write(p_par[1], "@", 2);
        close(p_par[1]);
        char buf[2];
        read(p_son[0], buf, 1);
        close(p_son[0]);
        printf(1, "%d: received pong\n",getpid());
    }
    exit();
}