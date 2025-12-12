-Hardecoded project id on the name for the storage bucket, modify it on the backupscript.sh which uploads the backup script. Make sure you put the bucket name that was created for the new project.

-Also edit the gcp Yaml with new project ID.

-Run the the first terraform apply without having a project varieble on terraform.tfvars
