#include <ctime>
#include <iostream>
#include <cassert>

// Interface of this cpp file is used by C code, we need to declare 
// extern "C" to prevent linking errors.
extern "C" {
#include "keystate/update_keyzones_cmd.h"
#include "keystate/update_keyzones_task.h"
#include "enforcer/enforce_task.h"
#include "shared/duration.h"
#include "shared/file.h"
#include "shared/str.h"
#include "daemon/engine.h"
}

static const char *module_str = "update_keyzones_cmd";

void
help_update_keyzones_cmd(int sockfd)
{
    char buf[ODS_SE_MAXLINE];
    snprintf(buf, ODS_SE_MAXLINE,
             "update zonelist update zonelist by importing zonelist.xml\n"
        );
    ods_writen(sockfd, buf, strlen(buf));
}

int
handled_update_keyzones_cmd(int sockfd, engine_type* engine, const char *cmd,
                            ssize_t n)
{
    char buf[ODS_SE_MAXLINE];
    task_type *task;
    ods_status status;
    const char *scmd = "update zonelist";

    cmd = ods_check_command(cmd,n,scmd);
    if (!cmd)
        return 0; // not handled

    ods_log_debug("[%s] %s command", module_str, scmd);
    
    /* perform task immediately */
    time_t tstart = time(NULL);
    perform_update_keyzones(sockfd,engine->config);
    (void)snprintf(buf, ODS_SE_MAXLINE, "%s completed in %ld seconds.\n",
                   scmd,time(NULL)-tstart);
    ods_writen(sockfd, buf, strlen(buf));

    flush_enforce_task(engine);

    return 1;
}