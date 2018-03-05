#!/bin/bash
#-------------------------------#
# Make sure variable here is correct before running this script

# Galaxy installation directory, change if not configure in global envirnemnt
#galaxy_dir="/srv/galaxyproject/galaxy"

# Galaxy user
galaxy_user=galaxy

# Annovar version
annovar_version="2017Jul16"

# Annover install Directory
annovar_path="$galaxy_dir/apps/"

# Annovar source path/URL
annovar_source="annovar_2017Jul16.tgz"
#-----------------------------------#
if [ -z "$galaxy_dir" ]; then
 echo "! Unable to find galaxy_dir"
 read -p "# Enter Galaxy Installation Path: " galaxy_dir
else
 echo "galaxy_dir found:- \"$galaxy_dir\""
fi

echo "This script assumes You already have a copy of Annovar in current directory with valid license and all varibles are updated inside direcotry. Proceed? [ y/N ]:
"; read continue; if ! [ "$continue" = "y" ]; then exit; fi

# check user
if [ "$USER" = "root" ]||[ "$USER" = "$galaxy_user" ]
then
 echo "Assuming Path Variables are correct, Installing Annovar:"
else
 echo "# WARNING: I should running as root or $galaxy_user and Check variables are correct inside this script"
 exit
fi


# Copy Annovar tools
mkdir -p $annovar_path
tar zxf $annovar_source -C $annovar_path
if [ "$USER" = "root" ]; then chown -R $galaxy_user $annovar_path; fi

# Create Tool Directories and symlink and env.sh
mkdir -p $galaxy_dir/database/dependencies/annovar/$annovar_version/
cd $galaxy_dir/database/dependencies/annovar/; ln -sf $annovar_version/ default; cd - > /dev/null;
if [ "$USER" = "root" ]; then chown -R $galaxy_user $galaxy_dir/database/dependencies/annovar/; fi
echo "export PATH=/$annovar_path/annovar:$PATH" > $galaxy_dir/database/dependencies/annovar/default/env.sh

echo "done
"
