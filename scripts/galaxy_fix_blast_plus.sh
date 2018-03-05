#!/bin/bash
#-------------------------------
# Make sure variable here is correct before running this script
# URL for the bx package
pkgurl="https://files.gel.zone/galaxy/tools/package_blast_plus_2_2_26_devteam_85e43fb3f363.tgz"

# Galaxy installation directory
galaxy_dir="/srv/galaxyproject/galaxy"

# Galaxy user
galaxy_user=galaxy

#Galaxy database name
galaxy_db=galaxydb

#-----------------------------------
tool_name="package_blast_plus_2_2_26"
toolpath="database/dependencies/blast+/2.2.26+/devteam/package_blast_plus_2_2_26/85e43fb3f363"
#-----------------------------------

echo "Installing package_blast+ 2_2_26 by devteam Revision 85e43fb3f363:
"

# check user
if [ "$USER" = "root" ]
then
 echo "Tool Source URL: $pkgurl"
 echo "Galaxy installation directory: $galaxy_dir"
 echo "Galaxy Galaxy User: $galaxy_user"
 echo "Galaxy database: $galaxy_db"
 echo "Assuming this script variables are correct"
else
 echo "# WARNING: I should running as root and check  variables are correct inside this script"
 exit
fi

# Remove current
rm -rf $galaxy_dir/$toolpath

# fetch and decompress
curl $pkgurl | tar xz -C "$galaxy_dir/database/dependencies/"
chown -R $galaxy_user "$galaxy_dir/database/dependencies/"

# fix paths
#sed -i "s~/galaxy/database/~$galaxy_dir/database/~g" $galaxy_dir/$toolpath/env.sh
find $galaxy_dir/$toolpath/ -type f -exec sed -i "s~/galaxy/database/~$galaxy_dir/database/~g" {} \;

# update postgres database
db_toolshed_id="`sudo -u postgres psql -t -d galaxydb << EOF
select id from tool_shed_repository
where name = '$tool_name';
EOF`"

sudo -u postgres psql -d galaxydb << EOF
update tool_dependency
set status = 'Installed', error_message = 'Manually Installed'
where tool_shed_repository_id = '$db_toolshed_id' and status = 'Error';
EOF
