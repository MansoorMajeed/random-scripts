#!/usr/bin/python

# Do incremental backups of folders to dropbox
# include mysql database ( specify names in the conf file)

# store the script in '/root/backup_script/'
# replace 'your_dropbox_app_folder' with the name of the folder you created in the Dropbox app
import os
import ConfigParser
import datetime
import sys
from dropbox.client import DropboxClient
from time import strftime

token = 'your_access_token_here'
dbx = DropboxClient(token)

def get_line_count(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1

conf = ConfigParser.ConfigParser()
conf.read('/root/backup_script/python_incremental_dropbox.conf')
folders = conf.get('backup_folders','backup_folders')
temp_dir = conf.get('temp','temp_dir')
retention = conf.get('retention','retention')
databases = conf.get('databases','dbs')
databases = databases.split('\n')
folders = folders.split('\n')
location = " ".join(folders)
#current_time = str(datetime.datetime.now().strftime("%Y%d%H%M%S"))
current_time = strftime("%Y:%m:%d-%H:%M:%S")
# dump the dbs


os.system("mkdir -p /tmp/databases")
for db in databases:
    os.system("mysqldump %s > /tmp/databases/%s.sql" %(db, db))
    print "Dumping Database ", db

# Create archives to be sent to dropbox
location = location + " /tmp/databases/"

print "Creating the backup archive..!"
os.system("tar -czvf %s/%s.tar.gz %s"  % (temp_dir, current_time, location) )
print "Archive created successfully"
os.system("echo %s >> /root/backup_script/backup_history" %(current_time))

backup_file = "%s/%s.tar.gz" %(temp_dir, current_time)
destination = "%s.tar.gz" %(current_time)

print "The payload is:", backup_file
print "The destination is gonna be: ", destination
print "Sending files to dropbox"
f = open(backup_file, 'rb')
response = dbx.put_file('/your_dropbox_app_folder/' + destination, f)

print "Response: ", response
# Retention
head = ''
total_backups = get_line_count('/root/backup_script/backup_history')
print "Checking retention"
print "There are %s backups | retention is %s" %(total_backups, retention)
diff = int(total_backups) - int(retention)
if diff > 0 :
    # Delete diff number of folders from the top of the file backup_history
    print "There are files to be deleted in the destination"
    with open("/root/backup_script/backup_history") as f:
        head = [next(f) for x in xrange(diff)]

# delete everything in head
if head:
	for folder in head:
	    os.system("sed -i '1d' /root/backup_script/backup_history")
	    print "Deleting ", folder
	    folder = folder.rstrip('\n')
	    dbx.file_delete('/your_dropbox_app_folder' + folder + '.tar.gz')
	    print "Deleted successfully"

#cleaning up
print "Cleaning up.."
os.system('rm -rf /tmp/databases/*')
os.system("rm -f %s" %(backup_file))
print "All done"
