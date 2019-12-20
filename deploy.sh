#!/bin/bash
project_name="notifi"
domain="notifi.it"
work_name="notifi"
project_type=".xcworkspace"

###################

dir="$(pwd)"
project_dir="${dir}/Documents/work/${work_name}/"
deployment_dir="${dir}/Documents/work/App Deployment/Deployer/"

#app
dev_team="3H49MXS325"
# `security find-identity -v -p codesigning` ->> "Mac Developer"
# can be recreated with xcode preferences > + > mac Developer
sign_key="884AC6AA0ADA77FE75BDAC50C771DA0A1E0779CF"

#dmg
dmg_project_output="${dir}/Documents/work/${domain}/public_html/${project_name}.dmg"

#server
scp_command="scp '"$dmg_project_output"' root@${domain}:/var/www/${domain}/public_html/"
sparkle_path="https://${domain}/version.php"

#run
cd "$deployment_dir"
bash deployer.sh "$project_name" "$project_type" "$project_dir" "$dev_team" "$dmg_project_output" "$scp_command" "$sparkle_path" "$sign_key"
