#!/bin/sh
if [ $# == 0 ];then
    echo "--- not found dir ---"
    echo "--- please use command like this: '$ ./compress.sh <dir>' or '$ sh compress.sh <dir>' ---"
    exit
fi
if [ ! $# == 1 ];then
    echo "--- dir num > 1 ---"
    exit
fi
path=$(cd "$(dirname "$0")";pwd)
source_dir=$1
cd $source_dir
echo "--- start compress png ---"
find . -name "*.png" -print | xargs -n1
pngquant=$path/lib/pngquant
des_dir=$source_dir
echo "--- png_output_des_dir:"$des_dir" ---"
[ -d $des_dir ] || mkdir -p $des_dir
for file in `find . -name "*.png"`
do
    original_file=$file
    file_name=`echo ${original_file#*/}`
    $pngquant $file_name --skip-if-larger --verbose --force -o $des_dir"/"$file_name
done
echo "--- start compress jpg ---"
find . \( -name "*.jpg" -o -name "*.jpeg" \) -print | xargs -n1
jpegoptim=$path/lib/jpegoptim
des_dir=$source_dir
echo "--- jpg_output_des_dir:"$des_dir" ---"
[ -d $des_dir ] || mkdir -p $des_dir
for file in `find . \( -name "*.jpg" -o -name "*.jpeg" \)`
do
original_file=$file
file_name=`echo ${original_file#*/}`
[[ $file_name =~ "/" ]] && echo "$file_name contains '/'" && sub_file_path=`echo ${file_name%/*}`
[ -d $des_dir"/"$sub_file_path ] || mkdir -p $des_dir"/"$sub_file_path
[[ $file_name =~ "/" ]] || echo "$file_name does NOT contains '/'" || sub_file_path=""
echo $file_name"===="$des_dir"/"$sub_file_path
$jpegoptim $file -m40 -o -d $des_dir"/"$sub_file_path
done
echo "--- start compress gif ---"
find . -name "*.gif" -print | xargs -n1
gifsicle=$path/lib/gifsicle
des_dir=$source_dir
echo "--- gif_output_des_dir:"$des_dir" ---"
[ -d $des_dir ] || mkdir -p $des_dir
for file in `find . -name "*.gif"`
do
    original_file=$file
    file_name=`echo ${original_file#*/}`
    $gifsicle $file -O3 --colors 256 --verbose -o $des_dir"/"$file_name
done
echo "--- compress completed ! ---"
