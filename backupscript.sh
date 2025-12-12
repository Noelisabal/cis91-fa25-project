#!/usr/bin/bash
cd /var/lib
sudo systemctl stop mysql
sudo tar -cf /tmp/db-backup.tar mysql/
sudo systemctl start mysql
gsutil cp /tmp/db-backup.tar gs://cis91fa25noel-backup-bucket
rm /tmp/db-backup.tar