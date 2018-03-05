#!/bin/bash

# This script will download the locfiles from rmeote and place it in default tool-data direcotry
# This will also prmt you to update the paths for default data drectory.
#========================================================#
# updae the list of files below to be downloaded from rsync server

# loclist format:  filename.loc,column1,column2,colum3,column4,column5

loclist="\
alignseq.loc,value,dbkey,name,path
all_fasta.loc,value,dbkey,name,path
bowtie_indices.loc,value,dbkey,name,path
bowtie2_indices.loc,value,dbkey,name,path
bowtie_indices_color.loc,value,dbkey,name,path
bwa_index.loc,value,dbkey,name,path
bwa_index_color.loc,value,dbkey,name,path
bwa_mem_index.loc,value,dbkey,name,path
codingSnps.loc,value,path
funDo.loc,value,description,,path
gatk_sorted_picard_index.loc,value,dbkey,name,path
picard_index.loc,value,dbkey,name,path
liftOver.loc,value,dbkey,name,path
sam_fa_indices.loc,value,name,path
sequence_index_base.loc,value,path
sift_db.loc,value,path
tmap_index.loc,value,dbkey,name,path"

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
  locfile="`echo $i | cut -d, -f1`"
  column1="`echo $i | cut -d, -f2`"
  column2="`echo $i | cut -d, -f3`"
  column3="`echo $i | cut -d, -f4`"
  column4="`echo $i | cut -d, -f5`"
  x=`echo "$locfile"| cut -d. -f1`
  echo "Updating $x"
  rsync -avhP "rsync://datacache.g2.bx.psu.edu/location/$locfile" $tooldpath/
  if [ "`echo $dirupdate`" == "y" ] ; then
  sed -i "s~/galaxy/data~$datapath~g" $tooldpath/$locfile
fi
  if [ -z "`grep $locfile $local_data_table`" ]; then
  echo '  
    <!-- Location of '"$locfile"' items -->"\
    <table comment_char="#" name="'"$x"'">\
       <columns>'"$column1, $column2`if [ -n "$column3" ]; then echo ", $column3"; fi``if [ -n "$column4" ]; then echo ", $column4"; fi`"'</columns>\
       <file path="tool-data/'"$locfile"'"> </file>\
    </table>' >> $local_data_table
  fi
done

# re-add end of tables
echo "</tables>" >> $local_data_table

