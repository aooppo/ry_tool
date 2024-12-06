@echo off
setlocal enabledelayedexpansion

rem ========== 固定配置部分 ==========
set old_package=com.ruoyi
set old_module_prefix=ruoyi
rem ========== 固定配置结束 ==========

rem ========== 用户输入部分 ==========
set /p new_package="请输入新的包名 (例如：cc.voox): "
if "%new_package%"=="" (
    echo 新包名不能为空。
    exit /b 1
)

set /p new_module_prefix="请输入新的模块前缀 (例如：voox): "
if "%new_module_prefix%"=="" (
    echo 新的模块前缀不能为空。
    exit /b 1
)

set /p project_root="请输入项目的根目录路径 (例如：C:\path\to\your\project): "
if "%project_root%"=="" (
    echo 项目根目录不能为空。
    exit /b 1
)

set /p log_path="请输入日志存放路径 (例如：C:\path\to\logs): "
if "%log_path%"=="" (
    echo 日志存放路径不能为空。
    exit /b 1
)

rem ========== 初始化日志 ==========
set log_file=%log_path%\rename_script_%date:~0,4%-%date:~5,2%-%date:~8,2%_%time:~0,2%-%time:~3,2%.log
echo 脚本运行日志存储在: %log_file%

rem 将包名转换为路径格式（例如：com.ruoyi -> com\ruoyi）
set old_package_path=%old_package:.=\%
set new_package_path=%new_package:.=\%

rem 开始操作日志
(
    echo 开始替换包名：%old_package% -> %new_package%
    echo 开始替换包名目录结构：%old_package_path% -> %new_package_path%
    echo 项目根目录: %project_root%

    rem 1. 替换包名目录
    echo 开始替换包名目录...
    for /f "tokens=*" %%d in ('dir /ad /s /b "%project_root%\*" ^| findstr /i "%old_package_path%"') do (
        set "new_dir=%%d"
        set "new_dir=!new_dir:%old_package_path%=%new_package_path%!"
        echo 重命名目录: %%d -> !new_dir!
        if not exist "!new_dir!" (
            mkdir "!new_dir!"
            move "%%d" "!new_dir!"
        )
    )

    rem 2. 替换 Java 文件中的包声明
    echo 开始替换文件中的包声明...
    for /r "%project_root%" %%f in (*.java) do (
        echo 处理文件: %%f
        powershell -Command "(Get-Content -Path '%%f') -replace '%old_package%', '%new_package%' | Set-Content -Path '%%f'"
    )

    rem 3. 替换 pom.xml、README.md 和其他配置文件中的包名
    echo 开始替换 pom.xml 文件中的包名...
    for /r "%project_root%" %%f in (pom.xml README.md) do (
        echo 处理文件: %%f
        powershell -Command "(Get-Content -Path '%%f') -replace '%old_package%', '%new_package%' | Set-Content -Path '%%f'"
    )

    echo 开始替换其他配置文件中的包名...
    for /r "%project_root%" %%f in (*.xml *.yml *.properties) do (
        echo 处理文件: %%f
        powershell -Command "(Get-Content -Path '%%f') -replace '%old_package%', '%new_package%' | Set-Content -Path '%%f'"
    )

    rem 4. 替换 logback.xml 中的日志路径
    set logback_file=%project_root%\ruoyi-admin\src\main\resources\logback.xml
    if exist "%logback_file%" (
        echo 正在处理 %logback_file% 中的日志路径...
        powershell -Command "(Get-Content -Path '%logback_file%') -replace '/home/ruoyi/logs', '%log_path%' | Set-Content -Path '%logback_file%'"
    )

    rem 5. 替换模块名称
    echo 开始替换模块名称...
    for /f "tokens=*" %%d in ('dir /ad /s /b "%project_root%\*" ^| findstr /i "%old_module_prefix%"') do (
        set "new_dir=%%d"
        set "new_dir=!new_dir:%old_module_prefix%=%new_module_prefix%!"
        echo 重命名目录: %%d -> !new_dir!
        if not exist "!new_dir!" (
            mkdir "!new_dir!"
            move "%%d" "!new_dir!"
        )
    )

    for /r "%project_root%" %%f in (*%old_module_prefix%*) do (
        set "new_file=%%f"
        set "new_file=!new_file:%old_module_prefix%=%new_module_prefix%!"
        echo 重命名文件: %%f -> !new_file!
        move "%%f" "!new_file!"
    )

    rem 6. 替换路径别名中的模块引用
    echo 开始替换路径别名中的模块引用...
    for /r "%project_root%" %%f in (*.js *.vue *.scss) do (
        echo 处理文件: %%f
        powershell -Command "(Get-Content -Path '%%f') -replace '@/utils/%old_module_prefix%', '@/utils/%new_module_prefix%' | Set-Content -Path '%%f'"
        powershell -Command "(Get-Content -Path '%%f') -replace '@/assets/styles/%old_module_prefix%.scss', '@/assets/styles/%new_module_prefix%.scss' | Set-Content -Path '%%f'"
    )

    rem 7. 删除空的 com 文件夹
    echo 开始删除空的 com 文件夹...
    for /d /r "%project_root%" %%d in (com) do (
        if not exist "%%d\*" (
            echo 删除空的 com 文件夹: %%d
            rmdir /s /q "%%d"
        )
    )

    echo 所有替换操作完成！
) > "%log_file%"