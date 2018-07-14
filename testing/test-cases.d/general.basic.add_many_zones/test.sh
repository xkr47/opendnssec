#!/usr/bin/env bash
#
#TEST: Make sure no signatures are added to a zone in a passthrough
#policy. Also see that the SOA serial is bumped.

(
	set -e
	set -o pipefail

	tests=10

	if [ -n "$HAVE_MYSQL" ]; then
		ods_setup_conf conf.xml conf-mysql.xml
	fi

	ods_reset_env
	echo -n "LINE: ${LINENO} " ; ods_start_ods-control

	## add zone in passthrough policy
	for i in `seq 1 $tests` ; do
		echo -n "LINE: ${LINENO} " ; log_this `printf '%02d' $i`-zone_add ods-enforcer zone add -z example${i}.com
	done

	## wait for signed file to appear
	for i in `seq 1 $tests` ; do
	  echo -n "LINE: ${LINENO} " ; syslog_waitfor 10 'ods-signerd: .*\[STATS\] example'"${i}.com"
	  echo -n "LINE: ${LINENO} " ; test -f "$INSTALL_ROOT/var/opendnssec/signed/example${i}.com"
	done

	## test absence of signatures
	for i in `seq 1 $tests` ; do
	  echo -n "LINE: ${LINENO} " ; ! grep -q RRSIG "$INSTALL_ROOT/var/opendnssec/signed/example${i}.com"
	done

	## test serial bump
	for i in `seq 1 $tests` ; do
	  echo -n "LINE: ${LINENO} " ; SOA1=`grep SOA "$INSTALL_ROOT/var/opendnssec/unsigned/example${i}.com" | cut -f5 | cut -f3 -d" "`
	  echo -n "LINE: ${LINENO} " ; SOA2=`grep SOA "$INSTALL_ROOT/var/opendnssec/signed/example${i}.com" | cut -f5 | cut -f3 -d" "`
	  echo -n "LINE: ${LINENO} " ; test "$SOA1" -lt "$SOA2"
	done

	## ask for a resign
	for i in `seq 1 $tests` ; do
	  echo -n "LINE: ${LINENO} " ; touch "$INSTALL_ROOT/var/opendnssec/signed/example${i}.com"
	  echo -n "LINE: ${LINENO} " ; log_this 02-resign ods-signer sign example${i}.com
	  echo -n "LINE: ${LINENO} " ; syslog_waitfor_count 10 2 'ods-signerd: .*\[STATS\] '"example${i}.com"
	done

	## serial bumped again?
	for i in `seq 1 $tests` ; do
	  echo -n "LINE: ${LINENO} " ; SOA3=`grep SOA "$INSTALL_ROOT/var/opendnssec/signed/example${i}.com" | cut -f5 | cut -f3 -d" "`
	  echo -n "LINE: ${LINENO} " ; test $SOA2 -lt $SOA3
	done

	echo -n "LINE: ${LINENO} " ; ods_stop_ods-control

)
[ $? = 0 ] && return 0

echo
echo "************ERROR******************"
echo
ods_kill
return 1
