#!/bin/bash

project_name="notifi"
project_type=".xcworkspace"
project_path="/Users/maxmitch/Documents/notifi/Mac App/"
dev_team="3H49MXS325"
dmg_project_output="/Users/maxmitch/Documents/notifi/notifi.it/public_html/notifi.dmg"
scp_command="scp $dmg_project_output root@notifi.it:/var/www/notifi.it/public_html/"

~/deploy.sh "$project_name" "$project_type" "$project_path" "$dev_team" "$dmg_project_output" "$scp_command"
