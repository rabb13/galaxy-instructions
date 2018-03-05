#!/bin/bash
#-------------------------------
# Make sure variable here is correct before running this script
# URL for the bx package
pkgurl="https://files.gel.zone/galaxy/tools/package_fontconfig_2_11_1_devteam_1e47d82c2c3d.tgz"

# Galaxy installation directory
galaxy_dir="/srv/galaxyproject/galaxy"

# Galaxy user
galaxy_user=galaxy

#Galaxy database name
galaxy_db=galaxydb

#-----------------------------------
tool_name="package_fontconfig_2_11_1"
toolpath="database/dependencies/fontconfig/2.11.1/devteam/package_fontconfig_2_11_1/1e47d82c2c3d"
#-----------------------------------

echo "Installing package_fontconfig_2_11_1 by devteam Revision 1e47d82c2c3d:
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
