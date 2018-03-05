#!/bin/bash

# This script will download the locfiles from rmeote and place it in default tool-data direcotry
# This will also prmt you to update the paths for default data drectory.
#========================================================#
# updae the list of files below to be downloaded from rsync server


loclist="\
alignseq.loc
all_fasta.loc
bowtie_indices.loc
bowtie2_indices.loc
bowtie_indices_color.loc
bwa_index.loc
bwa_index_color.loc
bwa_mem_index.loc
codingSnps.loc
funDo.loc
gatk_sorted_picard_index.loc
picard_index.loc
liftOver.loc
sam_fa_indices.loc
sequence_index_base.loc
sift_db.loc
tmap_index.loc"

shedloclist="fasta_indexes.loc"

#========================================================#
#echo "Press return to use default values"

# Check paths-
if [ -z "$galaxy_dir" ]; then
 echo "Unable to find galaxy_dir"
 read -p " Enter Galaxy Installation Path: " galaxy_dir
else
 echo "galaxy_dir found:- \"$galaxy_dir\""
fi
tooldpath="$galaxy_dir/tool-data"
local_data_table="$galaxy_dir/config/tool_data_table_conf.xml"

if [ -f $local_data_table ]; then
 echo "Local Data Table Found- $local_data_table" ; else
 echo" Unable to find the file $local_data_table"
fi

# Reference Data Directory
read -p "# Do you want to update data dirctory paths inside .loc files? y/N | " dirupdate
if [ "`echo $dirupdate`" == "y" ] ;
then
  read -p "# Data directory path,(replaces /glaxy/data), Default to /tools/galaxy/data : " datapath
  datapath=${datapath:-"/tools/galaxy/data"}
else
  echo "Skipping path update"
fi


# Removed end of tables
sed -i '/\/\<tables\>/d' $local_data_table

for i in $loclist
do
  echo "Updating $i"
  rsync -avhP "rsync://datacache.g2.bx.psu.edu/location/$i" $tooldpath/
  if [ "`echo $dirupdate`" == "y" ] ; then
  sed -i "s~/galaxy/data~$datapath~g" $tooldpath/$i
fi
  if [ -z "`grep $i $local_data_table`" ]; then
  x=`echo "$i"| cut -d. -f1`
  echo '
     <!-- Location of '"$i"' databases -->"\
     <table comment_char="#" name="'"$x"'">\
        <columns>value, dbkey, type, path</columns>\
        <file path="tool-data/'"$i"'"> </file>\
     </table>' >> $local_data_table
  fi
done

# re-add end of tables
echo "</tables>" >> $local_data_table
