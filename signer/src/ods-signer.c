/*
 * Copyright (c) 2009 NLNet Labs. All rights reserved.
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
 * OpenDNSSEC signer engine client.
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
#include "signer-api.h"

/**
 * Prints usage.
 *
 */
static void
usage(char* argv0, FILE* out)
{
    fprintf(out, "Usage: %s [<cmd>]\n", argv0);
    fprintf(out, "Simple command line interface to control the signer "
                 "engine daemon.\nIf no cmd is given, the tool is going "
                 "into interactive mode.\n");

    fprintf(out, "\nSupported options:\n");
    fprintf(out, " -h | --help             Show this help and exit.\n");
    fprintf(out, " -V | --version          Show version and exit.\n");
    fprintf(out, " -s | --socket <file>    Daemon socketfile \n"
        "    |    (default %s).\n", ODS_SE_SOCKFILE);

    fprintf(out, "\nBSD licensed, see LICENSE in source package for "
                 "details.\n");
    fprintf(out, "Version %s. Report bugs to <%s>.\n",
        PACKAGE_VERSION, PACKAGE_BUGREPORT);
}

/**
 * Prints version.
 *
 */
static void
version(FILE* out)
{
    fprintf(out, "%s version %s\n", PACKAGE_NAME, PACKAGE_VERSION);
}


int
main(int argc, char* argv[])
{
    char* argv0;
    char* cmd = NULL;
    char const *socketfile = ODS_SE_SOCKFILE;
    int error, c, options_index = 0;
    static struct option long_options[] = {
        {"help", no_argument, 0, 'h'},
        {"socket", required_argument, 0, 's'},
        {"version", no_argument, 0, 'V'},
        { 0, 0, 0, 0}
    };
    
    ods_log_init("ods-signerd", 0, NULL, 0);

    /* Get the name of the program */
    if((argv0 = strrchr(argv[0],'/')) == NULL)
        argv0 = argv[0];
    else
        ++argv0;

    if (argc > 5) {
        fprintf(stderr,"error, too many arguments (%d)\n", argc);
        exit(1);
    }

   /* parse the commandline. The + in the arg string tells getopt
     * to stop parsing when an unknown command is found not starting 
     * with '-'. This is important for us, else switches inside commands
     * would be consumed by getopt. */
    while ((c=getopt_long(argc, argv, "+hVs:",
        long_options, &options_index)) != -1) {
        switch (c) {
            case 'h':
                usage(argv0, stdout);
                exit(1);
            case 's':
                socketfile = optarg;
                printf("sock set to %s\n", socketfile);
                break;
            case 'V':
                version(stdout);
                exit(0);
            default:
                /* unrecognized options 
                 * getopt will report an error */
                fprintf(stderr, "use --help for usage information\n");
                exit(1);
        }
    }
    argc -= optind;
    argv += optind;
    if (!socketfile) {
        fprintf(stderr, "Enforcer socket file not set.\n");
        return 101;
    }
    if (argc != 0) 
        cmd = ods_strcat_delim(argc, argv, ' ');
    error = interface_start(cmd, socketfile);
    free(cmd);
    return error;
}
