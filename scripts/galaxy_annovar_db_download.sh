#!/bin/bash
echo "# Make Sure you run this script as Galaxy Application User"


# Check paths-
if [ -z "$galaxy_dir" ]; then
 echo "! Unable to find galaxy_dir"
 read -p "# Enter Galaxy Installation Path: " galaxy_dir
else
 echo "galaxy_dir found:- \"$galaxy_dir\""
fi

tooldpath="$galaxy_dir/tool-data"
local_data_table="$galaxy_dir/config/tool_data_table_conf.xml"
annovar_path="$galaxy_dir/apps/annovar"

if [ -f $annovar_path/annotate_variation.pl ]; then
 echo "# Annovar Script Found:- $annovar_path/annotate_variation.pl" ; else
 echo" ! Unable to find the file $annovar_path/annotate_variation.pl"
 read -p "# Enter path where Annovar is installed, : " annovar_path
fi

# Data directory path
read -p "# Enter data directory path, Defaults to /tools/galaxy/data/annovar: " datapath
datapath=${datapath:-"/tools/galaxy/data/annovar"}
mkdir -p $datapath

# CSV file path
read -p "# Enter full file path of csv database list : " dbcsv
if [ ! -f "$dbcsv" ]; then echo "Unable to find the CSV file." ;exit ;fi

# cleanup loc file
echo "# Backing up old annovar_index.loc"
cp $tooldpath/annovar_index.loc $tooldpath/annovar_index.loc_`date +\%d\%m\%y\%H\%M`.bak
cp $tooldpath/annovar_index.loc.sample $tooldpath/annovar_index.loc

#for i in `grep -v "#" $dbcsv`
grep -v "#" $dbcsv | while read -r i
do
  echo "Processiing $i"
  dbkey="`echo $i | cut -d, -f1`"
  dbvalue="`echo $i | cut -d, -f2`"
  dbtype="`echo $i | cut -d, -f3`"
  dboption="`echo $i | cut -d, -f4`"
  echo "key: $dbkey, value: $dbvalue, type: $dbtype, Options: $dboption"
  mkdir -p $datapath/$dbkey/$dbvalue
  $annovar_path/annotate_variation.pl -downdb -buildver $dbkey $dbvalue $dboption $datapath/$dbkey/$dbvalue/
  echo "#" >> $tooldpath/annovar_index.loc
  echo "$dbvalue        $dbkey  $dbtype $datapath/$dbkey/$dbvalue/" >> $tooldpath/annovar_index.loc
  unset dbkey dbvalue dbtype
done

# Update tool_data_table_conf.xml
sed -i '/\/\<tables\>/d' $local_data_table
  if [ -z "`grep  $local_data_table`" ]; then
  echo '  
     <!-- Location of ANNOVAR databases -->"\
     <table comment_char="#" name="annovar_indexes">\
        <columns>value, dbkey, type, path</columns>\
        <file path="tool-data/annovar_indexes.loc"> </file>\
     </table>' >> $local_data_table
  fi
echo "</tables>" >> $local_data_table
