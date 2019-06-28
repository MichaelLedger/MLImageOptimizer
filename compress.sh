#!/bin/sh
if [ $# == 0 ];then
    echo "--- not found dir ---"
    echo "--- please use command like this: '$ ./compress.sh <dir>' or '$ sh compress.sh <dir>' ---"
    exit
fi

if [ ! $# == 1 ];then
    echo "--- dir num > 1 ---"
    echo "--- please use command like this: '$ ./compress.sh <dir>' or '$ sh compress.sh <dir>' ---"
# chmod是Linux下设置文件权限的命令，后面的数字表示不同用户或用户组的权限。
# 第一个数字代表档案拥有者 第二个数字代表群组 第三个数字代表其他
# 在Linux中我们有三种常用权限：可读、可写以及可执行，用数字表示的话就是：可读=4 可写=2 可执行=1
# 755就代表 档案所有者权限(111)为—>可读可写可执行 群组权限(101)为—>可读可执行 其他人权限(101)为—>可读可执行
# 644则代表 档案所有者权限(110)为—>可读可写 群组权限(100)为—>可读 其他人权限(100)为—>可读
# 777就代表 所有用户都可读、可写、可执行
    echo "--- if use '$ ./compress.sh', command line tool print error: 'Permission denied', please modify privilege using '$ chmod 777 compress.sh'"
    exit
fi

path=`pwd`
echo "--- path="$path" ---"

#compress png [https://github.com/kornelski/pngquant]
#pngquant是一个命令行工具和一个用于有损压缩PNG图像的库。转换显着减少文件大小（通常高达70％），并保留完整的alpha透明度。生成的图像与所有网络浏览器和操作系统兼容。
#算法
#pngquant 使用中值切割量化算法的修改版本和附加技术来减轻中值切割的缺陷。
#而不是分裂具有最大音量或颜色数量的盒子，而是选择盒子以最小化其中值的方差。
#直方图是建立在基本感知模型的基础之上的，这样可以减少图像噪点区域的重量。
#为了进一步改善颜色，在类似于梯度下降的过程中调整直方图（中值切割重复许多次，在表现不佳的颜色上重量更多）。
#最后，使用Voronoi迭代（K均值）来校正颜色，这保证了局部最佳的调色板。
#pngquant 在预乘alpha颜色空间中工作，以减少透明颜色的重量。
#当重新映射时，误差扩散仅应用于若干相邻像素量化为相同值且不是边缘的区域。这避免了在没有抖动的情况下将视觉质量增加的区域。
#提供如下选项
#--help   帮助(简写-h)
#--force  覆盖已存在的导出文件(-f)
#--skip-if-larger当转换的文件比源文件更小时保存文件
#--output 目标文件路径(-o),与--ext用法相似(--ext and --output options can't be used at the same time)(  error: Only one input file is allowed when --output is used. This error also happens when filenames with spaces are not in quotes.)
#--ext 为导出文件添加一个后缀名，例如--ext new.png
#--quality min-max为图片转换加一个品质限制，如果转换后的图片比最低品质还低，就不保存，并返回错误码99.取值范围 0-100
#--speed 转换速度与品质的比例。1(最佳品质)，10(速度最快)，默认是3
#--verbose 打印出处理的状态

#安装pngquant依赖组件pkg-config
#brew install pkg-config

#Warning: pkg-config 0.29.2 is already installed, it's just not linked
#You can use `brew link pkg-config` to link this version.
#brew link pkg-config
#编译安装pngquant
#cd pngquant &&  ./configure && make && make install
#跳转回当前脚本所在目录
#cd ..

# 跳转到图片所在文件夹<dir>
source_dir=$1
echo "--- source_dir:"$source_dir" ---"
cd $source_dir

#.代表当前目录，查找所有以jpg结尾的文件并输出文件类型(匹配多个条件中的一个，采用OR条件操作)
#find . \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) -print | xargs file
#查找当前目录下所有指定后缀的文件并将结果输出到日志文件,一行输出一个结果
#find . -name "*.jpg" -print | xargs -n1 > /e/txt.log
find . \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" \) -print | xargs -n1 > ../txt.log
echo "--- see all images in txt.log ---"

echo "--- start compress png ---"
find . -name "*.png" -print | xargs -n1
#pngquant=$path/pngquant/pngquant
#使用lib中已经编译好的可执行文件进行压缩
pngquant=$path/lib/pngquant

#find . -name "*.png" -exec $pngquant --ext=.png --skip-if-larger --verbose --force {} \;

#mkdir ../compressed-pngs
#find . -name "*.png" -print | xargs cp ../compressed-pngs

#批量拷贝指定的文件到另一目录
##找到头文件路径列表
#head_files=`find . -name "*.png"`
#des_dir="../compressed-pngs"
#file_count=0
#
##目录不存在则创建
#[ -d $des_dir ] || mkdir -p $des_dir &> /dev/null
#
##进行拷贝过程
#for file in $head_files
#do
#echo $file"===="$des_dir$file
#cp $file $des_dir$file
#echo "$file has been copy."
#((file_count++))
#done
#
##对拷贝结果进行判断
#if [ $? != 0 ]; then
#echo "copy files error!!!"
#else
#echo "copy files successfully!,total $file_count files."
#fi

#图片导出目录
des_dir="../"$source_dir"-compressed-pngs"
echo "--- png_output_des_dir:"$des_dir" ---"
#目录不存在则创建
[ -d $des_dir ] || mkdir -p $des_dir

#批量拷贝指定的文件到另一目录
#find . -name "*.png" -exec cp {} $des_dir \;

#error: Only one input file is allowed when --output is used. This error also happens when filenames with spaces are not in quotes.
#find . -name "*.png" -exec $pngquant {} --skip-if-larger -v --force -o $des_dir \;
#或者
#find . -name "*.png" | xargs $pngquant --skip-if-larger --verbose --force -o $des_dir;

#pngquant设置的output路径不能为文件夹，只能一个个指定输出文件名称
#使用 # 号截取右边字符
#${string#*chars}
#其中，string 表示要截取的字符，chars 是指定的字符（或者子字符串），*是通配符的一种，表示任意长度的字符串。*chars连起来使用的意思是：忽略左边的所有字符，直到遇见 chars（chars 不会被截取）。
for file in `find . -name "*.png"`
do
    original_file=$file
    file_name=`echo ${original_file#*/}`
    $pngquant $file_name --skip-if-larger --verbose --force -o $des_dir"/"$file_name
done

#compress jpg [https://github.com/tjko/jpegoptim]
#JPEGOPTIM是CDN供应商Akamai开发的一个图片人优化的开源小工具,它有较好的图片压缩效果（压缩比、图片质量）, 比PHP的GD库算法要好。
#JpegOptim是用于优化jpeg文件的实用程序。提供无损优化（基于优化霍夫曼表Huffman）和基于设置最大品质因数的“有损”优化。所谓的“有损”优化除了优化之外。可以指定图像质量的上限。
#jpegoptim提供的选项如下:
#
#-d<path>, --dest=<path>
#//设置备选目标目录，以便保存优化。文件(默认是覆盖原始文件)。
#//请注意,不变的文件不会被添加到目标目录。
#//这意味着如果源文件不能被压缩，就不会有文件。在目标路径中创建。
#
#-f, --force
#//强制优化，即使结果大于。原始文件。
#
#-h, --help
#//显示简短的使用信息并退出。
#-m<quality>, --max=<quality>
#//设置最大图像质量因子(禁用无损优化)。mization模式是默认启用的。
#//设置这个选项会降低使用更高版本保存的源文件的质量。而那些已经有较低质量的文件。设置将使用无损优化进行压缩。
#
#-n, --noaction
#//不要真的优化文件，只需打印结果。
#
#-S<size>, --size=<size>
#//尝试优化文件大小（禁用了无损优化mizaiont模式）。目标尺寸指定KB（1 N）或百分比（1% - 99%）的原始文件的大小。
#
#-T<treshold>, --threshold=<treshold>
#//如果压缩增益低于阈值（%），则保持文件不变。传输安全有效值为：0 - 100
#
#-o, --overwrite
#//覆盖目标文件，即使它存在（使用D选项）。
#
#-p, --preserve
#//保存文件修改时间。
#
#-q, --quiet
#//安静模式。
#
#-t, --totals
#//处理完所有文件后打印总计。
#
#-v, --verbose
#//启用详细模式(积极聊天).
#
#--all-normal
#//强制所有输出文件为非逐行扫描。可以用来转换所有输入文件的渐进式JPEG当使用--force选项。
#
#--all-progressive
#//强制所有输出文件都是渐进的。可以将所有输入文件正常（非连续）当使用--force选项的JPEG文件。
#
#--strip-all
#//去除所有（Comment  & Exif）从输出文件删除标记。（注！默认情况下只有Comment  & Exif标记保存，其他一切都是丢弃）
#
#--strip-com
#//从输出文件中删除Comment(COM)标记。
#
#--strip-exif
#//从输出文件中删除标记。
#
#--strip-iptc
#//从输出文件中删除IPTC标记。
#
#--strip-icc
#//将ICC配置文件从输出文件中删除。

echo "--- start compress jpg ---"
find . \( -name "*.jpg" -o -name "*.jpeg" \) -print | xargs -n1

#如果要在Mac OS X上安装apt-get或yum类似的软件，你有两种选择：
#Homebrew：http://brew.sh
#Macports：http://www.macports.org
#安装了上面的程序之后(一个就行)，您可以使用$ brew install PACKAGE_NAME 或 $ port install PACKAGE_NAME安装可用的软件包。

#安装jpegoptim依赖组件libjpeg
#brew install libjpeg

#Warning: jpeg 9c is already installed, it's just not linked
#brew link jpeg

#安装jpegoptim，会在jpegoptim目录下生成可执行文件jpegoptim
#cd ../jpegoptim
#path3=`pwd`
#echo "--- path3="$path3" ---"
#./configure
#make
#make strip
#make install

#jpegoptim=$path/jpegoptim/jpegoptim
#使用lib中已经编译好的可执行文件进行压缩
jpegoptim=$path/lib/jpegoptim

#图片导出目录
des_dir="../"$source_dir"-compressed-jpgs"
echo "--- jpg_output_des_dir:"$des_dir" ---"
#目录不存在则创建
[ -d $des_dir ] || mkdir -p $des_dir

#无损优化
#find . \( -name "*.jpg" -o -name "*.jpeg" \) | xargs $jpegoptim -o --dest $des_dir;

#有损优化
#选项可以是传统的POSIX一个字母选项，也可以是。GNU风格长选项。 POSIX风格选项以一个“-”开头，而GNU的长选项以''--'开头。
#-m 后的数字代表压缩品质;将图片导出到指定目录
find . \( -name "*.jpg" -o -name "*.jpeg" \) | xargs $jpegoptim -m40 --overwrite --dest $des_dir;


echo "--- start compress gif ---"
find . -name "*.gif" -print | xargs -n1

#gifsicle 对GIF图片有三种优化选项：
#
#-O1 只保存每张图像上变化的部分。这是缺省模式。
#-O2 进一步用透明度压缩图片。
#-O3 尝试各种优化方法(通常速度会慢一些，有时会产生更好的效果)。
#优化GIF动图的命令行写法是这样的：
#gifsicle -O3 animation.gif -o animation-optimized.gif
#如果你有耐心和时间，推荐你尝试一下-O3，它有可能会给你输出体积更小的GIF动图。在有些图片上，它有可能压缩超过20%的体积，根据你提供的GIF动图的图片构成，它有可能压缩更大的体积。

#gifsicle=$path/gifsicle/src/gifsicle
#使用lib中已经编译好的可执行文件进行压缩
gifsicle=$path/lib/gifsicle

#图片导出目录
des_dir="../"$source_dir"-compressed-gifs"
echo "--- gif_output_des_dir:"$des_dir" ---"
#目录不存在则创建
[ -d $des_dir ] || mkdir -p $des_dir

for file in `find . -name "*.gif"`
do
    original_file=$file
    #字符串截取：保留左侧'/'后的部分，去除首部的'.'
    file_name=`echo ${original_file#*/}`
    $gifsicle $file -O3 --scale 0.5 --colors 256 --verbose -o $des_dir"/"$file_name
done

echo "--- compress completed ! ---"
