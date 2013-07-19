#!/bin/bash

# Sanity check
[[ $BACKUP_TYPE =~ (Full|Incremental) ]] || { echo "Unknown BACKUP_TYPE"; exit 1; }
[ -n "${BACKUP_TEMPDIR:+x}" ] || { echo "BACKUP_TEMPDIR is not defined"; exit 1; }
[ -n "${BACKUP_PATH:+x}" ] || { echo "BACKUP_PATH is not defined"; exit 1; }
[ -n "${BACKUP_GLACIER_CONFIG:+x}" ] || { echo "BACKUP_GLACIER_CONFIG is not defined"; exit 1; }
[ -n "${BACKUP_GLACIER_VAULT:+x}" ] || { echo "BACKUP_GLACIER_VAULT is not defined"; exit 1; }

set -e

date=$(date +%F)
timestamp=$(date +%s)
hostn=$(hostname -f)
clearpath=`echo $BACKUP_PATH | sed s@/@-@g`
mkdir -p $BACKUP_TEMPDIR/$date
cd $BACKUP_TEMPDIR/$date
[ "$BACKUP_TYPE" == "Full" ] && rm -f $BACKUP_TEMPDIR/backup-inc-file.list

ionice -n 7 tar czf backup.tar.gz $BACKUP_PATH --listed-incremental=$BACKUP_TEMPDIR/backup-inc-file.list >> $BACKUP_TEMPDIR/glacier_static.log 2>&1
/usr/local/bin/glacier-cmd -c $BACKUP_GLACIER_CONFIG upload $BACKUP_GLACIER_VAULT backup.tar.gz >> $BACKUP_TEMPDIR/glacier_static.log 2>&1
rm -f $BACKUP_TEMPDIR/$date/*
