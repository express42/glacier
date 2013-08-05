#!/bin/bash

# Sanity check
[[ $BACKUP_TYPE =~ (Full|Incremental) ]] || { echo "Unknown BACKUP_TYPE"; exit 1; }
[ -n "${BACKUP_TEMPDIR:+x}" ] || { echo "BACKUP_TEMPDIR is not defined"; exit 1; }
[ -n "${BACKUP_PATH:+x}" ] || { echo "BACKUP_PATH is not defined"; exit 1; }
[ -n "${BACKUP_GLACIER_CONFIG:+x}" ] || { echo "BACKUP_GLACIER_CONFIG is not defined"; exit 1; }
[ -n "${BACKUP_GLACIER_VAULT:+x}" ] || { echo "BACKUP_GLACIER_VAULT is not defined"; exit 1; }

set -e

date=$(date +%F)
timestamp=$(date +"%Y-%m-%d_%H:%M")
hostn=$(hostname -f)
clearpath=`echo $BACKUP_PATH | sed s@/@-@g`
mkdir -p $BACKUP_TEMPDIR/$date
cd $BACKUP_TEMPDIR/$date
[ "$BACKUP_TYPE" == "Full" ] && rm -f $BACKUP_TEMPDIR/backup-inc-file.list

echo "Starting $BACKUP_TYPE backup at $timestamp" >> $BACKUP_TEMPDIR/glacier_static.log

ionice -n 7 tar cz $BACKUP_PATH --absolute-names --listed-incremental=$BACKUP_TEMPDIR/backup-inc-file.list | split -d -b 5368709120 - Backup_${hostn}_${clearpath}_${timestamp}_${BACKUP_TYPE}.tar.gz. >> $BACKUP_TEMPDIR/glacier_static.log 2>&1

for file in $BACKUP_TEMPDIR/$date/*; do
	(/usr/local/bin/glacier-cmd -c $BACKUP_GLACIER_CONFIG upload \
		--description "$file, backup at $date from $hostn, $timestamp" $BACKUP_GLACIER_VAULT $file >> $BACKUP_TEMPDIR/glacier_static.log 2>&1)&
done

# let's get inventory at end of backup
/usr/local/bin/glacier-cmd -c $BACKUP_GLACIER_CONFIG inventory $BACKUP_GLACIER_VAULT >> $BACKUP_TEMPDIR/glacier_static.log 2>&1

rm -f $BACKUP_TEMPDIR/$date/*
