/*
 * Copyright (c) 2009,2018 NLNet Labs. All rights reserved.
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

#include "config.h"

#include<signal.h>
#include <errno.h>
#include <fcntl.h> /* fcntl() */
#include <stdio.h> /* fprintf() */
#include <string.h> /* strerror(), strncmp(), strlen(), strcpy(), strncat() */
#include <strings.h> /* bzero() */
#include <sys/select.h> /* select(), FD_ZERO(), FD_SET(), FD_ISSET(), FD_CLR() */
#include <sys/socket.h> /* socket(), connect(), shutdown() */
#include <sys/un.h>
#include <unistd.h> /* exit(), read(), write() */
#include <getopt.h>
/* According to earlier standards, we need sys/time.h, sys/types.h, unistd.h for select() */
#include <sys/types.h>
#include <sys/time.h>
#include <stdlib.h>
#include <assert.h>
#ifdef HAVE_READLINE
    /* cmd history */
    #include <readline/readline.h>
    #include <readline/history.h>
#endif

#include "file.h"
#include "log.h"
#include "str.h"
#include "clientpipe.h"
#include "ods-signer-api.h"

static const char* PROMPT = "cmd> ";
static const char* cli_str = "client";

/**
 * Consume messages in buffer
 * 
 * Read all complete messages in the buffer or until EXIT message 
 * is read. Messages larger than ODS_SE_MAXLINE can be handled but
 * will be truncated.
 * 
 * \param buf: buffer to read from. Must not be NULL.
 * \param pos: length of valid data in buffer, must never exceed buflen.
 *           Must not be NULL.
 * \param buflen: Capacity of buf, must not exeed ODS_SE_MAXLINE.
 * \param exitcode[out]: Return code from the daemon, only valid
 *                       when returned 1. Must not be NULL.
 * \return: -1 An error occured
 *           1 daemon done handling command, exitcode is set,
 *           0 otherwise 
 */
/* return 0 or (1 and exit code set) or -1*/
static int
extract_msg(char* buf, int *pos, int buflen, int *exitcode, int sockfd)
{
    char data[ODS_SE_MAXLINE+1], opc;
    int datalen;
    
    assert(buf);
    assert(pos);
    assert(exitcode);
    assert(*pos <= buflen);
    assert(ODS_SE_MAXLINE >= buflen);
    
    while (1) {
        /* Do we have a complete header? */
        if (*pos < 3) return 0;
        opc = buf[0];
        datalen = (buf[1]<<8) | (buf[2]&0xFF);
	datalen &= 0xFFFF; /* hopefully sooth tainted data checker */
        if (datalen+3 <= *pos) {
            /* a complete message */
            memset(data, 0, ODS_SE_MAXLINE+1);
            memcpy(data, buf+3, datalen);
            *pos -= datalen+3;
            memmove(buf, buf+datalen+3, *pos);
          
            if (opc == CLIENT_OPC_EXIT) {
                fflush(stdout);
                if (datalen != 1) return -1;
                *exitcode = (int)buf[3];
                return 1;
            }
            switch (opc) {
                case CLIENT_OPC_STDOUT:
                    fprintf(stdout, "%s", data);
                    break;
                case CLIENT_OPC_STDERR:
                    fprintf(stdout, "%s", data);
                    break;
                case CLIENT_OPC_PROMPT:
                    fprintf(stdout, "%s", data); 
                    fflush(stdout);
                    /* listen for input here */
                    if (!client_handleprompt(sockfd)) {
                        fprintf(stdout, "\n");
                        *exitcode = ODS_SIGNER_API_STATUS_CLIENT_INPUT_ERROR2;
                        return 1;
                    }
		default:
			break;
            }
            continue;
        } else if (datalen+3 > buflen) {
            /* Message is not going to fit! Discard the data already 
             * received */
            fprintf(stderr, "Daemon message to big, truncating.\n");
            datalen -= *pos - 3;
            buf[1] = datalen >> 8;
            buf[2] = datalen & 0xFF;
            *pos = 3;
            return 0;
        }
        return 0; /* waiting for more data */
    }
}

/**
 * Start interface - Set up connection and handle communication
 *
 * \param cmd: command to exec, NULL for interactive mode.
 * \param servsock_filename: name of pipe to connect to daemon. Must 
 *        not be NULL.
 * \return exit code for client
 */
ods_signer_api_status
interface_start(const char* cmd, const char* servsock_filename)
{
    struct sockaddr_un servaddr;
    fd_set rset;
    int sockfd, flags, exitcode = 0;
    int ret, n, r, inbuf_pos = 0;
    ods_signer_api_status error = ODS_SIGNER_API_STATUS_OK;
    char userbuf[ODS_SE_MAXLINE], inbuf[ODS_SE_MAXLINE];

    assert(servsock_filename);

    /* Create a socket */
    if ((sockfd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        fprintf(stderr, "Socket creation failed: %s\n", strerror(errno));
        return ODS_SIGNER_API_STATUS_SOCKET_CREATION_FAILED;
    }
    bzero(&servaddr, sizeof(servaddr));
    servaddr.sun_family = AF_UNIX;
    strncpy(servaddr.sun_path, servsock_filename, sizeof(servaddr.sun_path) - 1);
    
    if (connect(sockfd, (const struct sockaddr*) &servaddr, sizeof(servaddr)) == -1) {
        if (cmd) {
            if (strncmp(cmd, "start", 5) == 0) {
                exitcode = system(ODS_SE_ENGINE); 
                if (exitcode == 0) {
                    close(sockfd);
                    return ODS_SIGNER_API_STATUS_OK;
                }
                fprintf(stderr, "Failed to start signer engine\n");
                close(sockfd);
                return ODS_SIGNER_API_STATUS_COMMAND_FAILED;
            } else if (strcmp(cmd, "running\n") == 0) {
                fprintf(stdout, "Engine not running.\n");
                close(sockfd);
                return ODS_SIGNER_API_STATUS_NOT_RUNNING_OR_START_FAILED;
            }
        }
        fprintf(stderr, 
            "Unable to connect to engine. connect() failed: "
            "%s (\"%s\")\n", strerror(errno), servsock_filename);
        close(sockfd);
        return ODS_SIGNER_API_STATUS_CONNECT_FAILED;
    }
    /* set socket to non-blocking */
    if ((flags = fcntl(sockfd, F_GETFL, 0)) == -1) {
        ods_log_error("[%s] unable to start interface, fcntl(F_GETFL) "
            "failed: %s", cli_str, strerror(errno));
        close(sockfd);
        return ODS_SIGNER_API_STATUS_CONNECT_SETUP1_FAILED;
    } else if (fcntl(sockfd, F_SETFL, flags|O_NONBLOCK) == -1) {
        ods_log_error("[%s] unable to start interface, fcntl(F_SETFL) "
            "failed: %s", cli_str, strerror(errno));
        close(sockfd);
        return ODS_SIGNER_API_STATUS_CONNECT_SETUP2_FAILED;
    }
    
    /* If we have a cmd send it to the daemon, otherwise display a
     * prompt */
    if (cmd) client_stdin(sockfd, cmd, strlen(cmd)+1);

    userbuf[0] = 0;
    do {
        if (!cmd) {
#ifdef HAVE_READLINE
            char *icmd_ptr;
            if ((icmd_ptr = readline(PROMPT)) == NULL) { /* eof */
                printf("\n");
                break;
            }
            if (snprintf(userbuf, ODS_SE_MAXLINE, "%s", icmd_ptr) >= ODS_SE_MAXLINE) {
                break;
            }
            free(icmd_ptr);
            ods_str_trim(userbuf,0);
            if (strlen(userbuf) > 0) add_history(userbuf);
#else        
            fprintf(stdout, "%s", PROMPT);
            fflush(stdout);
            n = read(fileno(stdin), userbuf, ODS_SE_MAXLINE);
            if (n == 0) { /* eof */
                printf("\n");
                break;
            } else if (n == -1) {
                error = ODS_SIGNER_API_STATUS_CLIENT_INPUT_ERROR;
                break;
            }
            userbuf[n] = 0;
            ods_str_trim(userbuf,0);
#endif
            /* These commands don't go through the pipe */
            if (strcmp(userbuf, "exit") == 0 || strcmp(userbuf, "quit") == 0)
                break;
            /* send cmd through pipe */
            if (!client_stdin(sockfd, userbuf, strlen(userbuf))) {
                /* only try start on fail to send */
                if (strcmp(userbuf, "start") == 0) {
                    if (system(ODS_EN_ENGINE) != 0) {
                        fprintf(stderr, "Error: Daemon reported a failure starting. "
                            "Please consult the logfiles.\n");
                        error = ODS_SIGNER_API_STATUS_NOT_RUNNING_OR_START_FAILED;
                    }
                    continue;
                }
            }
        }

        while (1) {
            /* Clean the readset and add the pipe to the daemon */
            FD_ZERO(&rset);
            FD_SET(sockfd, &rset);
        
            ret = select(sockfd+1, &rset, NULL, NULL, NULL);
            if (ret < 0) {
                /* *SHRUG* just some interrupt*/
                if (errno == EINTR) continue;
                /* anything else is an actual error */
                perror("select()");
                error = ODS_SIGNER_API_STATUS_ERROR_SELECTING;
                break;
            }
            /* Handle data coming from the daemon */
            if (FD_ISSET(sockfd, &rset)) { /*daemon pipe is readable*/
                n = read(sockfd, inbuf+inbuf_pos, ODS_SE_MAXLINE-inbuf_pos);
                if (n == 0) { /* daemon closed pipe */
                    fprintf(stderr, "[Remote closed connection]\n");
                    error = ODS_SIGNER_API_STATUS_REMOTE_CLOSED_CONNECTION;
                    break;
                } else if (n == -1) { /* an error */
                    if (errno == EAGAIN || errno == EWOULDBLOCK) continue;
                    perror("read()");
                    error = ODS_SIGNER_API_STATUS_ERROR_READING;
                    break;
                }
                inbuf_pos += n;
                r = extract_msg(inbuf, &inbuf_pos, ODS_SE_MAXLINE, &exitcode, sockfd);
                if (r == -1) {
                    fprintf(stderr, "Error handling message from daemon\n");
                    error = ODS_SIGNER_API_STATUS_DAEMON_BAD_MESSAGE;
                    break;
                } else if (r == 1) {
                    if (cmd) 
                        error = exitcode;
                    else if (strlen(userbuf) != 0)
                        /* we are interactive so print response.
                         * But also suppress when no command is given. */
                        fprintf(stderr, "Daemon exit code: %d\n", exitcode);
                    break;
                }
            }
        }
        if (strlen(userbuf) != 0 && !strncmp(userbuf, "stop", 4))
            break;
    } while (error == 0 && !cmd);
    close(sockfd);

    if ((cmd && !strncmp(cmd, "stop", 4)) || 
        (strlen(userbuf) != 0 && !strncmp(userbuf, "stop", 4))) {
        char line[80];
        FILE *cmd2 = popen("pgrep ods-signerd","r");
        fgets(line, 80, cmd2);
        (void) pclose(cmd2);
        pid_t pid = strtoul(line, NULL, 10);
        fprintf(stdout, "pid %d\n", pid);
        int time = 0;
        error = ODS_SIGNER_API_STATUS_OK;
        while (pid > 0) {
           if(kill(pid, 0) == 0){
               sleep(1);
               time += 1;
               if (time>20) {
                  printf("signer needs more time to stop...\n");
                  time = 0;
               }
           }
           else
               break;
       }
    }

#ifdef HAVE_READLINE
    clear_history();
    rl_free_undo_list();
#endif
    return error;
}

ods_signer_api_status
execute_signer_command(const char *cmd, const char *servsock_filename)
{
   if (cmd == NULL) {
      return ODS_SIGNER_API_STATUS_WRONG_ARGS;
   }
   return interface_start(cmd, servsock_filename);
}
