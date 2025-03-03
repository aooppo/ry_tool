#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ========== 固定配置部分 ==========
old_package="com.ruoyi"
old_module_prefix="ruoyi"
# ========== 固定配置结束 ==========

# ========== 用户输入部分 ==========
read -rp "请输入新的包名 (例如：cc.voox): " new_package
if [[ -z "$new_package" ]]; then
    echo "新包名不能为空。"
    exit 1
fi

read -rp "请输入新的模块前缀 (例如：voox): " new_module_prefix
if [[ -z "$new_module_prefix" ]]; then
    echo "新的模块前缀不能为空。"
    exit 1
fi

read -rp "请输入项目的根目录路径 (例如：/path/to/your/project): " project_root
if [[ -z "$project_root" ]]; then
    echo "项目根目录不能为空。"
    exit 1
fi

read -rp "请输入日志存放路径 (例如：/path/to/logs): " log_path
if [[ -z "$log_path" ]]; then
    echo "日志存放路径不能为空。"
    exit 1
fi
# ========== 用户输入结束 ==========

# ========== 初始化日志 ==========
timestamp=$(date +%Y%m%d_%H%M%S)
log_file="${log_path}/rename_script_${timestamp}.log"
echo "脚本运行日志将存储在: $log_file"

# 将包名转换为路径格式（例如：com.ruoyi -> com/ruoyi）
old_package_path=$(echo "$old_package" | tr '.' '/')
new_package_path=$(echo "$new_package" | tr '.' '/')

{
  echo "开始替换包名：$old_package -> $new_package"
  echo "开始替换包名目录结构：$old_package_path -> $new_package_path"
  echo "项目根目录: $project_root"

  # 1. 替换包名目录
  echo "开始替换包名目录..."
  find "$project_root" -type d -path "*$old_package_path*" | while read -r dir; do
      new_dir=$(echo "$dir" | sed "s#$old_package_path#$new_package_path#g")
      echo "重命名目录: $dir -> $new_dir"
      mkdir -p "$(dirname "$new_dir")"
      mv "$dir" "$new_dir"
  done

  # 2. 替换Java文件中的包声明 (适用于 macOS 和 Linux)
  echo "开始替换文件中的包声明..."
  find "$project_root" -type f -name "*.java" | while read -r file; do
      echo "处理文件: $file"
      if [[ "$OSTYPE" == darwin* ]]; then
          sed -i '' "s/$old_package/$new_package/g" "$file"
      else
          sed -i "s/$old_package/$new_package/g" "$file"
      fi
  done

  # 3. 替换 pom.xml 中的包名
  echo "开始替换 pom.xml 文件中的包名..."
  find "$project_root" -type f -name "pom.xml" | while read -r file; do
      echo "处理 pom 文件: $file"
      if [[ "$OSTYPE" == darwin* ]]; then
          sed -i '' "s/$old_package/$new_package/g" "$file"
      else
          sed -i "s/$old_package/$new_package/g" "$file"
      fi
  done

  echo "开始替换其他配置文件中的包名 (如 .xml, .yml, .properties)..."
  find "$project_root" -type f \( -name "*.xml" -o -name "*.yml" -o -name "*.properties" \) | while read -r file; do
      echo "处理配置文件: $file"
      if [[ "$OSTYPE" == darwin* ]]; then
          sed -i '' "s/$old_package/$new_package/g" "$file"
      else
          sed -i "s/$old_package/$new_package/g" "$file"
      fi
  done

  # 4. 替换 logback.xml 中的日志路径
  logback_file="${project_root}/ruoyi-admin/src/main/resources/logback.xml"
  if [[ -f "$logback_file" ]]; then
      echo "正在处理 $logback_file 中的日志路径..."
      if [[ "$OSTYPE" == darwin* ]]; then
          sed -i '' "s#/home/ruoyi/logs#$log_path#g" "$logback_file"
      else
          sed -i "s#/home/ruoyi/logs#$log_path#g" "$logback_file"
      fi
  fi

  # 5. 替换模块名称（目录和文件）
  echo "开始替换模块名称..."
  find "$project_root" -type d -name "*${old_module_prefix}*" | while read -r dir; do
      new_dir=$(echo "$dir" | sed "s#$old_module_prefix#$new_module_prefix#g")
      echo "重命名模块目录: $dir -> $new_dir"
      mv "$dir" "$new_dir"
  done

  find "$project_root" -type f -name "*${old_module_prefix}*" | while read -r file; do
      new_file=$(echo "$file" | sed "s#$old_module_prefix#$new_module_prefix#g")
      echo "重命名模块文件: $file -> $new_file"
      mv "$file" "$new_file"
  done

  # 6. 替换路径别名中的模块引用
  echo "开始替换路径别名中的模块引用..."
  find "$project_root" -type f \( -name "*.js" -o -name "*.vue" -o -name "*.scss" \) | while read -r file; do
      echo "处理文件: $file"
      if [[ "$OSTYPE" == darwin* ]]; then
          sed -i '' "s#@/utils/${old_module_prefix}#@/utils/${new_module_prefix}#g" "$file"
          sed -i '' "s#@/assets/styles/${old_module_prefix}.scss#@/assets/styles/${new_module_prefix}.scss#g" "$file"
      else
          sed -i "s#@/utils/${old_module_prefix}#@/utils/${new_module_prefix}#g" "$file"
          sed -i "s#@/assets/styles/${old_module_prefix}.scss#@/assets/styles/${new_module_prefix}.scss#g" "$file"
      fi
  done

  # 7. 替换 pom.xml 中的模块依赖
  echo "开始替换 pom.xml 文件中的模块依赖..."
  find "$project_root" -type f -name "pom.xml" | while read -r file; do
      echo "处理 pom 文件中的模块依赖: $file"
      if [[ "$OSTYPE" == darwin* ]]; then
          sed -i '' "s/$old_module_prefix/$new_module_prefix/g" "$file"
      else
          sed -i "s/$old_module_prefix/$new_module_prefix/g" "$file"
      fi
  done

  # 8. 删除空的 com 文件夹
  echo "开始删除空的 com 文件夹..."
  find "$project_root" -type d -name "com" | while read -r com_dir; do
      if [[ -z "$(ls -A "$com_dir")" ]]; then
          echo "删除空的 com 文件夹: $com_dir"
          rmdir "$com_dir"
      fi
  done

  # 9. 替换 ruoyi-ui/src/utils/index.js 中的 import 语句
  echo "开始替换 ${new_module_prefix}-ui/src/utils/index.js 中的 import 语句..."
  index_js_file="${project_root}/${new_module_prefix}-ui/src/utils/index.js"
  if [[ -f "$index_js_file" ]]; then
      echo "处理文件: $index_js_file"
      if [[ "$OSTYPE" == darwin* ]]; then
          sed -i '' "s#import { parseTime } from './${old_module_prefix}'#import { parseTime } from './${new_module_prefix}'#g" "$index_js_file"
      else
          sed -i "s#import { parseTime } from './${old_module_prefix}'#import { parseTime } from './${new_module_prefix}'#g" "$index_js_file"
      fi
      echo "✅ 替换完成: import { parseTime } from './${new_module_prefix}'"
  else
      echo "⚠️ 警告: 找不到 ${index_js_file}，跳过此步骤。"
  fi

  echo "所有替换操作完成！"

} | tee "$log_file"