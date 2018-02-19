import boto
import datetime
import dateutil
from dateutil import parser
from boto import ec2
from boto.ec2.connection import EC2Connection
from boto.ec2.regioninfo import RegionInfo
import os
import time
import sys
import re
from config import config

# keys
aws_access_key = config['aws_access_key']
aws_secret_key = config['aws_secret_key']
ec2_region_name = config['ec2_region_name']
ec2_region_endpoint = config['ec2_region_endpoint']

# volume ids and days
prod_vol_id = config['prod_vol_id']
prod_days_del = config['prod_days_old']

# tags for creation of snapshot
prod_tag_value = config['tag_value']

# creating connection
region = RegionInfo(name=ec2_region_name, endpoint=ec2_region_endpoint)
connection = EC2Connection(aws_access_key,aws_secret_key,region=region)

# function for deletion of snapshots
def snapshot_delete (vol_id, del_days):
    timeLimit = datetime.datetime.now() - datetime.timedelta(days = int(del_days))
    prodAllSnapshots=connection.get_all_snapshots(owner='self')
    for snapshot in prodAllSnapshots:
      if 'Name' in snapshot.tags:
        if re.search(prod_tag_value,snapshot.tags['Name']):
          print "Checking the deletion date for "+snapshot.tags['Name']
          if parser.parse(snapshot.start_time).date() <= timeLimit.date():
            print " Deleting Snapshot %s  %s "  %(snapshot.tags,snapshot.id)
            connection.delete_snapshot(snapshot.id)
        else:
          print "Not Deleted "+snapshot.tags['Name']


# function for creation of Snapshots
def snapshot_create (vol_id, tag_value):
    curr_datetime = datetime.datetime.now()
    curr_datetime.strftime("%Y-%m-%d-%H%MZ")
    curr_time = str(curr_datetime).replace(" ","_")
    c_time = str(curr_time).replace(":","")
    head, mid, tail = c_time.partition('.')
    value = tag_value+head
    snapshot = connection.create_snapshot(vol_id,description='prod_mongo_snapshot_used_volume-'+vol_id+'')
    snapshot.add_tags({'Name': value})
    print "Creating snapshot %s %s" %(snapshot.tags,snapshot.id)
    # checking for status
    while snapshot.status != 'completed':
        snapshot.update()
        time.sleep(5)
        if snapshot.status == 'completed':
            print snapshot.id + ' is complete.'
            break
    print "Snapshot completed at : %s" %(head)

# calling of function
create_snap = snapshot_create (prod_vol_id, prod_tag_value)
del_snap = snapshot_delete(prod_vol_id, prod_days_del)
