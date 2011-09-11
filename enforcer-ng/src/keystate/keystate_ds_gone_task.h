#ifndef _KEYSTATE_DS_GONE_TASK_H_
#define _KEYSTATE_DS_GONE_TASK_H_

#include "daemon/cfg.h"
#include "scheduler/task.h"

void perform_keystate_ds_gone(int sockfd, engineconfig_type *config,
                              const char *zone, const char *id);

#endif