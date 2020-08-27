#!/bin/bash

#PROJECT_NAME=${PWD##*/}  #获取当前目录

# VersionString=`grep -E 's.version.*=' $PROJECT_NAME.podspec`
# VersionNumber=`tr -cd 0-9 <<<"$VersionString"`
# NewVersionNumber=$(($VersionNumber + 1))
# LineNumber=`grep -nE 's.version.*=' $PROJECT_NAME.podspec | cut -d : -f1`
# sed -i "" "${LineNumber}s/${VersionNumber}/${NewVersionNumber}/g" $PROJECT_NAME.podspec

# echo "current version is ${VersionNumber}, new version is ${NewVersionNumber}"

# git commit -am ${NewVersionNumber}
# git tag ${NewVersionNumber}
# git push origin master --tags
# cd ~/.cocoapods/repos/BLRepositories && git pull origin master && cd - && pod repo push BLRepositories $PROJECT_NAME.podspec --verbose --allow-warnings --use-libraries

# echo "\n ---- 获取podspec文件 begin ---- \n"

PROJECT_NAME=${PWD##*/} #获取当前目录

VersionString=$(grep -E 's.version.*=' $PROJECT_NAME.podspec)
Homepage=$(grep -E 's.homepage.*=*"https' $PROJECT_NAME.podspec)
array=(${Homepage// / })
count=${#array[@]}           # 数组长度
Homepage=${array[count - 1]} #获取最后一个元素内容
Homepage=${Homepage//\"/}    # 去掉 "
Source=${Homepage}.git
echo ${Homepage}
echo ${Source}

echo "current version is ${VersionNumber}, new version is ${NewVersionNumber}"
VersionNumber=$(tr -cd 0-9 <<<"$VersionString")
NewVersionNumber=$(($VersionNumber + 1))
LineNumber=$(grep -nE 's.version.*=' $PROJECT_NAME.podspec | cut -d : -f1)
sed -i "" "${LineNumber}s/${VersionNumber}/${NewVersionNumber}/g" $PROJECT_NAME.podspec

echo "current version is ${VersionNumber}, new version is ${NewVersionNumber}"

echo "删除旧的二进制文件"
rm -rf ./$PROJECT_NAME-${VersionNumber}
rm -rf ./$PROJECT_NAME/SDK/$PROJECT_NAME.zip
rm -rf ./$PROJECT_NAME/SDK/$PROJECT_NAME.framework

git add .
git commit -am "新增Tag对应二进制文件"
git tag ${NewVersionNumber}
git push origin master --tags

echo "\n ---- 开始打包二进制文件 ---- \n"
pod package ./$PROJECT_NAME.podspec --exclude-deps --force --no-mangle --spec-sources=https://github.com/CocoaPods/Specs.git,https://github.com/fengshuo1992/example_spec_bin_dev.git
eval $PACKAGE

ret=$?

if [ "$ret" -ne "0" ]; then
  echo $?
  exit 1
fi

echo "\n ---- 二进制文件打包成功 ---- \n"

echo "\n ---- 完成二进制,移动到当前目录并开始压缩zip ---- \n"
cp -rf ./$PROJECT_NAME-${NewVersionNumber}/ios/$PROJECT_NAME.framework ./
zip --symlinks -r ./$PROJECT_NAME.zip ./$PROJECT_NAME.framework

rm -rf ./$PROJECT_NAME-${NewVersionNumber} #删除打包文件

if [ "$?" -eq "0" ]; then
  echo "\n --- 二进制压缩ZIP文件成功 ----\n"
else
  echo "\n --- 二进制文件压缩ZIP失败  ---\n"
  exit 1
fi


#获取上传状态
rm -rf ./$PROJECT_NAME.zip
rm -rf ./$PROJECT_NAME.framework

git commit -am ${NewVersionNumber}
git tag ${NewVersionNumber}
git push origin master --tags
cd ~/.cocoapods/repos/example_spec_bin_dev && git pull origin master && cd - && pod repo push example_spec_bin_dev $PROJECT_NAME.podspec --verbose --allow-warnings --use-libraries
