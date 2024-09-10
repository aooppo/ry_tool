#!/bin/bash

# ========== 固定配置部分 ==========
# 旧包名
old_package="com.ruoyi"

# 旧模块前缀
old_module_prefix="ruoyi"
# ========== 固定配置结束 ==========

# ========== 用户输入部分 ==========
echo "请输入新的包名 (例如：cc.voox):"
read new_package

if [ -z "$new_package" ]; then
    echo "新包名不能为空。"
    exit 1
fi

echo "请输入新的模块前缀 (例如：voox):"
read new_module_prefix

if [ -z "$new_module_prefix" ]; then
    echo "新的模块前缀不能为空。"
    exit 1
fi

echo "请输入项目的根目录路径 (例如：/path/to/your/project):"
read project_root

if [ -z "$project_root" ]; then
    echo "项目根目录不能为空。"
    exit 1
fi

echo "请输入日志存放路径 (例如：/path/to/logs):"
read log_path

if [ -z "$log_path" ]; then
    echo "日志存放路径不能为空。"
    exit 1
fi
# ========== 输入结束 ==========

# 将包名转换为路径格式（例如：com.ruoyi -> com/ruoyi）
old_package_path=$(echo "$old_package" | tr '.' '/')
new_package_path=$(echo "$new_package" | tr '.' '/')

echo "开始替换包名：$old_package -> $new_package"
echo "开始替换包名目录结构：$old_package_path -> $new_package_path"
echo "项目根目录: $project_root"

# 1. 替换包名目录
echo "开始替换包名目录..."
find "$project_root" -type d -path "*$old_package_path*" | while read dir; do
    new_dir=$(echo "$dir" | sed "s#$old_package_path#$new_package_path#g")
    echo "重命名目录: $dir -> $new_dir"
    mkdir -p "$(dirname "$new_dir")"
    mv "$dir" "$new_dir"
done

# 2. 替换Java文件中的包声明 (适用于macOS和Linux)
echo "开始替换文件中的包声明..."
find "$project_root" -type f -name "*.java" | while read file; do
    echo "处理文件: $file"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/$old_package/$new_package/g" "$file"
    else
        sed -i "s/$old_package/$new_package/g" "$file"
    fi
done

# 3. 替换pom.xml、README.md 和其他配置文件中的包名
echo "开始替换pom.xml文件中的包名..."
find "$project_root" -type f -name "pom.xml" | while read file; do
    echo "处理pom文件: $file"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/$old_package/$new_package/g" "$file"
    else
        sed -i "s/$old_package/$new_package/g" "$file"
    fi
done

echo "开始替换其他配置文件中的包名 (如 .xml, .yml, .properties)..."
find "$project_root" -type f \( -name "*.xml" -o -name "*.yml" -o -name "*.properties" \) | while read file; do
    echo "处理配置文件: $file"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/$old_package/$new_package/g" "$file"
    else
        sed -i "s/$old_package/$new_package/g" "$file"
    fi
done

# 4. 替换logback.xml中的日志路径
logback_file="$project_root/ruoyi-admin/src/main/resources/logback.xml"
if [ -f "$logback_file" ]; then
    echo "正在处理 $logback_file 中的日志路径..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s#/home/ruoyi/logs#$log_path#g" "$logback_file"
    else
        sed -i "s#/home/ruoyi/logs#$log_path#g" "$logback_file"
    fi
fi

# 5. 替换模块名称
echo "开始替换模块名称..."
find "$project_root" -type d -name "*$old_module_prefix*" | while read dir; do
    new_dir=$(echo "$dir" | sed "s#$old_module_prefix#$new_module_prefix#g")
    echo "重命名模块目录: $dir -> $new_dir"
    mv "$dir" "$new_dir"
done

find "$project_root" -type f -name "*$old_module_prefix*" | while read file; do
    new_file=$(echo "$file" | sed "s#$old_module_prefix#$new_module_prefix#g")
    echo "重命名模块文件: $file -> $new_file"
    mv "$file" "$new_file"
done

# 6. 替换pom.xml等文件中的模块依赖
echo "开始替换pom.xml文件中的模块依赖..."
find "$project_root" -type f -name "pom.xml" | while read file; do
    echo "处理pom文件中的模块依赖: $file"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/$old_module_prefix/$new_module_prefix/g" "$file"
    else
        sed -i "s/$old_module_prefix/$new_module_prefix/g" "$file"
    fi
done

# 7. 删除空的com文件夹
echo "开始删除空的com文件夹..."
find "$project_root" -type d -name "com" | while read com_dir; do
    if [ -z "$(ls -A "$com_dir")" ]; then
        echo "删除空的com文件夹: $com_dir"
        rmdir "$com_dir"
    fi
done

echo "所有替换操作完成！"