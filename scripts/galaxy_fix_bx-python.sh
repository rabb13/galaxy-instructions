#!/bin/bash
#-------------------------------
# Make sure variable here is correct before running this script
# URL for the bx package
pkgurl="https://github.com/rabb13/galaxy-instructions/raw/master/tools/package_bx_py_devteam_0.7.1_devteam_2d0c08728bca.tgz"

# Galaxy installation directory
galaxy_dir="/srv/galaxyproject/galaxy"

# Galaxy user
galaxy_user=galaxy

#Galaxy database name
galaxy_db=galaxydb

#-----------------------------------
tool_name="package_bx_python_0_7"
toolpath="database/dependencies/bx-python/0.7.1/devteam/package_bx_python_0_7/2d0c08728bca"
#-----------------------------------

echo "Installing package_bx_python_0_7 by devteam Revision 2d0c08728bca:
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
#sed -i "s~/galaxy/database/~$galaxy_dir/database/~g" $galaxy_dir/$toolpath/env.sh
#sed -i "s~/galaxy/database/~$galaxy_dir/database/~g" $galaxy_dir/$toolpath/venv/bin/activate*


# update postgres database
db_toolshed_id="`sudo -u postgres psql -t -d galaxydb << EOF
select id from tool_shed_repository
where name = 'package_bx_python_0_7';
EOF`"

sudo -u postgres psql -d galaxydb << EOF
update tool_dependency
set status = 'Installed', error_message = 'Manually Installed'
where tool_shed_repository_id = '$db_toolshed_id' and status = 'Error';
EOF
