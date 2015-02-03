README Notes for backupVM.sh

1.	Copy backupVM.sh to /usr/local/bin
2.	Copy com.justinrummel.vmware.backup.plist to /Library/LaunchAgents and be sure to set the permissions to 644 root:wheel
3.	REVIEW Scripts before you run them!  Such as update the destination server in backupVM.sh (the default wont work)
4.	Be sure to read the requiremetns of backupVM.sh

	This script is best used after you have established SSH keys between your client and destination server.

	See the SSH-keygen-copy.sh script in our GIT repo
