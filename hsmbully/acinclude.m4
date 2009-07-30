#### N.B.:  DO NOT EDIT THIS FILE - IT IS AUTOGENERATED

# $Id: acx_64bit.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_64BIT],[
	AC_ARG_ENABLE(
	        [64bit],
        	[AS_HELP_STRING([--enable-64bit],[enable 64-bit compiling])],
	        [enable_64bit="yes"],
	        [enable_64bit="no"])

	if test "x$enable_64bit" = "xyes"
	then
	        AC_MSG_CHECKING(if we can compile in 64-bit mode)
	        tmp_CFLAGS=$CFLAGS
	        CFLAGS="-m64"
	        AC_RUN_IFELSE(
	                [
				AC_LANG_PROGRAM([],[return sizeof(void*) == 8 ? 0 : 1;])
			], [
	                        AC_MSG_RESULT(yes)
	                        CXXFLAGS="-m64 $CXXFLAGS"
	                        LDFLAGS="-m64 $LDFLAGS"
	                        CFLAGS="-m64 $tmp_CFLAGS"
	                ],[
	                        AC_MSG_RESULT(no)
	                        AC_MSG_ERROR([Don't know how to compile in 64-bit mode.])
	                ]
	        )
	        CFLAGS=$tmp_CFLAGS
	fi

])
AC_DEFUN([ACX_ABS_SRCDIR], [
case "$srcdir" in
  .) # No --srcdir option.  We are building in place.
    ac_sub_srcdir=`pwd` ;;
  /*) # Absolute path.
    ac_sub_srcdir=$srcdir/$ac_config_dir ;;
  *) # Relative path.
    ac_sub_srcdir=`pwd`/$ac_dots$srcdir/$ac_config_dir ;;
esac
])
# $Id: acx_botan.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_BOTAN],[
	AC_ARG_WITH(botan,
        	AC_HELP_STRING([--with-botan=DIR],[Location of the Botan crypto library]),
		[
			BOTAN_PATH="$withval"
		],
		[
			BOTAN_PATH="/usr/local"
		])

	AC_MSG_CHECKING(what are the Botan includes)
	BOTAN_INCLUDES="-I$BOTAN_PATH/include"
	AC_MSG_RESULT($BOTAN_INCLUDES)

	AC_MSG_CHECKING(what are the Botan libs)
	BOTAN_LIBS="-L$BOTAN_PATH/lib -lbotan"
	AC_MSG_RESULT($BOTAN_LIBS)

	tmp_CPPFLAGS=$CPPFLAGS
	tmp_LIBS=$LIBS

	CPPFLAGS="$CPPFLAGS $BOTAN_INCLUDES"
	LIBS="$LIBS $BOTAN_LIBS"

	AC_LANG_PUSH([C++])
	AC_LINK_IFELSE(
		[AC_LANG_PROGRAM([#include <botan/init.h>
			#include <botan/pipe.h>
			#include <botan/filters.h>
			#include <botan/hex.h>
			#include <botan/sha2_32.h>
			#include <botan/emsa3.h>],
			[using namespace Botan;
			LibraryInitializer::initialize();
			new EMSA3_Raw();])],
		[AC_MSG_RESULT([checking for Botan >= v1.8.0 ... yes])],
		[AC_MSG_RESULT([checking for Botan >= v1.8.0 ... no])
		 AC_MSG_ERROR([Missing the correct version of the Botan library])]
	)
	AC_LINK_IFELSE(
		[AC_LANG_PROGRAM([#include <botan/init.h>
			#include <botan/pipe.h>
			#include <botan/filters.h>
			#include <botan/hex.h>
			#include <botan/sha2_32.h>
			#include <botan/auto_rng.h>
			#include <botan/emsa3.h>],
			[using namespace Botan;
			LibraryInitializer::initialize();
			new EMSA3_Raw();
			AutoSeeded_RNG *rng = new AutoSeeded_RNG();
			rng->reseed();])],
		[AC_MSG_RESULT([checking for Botan reseed API fix ... no])],
		[AC_MSG_RESULT([checking for Botan reseed API fix ... yes])
		AC_DEFINE_UNQUOTED(
			[BOTAN_RESEED_FIX],
			[1],
			[Fixes an API problem within Botan]
		)]
	)
	AC_LANG_POP([C++])

	CPPFLAGS=$tmp_CPPFLAGS
	LIBS=$tmp_LIBS

	AC_SUBST(BOTAN_INCLUDES)
	AC_SUBST(BOTAN_LIBS)
])
# $Id: acx_cunit.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_CUNIT],[
	AC_ARG_WITH(cunit,
		[AC_HELP_STRING([--with-cunit=DIR],[Look for cunit in this dir])],
        	[
			CUNIT_PATH="$withval"
		],[
			CUNIT_PATH="/usr/local"
		])

	AC_MSG_CHECKING(what are the cunit includes)
	CUNIT_INCLUDES="-I$CUNIT_PATH/include"
	AC_MSG_RESULT($CUNIT_INCLUDES)

	AC_MSG_CHECKING(what are the cunit libs)
	CUNIT_LIBS="-L$CUNIT_PATH/lib -lcunit"
	AC_MSG_RESULT($CUNIT_LIBS)

	AC_SUBST(CUNIT_INCLUDES)
	AC_SUBST(CUNIT_LIBS)
])
# $Id: acx_dbparams.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_DBPARAMS],[

	AC_ARG_WITH(dbname,
		[AS_HELP_STRING([--with-dbname=DB_NAME],[Database name/schema for unit tests])],
		DB_NAME="$withval"
	)
	AC_SUBST(DB_NAME)
	
	AC_ARG_WITH(dbhost,
		[AS_HELP_STRING([--with-dbhost=DB_HOST],[Database host for unit tests])],
		DB_HOST="$withval"
	)
	AC_SUBST(DB_HOST)
	
	AC_ARG_WITH(dbuser,
		[AS_HELP_STRING([--with-dbuser=DB_USER],[Database user for unit tests])],
		DB_USER="$withval"
	)
	AC_SUBST(DB_USER)
	
	AC_ARG_WITH(dbpass,
		[AS_HELP_STRING([--with-dbpass=DB_PASS],[Database password for unit tests])],
		DB_PASS="$withval"
	)
	AC_SUBST(DB_PASS)
])
# $Id: acx_dlopen.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_DLOPEN],[
  AC_CHECK_FUNC(dlopen, [AC_DEFINE(HAVE_DLOPEN,1,[Define if you have dlopen])],
  [
    AC_CHECK_LIB([dl],[dlopen], 
      [AC_DEFINE(HAVE_DLOPEN,1,[Define if you have dlopen])
      LIBS="$LIBS -ldl"],
      [AC_CHECK_FUNC(LoadLibrary, 
        [if test $ac_cv_func_LoadLibrary = yes; then
          AC_DEFINE(HAVE_LOADLIBRARY, 1, [Whether LoadLibrary is available])
        fi
        ], [AC_MSG_ERROR(No dynamic library loading support)]
      )]
    )
  ])
])
# $Id: acx_ldns.m4 1428 2009-07-30 10:41:25Z jakob $

AC_DEFUN([ACX_LDNS],[
	AC_ARG_WITH(ldns, 
		[AC_HELP_STRING([--with-ldns=PATH],[specify prefix of path of ldns library to use])],
        	[
			LDNS_PATH="$withval"
			AC_PATH_PROGS(LDNS_CONFIG, ldns-config, ldns-config, $LDNS_PATH/bin)
		],[
			LDNS_PATH="/usr/local"
			AC_PATH_PROGS(LDNS_CONFIG, ldns-config, ldns-config, $PATH)
		])

	if test -x "$LDNS_CONFIG"
	then
		AC_MSG_CHECKING(what are the ldns includes)
		LDNS_INCLUDES="`$LDNS_CONFIG --cflags`"
		AC_MSG_RESULT($LDNS_INCLUDES)

		AC_MSG_CHECKING(what are the ldns libs)
		LDNS_LIBS="`$LDNS_CONFIG --libs`"
		AC_MSG_RESULT($LDNS_LIBS)
	else
		AC_MSG_CHECKING(what are the ldns includes)
		LDNS_INCLUDES="-I$LDNS_PATH/include"
		AC_MSG_RESULT($LDNS_INCLUDES)

		AC_MSG_CHECKING(what are the ldns libs)
		LDNS_LIBS="-L$LDNS_PATH/lib -lldns"
		AC_MSG_RESULT($LDNS_LIBS)
	fi

	tmp_CPPFLAGS=$INCLUDES
	tmp_LIBS=$LIBS

	CPPFLAGS="$CPPFLAGS $LDNS_INCLUDES"
	LIBS="$LIBS $LDNS_LIBS"

	AC_CHECK_LIB(ldns, ldns_rr_new,,[AC_MSG_ERROR([Can't find ldns library])])
	AC_CHECK_FUNC(ldns_sha1,[],[AC_MSG_ERROR([ldns library too old (1.6.0 or later required)])])
	
	CPPFLAGS=$tmp_INCLUDES
	LIBS=$tmp_LIBS

	AC_SUBST(LDNS_INCLUDES)
	AC_SUBST(LDNS_LIBS)
])
# $Id: acx_libhsm.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_LIBHSM],[
	AC_ARG_WITH(libhsm, 
        	AC_HELP_STRING([--with-libhsm=PATH],[Specify prefix of path of libhsm]),
        	[
			LIBHSM_PATH="$withval"
		],[
			LIBHSM_PATH="/usr/local"
		])

	AC_MSG_CHECKING(what are the libhsm includes)
	LIBHSM_INCLUDES="-I$LIBHSM_PATH/include"
	AC_MSG_RESULT($LIBHSM_INCLUDES)

	AC_MSG_CHECKING(what are the libhsm libs)
	LIBHSM_LIBS="-L$LIBHSM_PATH/lib -lhsm"
	AC_MSG_RESULT($LIBHSM_INCLUDES)

	tmp_CPPFLAGS=$CPPFLAGS
	tmp_LIBS=$LIBS

	CPPFLAGS="$CPPFLAGS $XML2_INCLUDES $LIBHSM_INCLUDES"
	LIBS="$LIBS -L$LIBHSM_PATH/lib"

	BUILD_LIBHSM=""
	
	ACX_ABS_SRCDIR # defines ac_sub_srcdir as an absolute path
	
	# dnl ok we don't have an installed library, use the source
	# (makefile will figure it out)
	if test ! -f $ac_sub_srcdir/../../libhsm/src/libhsm.h; then
		if test ! -f $ac_sub_srcdir/../libhsm/src/libhsm.h; then
			AC_CHECK_HEADERS(libhsm.h, [
				AC_CHECK_LIB(hsm,hsm_create_context,, [
					AC_MSG_ERROR([libhsm not found on system, and libhsm source not present, use --with-libhsm=path.])
				])
			], [
				AC_MSG_ERROR([libhsm headers not found in source tree or on system])
			])
		else
			LIBHSM_INCLUDES="$LIBHSM_INCLUDE -I$ac_sub_srcdir/../libhsm/src"
			LIBHSM_LIBS="$LIBHSM_LIBS -L../../libhsm/src/.libs"
			BUILD_LIBHSM="../../libhsm/src/libhsm.la"
		fi
	else
		LIBHSM_INCLUDES="$LIBHSM_INCLUDE -I$ac_sub_srcdir/../../libhsm/src"
		LIBHSM_LIBS="$LIBHSM_LIBS -L../../libhsm/src/.libs"
		BUILD_LIBHSM="../../libhsm/src/.libs/libhsm.la"
	fi

	CPPFLAGS=$tmp_CPPFLAGS
	LIBS=$tmp_LIBS

	AC_SUBST(BUILD_LIBHSM)
	AC_SUBST(LIBHSM_INCLUDES)
	AC_SUBST(LIBHSM_LIBS)
])
# $Id: acx_libksm.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_LIBKSM],[
	AC_ARG_WITH(libksm, 
        	AC_HELP_STRING([--with-libksm=PATH],[Specify prefix of path of libksm]),
        	[
			LIBKSM_PATH="$withval"
		],[
			LIBKSM_PATH="/usr/local"
		])

	AC_MSG_CHECKING(what are the libksm includes)
	LIBKSM_INCLUDES="-I$LIBKSM_PATH/include"
	AC_MSG_RESULT($LIBKSM_INCLUDES)

	AC_MSG_CHECKING(what are the libksm libs)
	LIBKSM_LIBS="-L$LIBKSM_PATH/lib -lksm"
	AC_MSG_RESULT($LIBKSM_INCLUDES)

	tmp_CPPFLAGS=$CPPFLAGS
	tmp_LIBS=$LIBS

	CPPFLAGS="$CPPFLAGS $LIBKSM_INCLUDES"
	LIBS="$LIBS $LIBKSM_LIBS"

        ACX_ABS_SRCDIR # defines ac_sub_srcdir as an absolute path
        
	# dnl ok we don't have an installed library, use the source
	# (makefile will figure it out)
	if test ! -f $ac_sub_srcdir/../../libksm/src/include/ksm/ksm.h; then
		if test ! -f $ac_sub_srcdir/../libksm/src/include/ksm/ksm.h; then
			AC_CHECK_HEADERS(ksm/ksm.h, [
				AC_CHECK_LIB(ksm,KsmPolicyPopulateSMFromIds,, [
					AC_MSG_ERROR([libksm not found on system, and libksm source not present, use --with-libksm=path.])
				])
			], [
				AC_MSG_ERROR([libksm not found on system, and libksm source not present, use --with-libksm=path.])
			])
		else
			LIBKSM_INCLUDES="$LIBKSM_INCLUDE -I$ac_sub_srcdir/../libksm/src/include -I../../libksm/src/include"
			LIBKSM_LIBS="$LIBKSM_LIBS -L../../libksm/src/.libs"
			BUILD_LIBKSM="../../libksm/src/libksm.la"
		fi
	else
		LIBKSM_INCLUDES="$LIBKSM_INCLUDE -I$ac_sub_srcdir/../../libksm/src/include -I../../libksm/src/include"
		LIBKSM_LIBS="$LIBKSM_LIBS -L../../../libksm/src/.libs"
		BUILD_LIBKSM="../../libksm/src/libksm.la"
	fi


	CPPFLAGS=$tmp_CPPFLAGS
	LIBS=$tmp_LIBS

	AC_SUBST(BUILD_LIBKSM)
	AC_SUBST(LIBKSM_INCLUDES)
	AC_SUBST(LIBKSM_LIBS)
])
# $Id: acx_libxml2.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_LIBXML2],[
	AC_ARG_WITH(libxml2,
		[AS_HELP_STRING([--with-libxml2=DIR],[look for libxml2 in this dir])],
        	[
			XML2_PATH="$withval"
			AC_PATH_PROGS(XML2_CONFIG, xml2-config, xml2-config, $XML2_PATH/bin)
		],[
			XML2_PATH="/usr/local"
			AC_PATH_PROGS(XML2_CONFIG, xml2-config, xml2-config, $PATH)
		])
	if test -x "$XML2_CONFIG"
	then
		AC_MSG_CHECKING(what are the xml2 includes)
		XML2_INCLUDES="`$XML2_CONFIG --cflags`"
		AC_MSG_RESULT($XML2_INCLUDES)

		AC_MSG_CHECKING(what are the xml2 libs)
		XML2_LIBS="`$XML2_CONFIG --libs`"
		AC_MSG_RESULT($XML2_LIBS)

		tmp_CPPFLAGS=$CPPFLAGS
		tmp_LIBS=$LIBS

		CPPFLAGS="$CPPFLAGS $XML2_INCLUDES"
		LIBS="$LIBS $XML2_LIBS"

		AC_CHECK_LIB(xml2, xmlDocGetRootElement,,[AC_MSG_ERROR([Can't find libxml2 library])])
		
		CPPFLAGS=$tmp_CPPFLAGS
		LIBS=$tmp_LIBS
	else
		AC_MSG_ERROR([libxml2 required, but not found.])
	fi

	AC_SUBST(XML2_INCLUDES)
	AC_SUBST(XML2_LIBS)
])
# $Id: acx_mysql.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_MYSQL],[
	AC_ARG_WITH(mysql,
        	AC_HELP_STRING([--with-mysql=DIR],[Specify prefix of path of MySQL]),
		[
			MYSQL_PATH="$withval"
			AC_PATH_PROGS(MYSQL_CONFIG, mysql_config, mysql_config, $MYSQL_PATH/bin)
			AC_PATH_PROG(MYSQL, mysql, ,$MYSQL_PATH/bin)
		],[
			MYSQL_PATH="/usr/local"
			AC_PATH_PROGS(MYSQL_CONFIG, mysql_config, mysql_config, $PATH)
			AC_PATH_PROG(MYSQL, mysql)
		])
	if test -z "$MYSQL"; then
		AC_MSG_ERROR([mysql not found])
	fi
	if test -x "$MYSQL_CONFIG"
	then
		AC_MSG_CHECKING(mysql version)
		MYSQL_VERSION="`$MYSQL_CONFIG --version`"
		AC_MSG_RESULT($MYSQL_VERSION)
		if test ${MYSQL_VERSION//.*/} -le 4 ; then
			AC_MSG_ERROR([mysql must be newer than 5.0.0])
		fi

		AC_MSG_CHECKING(what are the MySQL includes)
		MYSQL_INCLUDES="`$MYSQL_CONFIG --include` -DBIG_JOINS=1 -DUSE_MYSQL"
		AC_MSG_RESULT($MYSQL_INCLUDES)

		AC_MSG_CHECKING(what are the MySQL libs)
		MYSQL_LIBS="`$MYSQL_CONFIG --libs_r`"
		AC_MSG_RESULT($MYSQL_LIBS)
  	fi

	AC_SUBST(MYSQL_INCLUDES)
	AC_SUBST(MYSQL_LIBS)
])
# $Id: acx_pedantic.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_PEDANTIC],[
	AC_ARG_ENABLE(
		[pedantic],
		[AS_HELP_STRING([--enable-pedantic],[enable pedantic compile mode @<:@enabled@:>@])],
		,
		[enable_pedantic="yes"]
	)
	if test "${enable_pedantic}" = "yes"; then
		enable_strict="yes";
		CFLAGS="${CFLAGS} -pedantic"
	fi
])
# $Id: acx_pkcs11_modules.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_PKCS11_MODULES],[
	AC_ARG_WITH(pkcs11-softhsm, 
		AC_HELP_STRING([--with-pkcs11-softhsm=PATH],[specify path of SoftHSM library to use for regression testing (default PREFIX/lib/libsofthsm.so)]),
		[ pkcs11_softhsm_module="$withval" ],
		[ pkcs11_softhsm_module="$prefix/lib/libsofthsm.so" ]
	)
	
	AC_ARG_WITH(pkcs11-sca6000, 
		AC_HELP_STRING([--with-pkcs11-sca6000=PATH],[specify path of SCA6000 library to use for regression testing (default /usr/lib/libpkcs11.so)]),
		[ pkcs11_sca6000_module="$withval" ],
		[ pkcs11_sca6000_module="/usr/lib/libpkcs11.so" ]
	)
	
	AC_ARG_WITH(pkcs11-etoken, 
		AC_HELP_STRING([--with-pkcs11-etoken=PATH],[specify path of Aladdin eToken library to use for regression testing (default /usr/local/lib/libeTPkcs11.so)]),
		[ pkcs11_etoken_module="$withval" ],
		[ pkcs11_etoken_module="/usr/local/lib/libeTPkcs11.so" ]
	)
	
	AC_ARG_WITH(pkcs11-opensc, 
		AC_HELP_STRING([--with-pkcs11-opensc=PATH],[specify path of Aladdin eToken library to use for regression testing (default /usr/lib/pkcs11/opensc-pkcs11.so)]),
		[ pkcs11_opensc_module="$withval" ],
		[ pkcs11_opensc_module="/usr/lib/pkcs11/opensc-pkcs11.so" ]
	)
	
	AC_SUBST(pkcs11_softhsm_module)
	AC_SUBST(pkcs11_sca6000_module)
	AC_SUBST(pkcs11_etoken_module)
	AC_SUBST(pkcs11_opensc_module)
])
# $Id: acx_rpath.m4 1411 2009-07-30 07:37:36Z jakob $

dnl Add option to disable the evil rpath. Check whether to use rpath or not.
dnl Adds the --disable-rpath option. Uses trick to edit the ./libtool.
AC_DEFUN([ACX_ARG_RPATH],
[
	AC_ARG_ENABLE(rpath,
		[AS_HELP_STRING([--disable-rpath],
			[disable hardcoded rpath (default=enabled)])],
		[enable_rpath=$enableval],
		[enable_rpath=yes])

	if test "x$enable_rpath" = xno; then
		AC_MSG_RESULT([Fixing libtool for -rpath problems.])
		sed < libtool > libtool-2 \
		's/^hardcode_libdir_flag_spec.*$'/'hardcode_libdir_flag_spec=" -D__LIBTOOL_RPATH_SED__ "/'
		mv libtool-2 libtool
		chmod 755 libtool
		libtool="./libtool"
	fi
])

dnl Add a -R to the RUNTIME_PATH.  Only if rpath is enabled and it is
dnl an absolute path.
dnl $1: the pathname to add.
AC_DEFUN([ACX_RUNTIME_PATH_ADD], [
	if test "x$enable_rpath" = xyes; then
		if echo "$1" | grep "^/" >/dev/null; then
			RUNTIME_PATH="$RUNTIME_PATH -R$1"
		fi
	fi
])
# $Id: acx_sqlite3.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_SQLITE3],[
	AC_ARG_WITH(sqlite3,
        	AC_HELP_STRING([--with-sqlite3=PATH],[Specify prefix of path of SQLite3]),
		[
			SQLITE3_PATH="$withval"
			AC_PATH_PROG(SQLITE3, sqlite3, $withval/bin)
		],[
			SQLITE3_PATH="/usr/local"
			AC_PATH_PROG(SQLITE3, sqlite3, $PATH)
		])
	
	AC_MSG_CHECKING(what are the SQLite3 includes)
	SQLITE3_INCLUDES="-I$SQLITE3_PATH/include"
	AC_MSG_RESULT($SQLITE3_INCLUDES)

	AC_MSG_CHECKING(what are the SQLite3 libs)
	SQLITE3_LIBS="-L$SQLITE3_PATH/lib -lsqlite3"
	AC_MSG_RESULT($SQLITE3_LIBS)

	tmp_CPPFLAGS=$CPPFLAGS
	tmp_LIBS=$LIBS

	CPPFLAGS="$CPPFLAGS $SQLITE3_INCLUDES"
	LIBS="$LIBS $SQLITE3_LIBS"

	AC_CHECK_HEADERS(sqlite3.h,,[AC_MSG_ERROR([Can't find SQLite3 headers])])
	AC_CHECK_LIB(sqlite3, sqlite3_prepare_v2, [], [AC_MSG_ERROR([Missing SQLite3 library v3.4.2 or greater])])

	CPPFLAGS=$tmp_CPPFLAGS
	LIBS=$tmp_LIBS

	AC_SUBST(SQLITE3_INCLUDES)
	AC_SUBST(SQLITE3_LIBS)
])
# $Id: acx_strict.m4 1411 2009-07-30 07:37:36Z jakob $

AC_DEFUN([ACX_STRICT],[
	AC_ARG_ENABLE(
		[strict],
		[AS_HELP_STRING([--enable-strict],[enable strict compile mode @<:@enabled@:>@])],
		,
		[enable_strict="yes"]
	)
	if test "${enable_strict}" = "yes"; then
		CFLAGS="${CFLAGS} -Wall -Wextra"
	fi
])
# $Id: acx_trang.m4 1414 2009-07-30 08:05:50Z jakob $

AC_DEFUN([ACX_TRANG],[
	AC_ARG_WITH(trang,
		[AS_HELP_STRING([--with-trang],[Path to trang(.jar) (optional)])],
		TRANG="$withval"
	)

	if test "x$TRANG" != "x"; then
		if test -x $TRANG; then
			AC_MSG_NOTICE(trang will run like this $TRANG)
		elif test -e $TRANG; then
			# TRANG exists, let's assume it's a jar-file
			TRANG="$JAVA -jar $TRANG"
			AC_MSG_NOTICE(trang will run like this $TRANG)
		fi
	else
		AC_PATH_PROG(TRANG, trang)
	fi

	if test "x$TRANG" = "x"; then
		AC_MSG_NOTICE([trang.jar can be downloaded from http://code.google.com/p/jing-trang/])
	    	AC_MSG_ERROR(trang is needed to continue - say where it is with --with-trang=PATH)
	fi

	AC_SUBST(TRANG)
])
# $Id: am_path_ruby.m4 1411 2009-07-30 07:37:36Z jakob $
#
# AM_PATH_RUBY([MINIMUM-VERSION], [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------------------
# Adds support for distributing Ruby modules and packages.  To
# install modules, copy them to $(rubydir), using the ruby_RUBY 
# automake variable.  To install a package with the same name as the
# automake package, install to $(pkgrubydir), or use the
# pkgruby_RUBY automake variable.
#
# The variables $(rbexecdir) and $(pkgrbexecdir) are provided as
# locations to install ruby extension modules (shared libraries).
# Another macro is required to find the appropriate flags to compile
# extension modules.
#
AC_DEFUN([AM_PATH_RUBY],
 [
  dnl Find a Ruby interpreter.
  m4_define_default([_AM_RUBY_INTERPRETER_LIST],
                    [ruby ruby1.8 ruby1.7 ruby1.6])

  m4_if([$1],[],[
    dnl No version check is needed.
    # Find any Ruby interpreter.
    if test -z "$RUBY"; then
      AC_PATH_PROGS([RUBY], _AM_RUBY_INTERPRETER_LIST, :)
    fi
    am_display_RUBY=ruby
  ], [
    dnl A version check is needed.
    if test -n "$RUBY"; then
      # If the user set $RUBY, use it and don't search something else.
      #AC_MSG_CHECKING([whether $RUBY version >= $1])
      #AM_RUBY_CHECK_VERSION([$RUBY], [$1],
      #                        [AC_MSG_RESULT(yes)],
      #                        [AC_MSG_ERROR(too old)])
      am_display_RUBY=$RUBY
    else
      # Otherwise, try each interpreter until we find one that satisfies
      # VERSION.
      AC_CACHE_CHECK([for a Ruby interpreter with version >= $1],
        [am_cv_pathless_RUBY],[
        for am_cv_pathless_RUBY in _AM_RUBY_INTERPRETER_LIST none; do
          test "$am_cv_pathless_RUBY" = none && break
          #AM_RUBY_CHECK_VERSION([$am_cv_pathless_RUBY], [$1], [break])
          [], [$1], [break])
        done])
      # Set $RUBY to the absolute path of $am_cv_pathless_RUBY.
      if test "$am_cv_pathless_RUBY" = none; then
        RUBY=:
      else
        AC_PATH_PROG([RUBY], [$am_cv_pathless_RUBY])
      fi
      am_display_RUBY=$am_cv_pathless_RUBY
    fi
  ])

  if test "$RUBY" = :; then
  dnl Run any user-specified action, or abort.
    m4_default([$3], [AC_MSG_ERROR([no suitable Ruby interpreter found])])
  else

  dnl Query Ruby for its version number.  Getting [:3] seems to be
  dnl the best way to do this; it's what "site.py" does in the standard
  dnl library.

  AC_CACHE_CHECK([for $am_display_RUBY version], [am_cv_ruby_version],
    [am_cv_ruby_version=`$RUBY -e "print RUBY_VERSION"`])
  AC_SUBST([RUBY_VERSION], [$am_cv_ruby_version])

  dnl Use the values of $prefix and $exec_prefix for the corresponding
  dnl values of RUBY_PREFIX and RUBY_EXEC_PREFIX.  These are made
  dnl distinct variables so they can be overridden if need be.  However,
  dnl general consensus is that you shouldn't need this ability.

  AC_SUBST([RUBY_PREFIX], ['${prefix}'])
  AC_SUBST([RUBY_EXEC_PREFIX], ['${exec_prefix}'])

  dnl At times (like when building shared libraries) you may want
  dnl to know which OS platform Ruby thinks this is.

  AC_CACHE_CHECK([for $am_display_RUBY platform], [am_cv_ruby_platform],
    [am_cv_ruby_platform=`$RUBY -e "print RUBY_PLATFORM"`])
  AC_SUBST([RUBY_PLATFORM], [$am_cv_ruby_platform])


  dnl Set up 4 directories:
  dnl rubydir -- where to install ruby scripts.  
  AC_CACHE_CHECK([for $am_display_RUBY script directory],
    [am_cv_ruby_rubydir],
    [am_cv_ruby_rubydir=`$RUBY -rrbconfig -e "drive = File::PATH_SEPARATOR == ';' ? /\A\w:/ : /\A/; prefix = Regexp.new('\\A' + Regexp.quote(Config::CONFIG[['prefix']])); \\$prefix = Config::CONFIG[['prefix']].sub(drive, ''); \\$archdir = Config::CONFIG[['archdir']].sub(prefix, '\\$(prefix)').sub(drive, ''); print \\$archdir;"`])
  AC_SUBST([rubydir], [$am_cv_ruby_rubydir])

  dnl pkgrubydir -- $PACKAGE directory under rubydir.  
  AC_SUBST([pkgrubydir], [\${rubydir}/$PACKAGE])

  dnl rbexecdir -- directory for installing ruby extension modules
  dnl   (shared libraries)
  AC_CACHE_CHECK([for $am_display_RUBY extension module directory],
    [am_cv_ruby_rbexecdir],
    [am_cv_ruby_rbexecdir=`$RUBY -rrbconfig -e "drive = File::PATH_SEPARATOR == ';' ? /\A\w:/ : /\A/; prefix = Regexp.new('\\A' + Regexp.quote(Config::CONFIG[['prefix']])); \\$prefix = Config::CONFIG[['prefix']].sub(drive, ''); \\$sitearchdir = Config::CONFIG[['sitearchdir']].sub(prefix, '\\$(prefix)').sub(drive, ''); print \\$sitearchdir;" 2>/dev/null || echo "${RUBY_EXEC_PREFIX}/local/lib/site_ruby/${RUBY_VERSION}/${RUBY_PLATFORM}"`])
  AC_SUBST([rbexecdir], [$am_cv_ruby_rbexecdir])

  RUBY_INCLUDES=`$RUBY -r rbconfig -e 'print " -I" + Config::CONFIG[["archdir"]]'`
  AC_SUBST([RUBY_INCLUDES])

  dnl pkgrbexecdir -- $(rbexecdir)/$(PACKAGE)

  AC_SUBST([pkgrbexecdir], [\${rbexecdir}/$PACKAGE])

  dnl Run any user-specified action.
  $2
  fi

])
# $Id: check_compiler_flag.m4 1411 2009-07-30 07:37:36Z jakob $

# routine to help check for compiler flags.
AC_DEFUN([CHECK_COMPILER_FLAG],[
	AC_REQUIRE([AC_PROG_CC])
	AC_MSG_CHECKING(whether $CC supports -$1)
	cache=`echo $1 | sed 'y% .=/+-%____p_%'`
	AC_CACHE_VAL(cv_prog_cc_flag_$cache,
	[
		echo 'void f(){}' >conftest.c
		if test -z "`$CC -$1 -c conftest.c 2>&1`"; then
			eval "cv_prog_cc_flag_$cache=yes"
		else
			eval "cv_prog_cc_flag_$cache=no"
		fi
		rm -f conftest*
	])
	if eval "test \"`echo '$cv_prog_cc_flag_'$cache`\" = yes"; then
		AC_MSG_RESULT(yes)
		:
		$2
	else
		AC_MSG_RESULT(no)
		:
		$3
	fi
])
# $Id: check_compiler_flag_needed.m4 1411 2009-07-30 07:37:36Z jakob $

# if the given code compiles without the flag, execute argument 4
# if the given code only compiles with the flag, execute argument 3
# otherwise fail
AC_DEFUN([CHECK_COMPILER_FLAG_NEEDED],[
	AC_REQUIRE([AC_PROG_CC])
	AC_MSG_CHECKING(whether we need $1 as a flag for $CC)
	cache=`echo $1 | sed 'y% .=/+-%____p_%'`
	AC_CACHE_VAL(cv_prog_cc_flag_needed_$cache,
	[
		echo '$2' > conftest.c
		echo 'void f(){}' >>conftest.c
		if test -z "`$CC $CFLAGS -Werror -Wall -c conftest.c 2>&1`"; then
			eval "cv_prog_cc_flag_needed_$cache=no"
		else
		[
			if test -z "`$CC $CFLAGS $1 -Werror -Wall -c conftest.c 2>&1`"; then
				eval "cv_prog_cc_flag_needed_$cache=yes"
			else
				echo 'Test with flag fails too'
			fi
		]
		fi
		rm -f conftest*
	])
	if eval "test \"`echo '$cv_prog_cc_flag_needed_'$cache`\" = yes"; then
		AC_MSG_RESULT(yes)
		:
		$3
	else
		AC_MSG_RESULT(no)
		:
		$4
	fi
])
