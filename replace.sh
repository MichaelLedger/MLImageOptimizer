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
#cd和pwd命令配合获取脚本所在绝对路径
path=$(cd "$(dirname "$0")";pwd)

#用readlink命令我们可以直接获取$0参数的全路径文件名，然后再用dirname获取其所在的绝对路径
#readlink -f $path 如果$path没有链接，就显示自己本身的绝对路径
#path=$(dirname $(readlink -f "$0"))

#Mac下的readlink没有-f参数，诸如screenfetch又会去调用readlink -f，于是每次都会出现：
#readlink: illegal option -- f
#usage: readlink [-n] [file ...]

#安装coreutils
#brew install coreutils
#用greadlink命令替代代readlink命令
#path=$(dirname $(greadlink -f "$0"))

source_dir=$1
##避免已有同名文件夹，拷贝到同名文件夹下
#[ -d $source_dir"-optimized" ] && rm -rf $source_dir"-optimized"
##加反斜杠 \cp 执行cp命令时不走alias，解决Linux CentOS中cp -f 复制强制覆盖的命令无效的方法
#\cp -R -f $source_dir $source_dir"-optimized"
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
#-d filename 如果filename为目录，则为真; mkdir参数P代表parents，表示递归创建目录
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
