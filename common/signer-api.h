/*
 * Copyright (c) 2018 NLNet Labs. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/**
 * OpenDNSSEC signer engine api client.
 *
 */

#ifndef SIGNER_API_H
#define SIGNER_API_H

#include "config.h"

enum ods_enum_signer_api_status {
   ODS_SIGNER_API_STATUS_WRONG_ARGS = -1,
   ODS_SIGNER_API_STATUS_OK = 0,
   ODS_SIGNER_API_STATUS_COMMAND_FAILED,
   ODS_SIGNER_API_STATUS_SOCKET_CREATION_FAILED = 200,
   ODS_SIGNER_API_STATUS_CONNECT_FAILED,
   ODS_SIGNER_API_STATUS_CONNECT_SETUP1_FAILED,
   ODS_SIGNER_API_STATUS_CONNECT_SETUP2_FAILED,
   ODS_SIGNER_API_STATUS_ERROR_SELECTING,
   ODS_SIGNER_API_STATUS_CLIENT_INPUT_ERROR,
   ODS_SIGNER_API_STATUS_REMOTE_CLOSED_CONNECTION,
   ODS_SIGNER_API_STATUS_ERROR_READING,
   ODS_SIGNER_API_STATUS_DAEMON_BAD_MESSAGE,
   ODS_SIGNER_API_STATUS_NOT_RUNNING_OR_START_FAILED,
   ODS_SIGNER_API_STATUS_CLIENT_INPUT_ERROR2 = 300,
};
typedef enum ods_enum_signer_api_status ods_signer_api_status;

/**
 * Start interface - Set up connection and handle communication
 *
 * \param cmd: command to exec, NULL for interactive mode.
 * \param servsock_filename: name of pipe to connect to daemon. Must 
 *        not be NULL.
 * \return exit code for client
 */
ods_signer_api_status
interface_start(const char* cmd, const char* servsock_filename);

/**
 * Execute signer command - Set up connection and handle communication for executing single command
 *
 * \param cmd: command to exec, must not be NULL.
 * \param servsock_filename: name of pipe to connect to daemon. Must 
 *        not be NULL.
 * \return exit code for client
 */
ods_signer_api_status
execute_signer_command(const char *cmd, const char *servsock_filename);

#endif /* SHARED_HSM_H */
