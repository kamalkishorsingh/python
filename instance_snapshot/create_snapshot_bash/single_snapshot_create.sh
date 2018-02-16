#!/bin/bash

# Original was modified to do backup only for one specified volume. 

set -ue
set -o pipefail

export PATH=$PATH:/usr/local/bin/:/usr/bin

## START SCRIPT

# Set Variables
volume_id="********"
today=`date +"%m-%d-%Y"+"%T"`
logfile="/var/log/ebs-snapshot.log"

# How many days do you wish to retain backups for? Default: 7 days
retention_days="7"
retention_date_in_seconds=`date +%s --date "$retention_days days ago"`

log_info() {
  echo "$@" >> $logfile
}

# Start log file: today's date
log_info $today

# Take a snapshot of the volume
description="mongo_snapshot_used_volumeID_${volume_id}-backup-$(date +%Y-%m-%d)"
log_info "Volume ID is $volume_id"

# Next, we're going to take a snapshot of the current volume, and capture the resulting snapshot ID
snapresult=$(aws ec2 create-snapshot --profile snapshot --output=text --description $description --volume-id $volume_id --query SnapshotId)

log_info "New snapshot is $snapresult" 
 
# And then we're going to add a "CreatedBy:AutomatedBackup" tag to the resulting snapshot.
# Why? Because we only want to purge snapshots taken by the script later, and not delete snapshots manually taken.
#aws ec2 create-tags --profile snapshot --resource $snapresult --tags Key=CreatedBy,Value=AutomatedBackup
aws ec2 create-tags --profile snapshot --resource $snapresult --tags Key=Name,Value=prod_mongo_snapshot

# Get all snapshot IDs associated with each volume attached to this instance
rm /tmp/snapshot_info.txt --force

aws ec2 describe-snapshots --profile snapshot --output=text --filters "Name=volume-id,Values=$volume_id" "Name=tag:Name,Values=prod_mongo_snapshot" --query Snapshots[].SnapshotId | tr '\t' '\n' | sort | uniq >> /tmp/snapshot_info.txt 2>&1

# Purge all instance volume snapshots created by this script that are older than 7 days
for snapshot_id in $(cat /tmp/snapshot_info.txt)
do
    log_info "Checking $snapshot_id..."
	snapshot_date=$(aws ec2 describe-snapshots --profile snapshot --output=text --snapshot-ids $snapshot_id --query Snapshots[].StartTime | awk -F "T" '{printf "%s\n", $1}')
    snapshot_date_in_seconds=`date "--date=$snapshot_date" +%s`

    if (( $snapshot_date_in_seconds <= $retention_date_in_seconds )); then
        log_info "Deleting snapshot $snapshot_id ..."
        aws ec2 delete-snapshot --profile snapshot --snapshot-id $snapshot_id
    else
        log_info "Not deleting snapshot $snapshot_id ..."
    fi
done

# One last carriage-return in the logfile...
log_info ""

echo "Results logged to $logfile"
