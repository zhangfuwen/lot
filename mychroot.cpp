#include <stdio.h>
#include <unistd.h>
#include <errno.h>

#include <sched.h>
#include <sys/wait.h>
#include <string.h>


int run_bash(void * args);

int main()
{
    int ret = chroot("./root-fs");
    if (ret < 0) {
        printf("failed to chroot, %s", strerror(errno));
        return -1;
    }

    static char child_stack[1048576];
    pid_t child_pid = clone(run_bash, child_stack+1048576, CLONE_NEWPID | CLONE_NEWUSER | SIGCHLD, NULL);
    printf("clone() = %ld\n", (long)child_pid);
    perror("clone error message");
    waitpid(child_pid, NULL, 0);
    return 0;
}

int run_bash(void * args)
{
  const char *binaryPath = "/usr/bin/env";
  const char *arg1 = "-i";
  const char *arg2 = "HOME=/root";
  const char *arg3 = "USER=root";
  const char *arg4 = "PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games";
  const char *arg5 = "TERM=xterm-256color";
  const char *arg6 = "LANG=C.UTF-8";
  const char *arg7 = "/usr/bin/bash";
  const char *arg8 = "--login";
  execl(binaryPath, binaryPath, 
          arg1, 
          arg2, 
          arg3,
          arg4,
          arg5,
          arg6,
          arg7,
          arg8,
          NULL);
}
