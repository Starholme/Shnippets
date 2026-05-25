#!/bin/bash

Remove one line from history: history -d 123; history -d 122;
SFTP put: sftp -P someport someuser@someserver <<< $'put {filename}'
SFTP get: sftp -P someport someuser@someserver:{remoteFileName} {localFileName}