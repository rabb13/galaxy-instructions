#!/bin/bash
#-------------------------------
# Make sure variable here is correct before running this script
# URL for the bx package
pkgurl="https://github.com/rabb13/galaxy-instructions/raw/master/tools/package_freetype_2_5_2_devteam_a65217367e4a.tgz"

# Galaxy installation directory
galaxy_dir="/srv/galaxyproject/galaxy"

# Galaxy user
galaxy_user=galaxy

#Galaxy database name
galaxy_db=galaxydb

#-----------------------------------
tool_name="package_freetype_2_5_2"
toolpath="database/dependencies/freetype/2.5.2/devteam/package_freetype_2_5_2/a65217367e4a"
#-----------------------------------

echo "Installing package_freetype_2_5_2 by devteam Revision a65217367e4a:
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
