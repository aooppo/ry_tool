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
rem ========== 输入结束 ==========

rem 将包名转换为路径格式（例如：com.ruoyi -> com\ruoyi）
set old_package_path=%old_package:.=\%
set new_package_path=%new_package:.=\%

echo 开始替换包名：%old_package% -> %new_package%
echo 开始替换包名目录结构：%old_package_path% -> %new_package_path%
echo 项目根目录: %project_root%

rem 1. 替换包名目录
echo 开始替换包名目录...
for /r "%project_root%" %%d in (*) do (
    set "dir=%%~dpd"
    if not "!dir!" == "" (
        echo !dir! | findstr /i /c:"%old_package_path%" >nul
        if not errorlevel 1 (
            set "new_dir=!dir:%old_package_path%=%new_package_path%!"
            echo 重命名目录: !dir! -> !new_dir!
            if not exist "!new_dir!" (
                mkdir "!new_dir!"
                move /Y "!dir!" "!new_dir!"
            )
        )
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
for /r "%project_root%" %%f in (pom.xml) do (
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
for /r "%project_root%" %%d in (*) do (
    set "dir=%%~dpd"
    if not "!dir!" == "" (
        echo !dir! | findstr /i /c:"%old_module_prefix%" >nul
        if not errorlevel 1 (
            set "new_dir=!dir:%old_module_prefix%=%new_module_prefix%!"
            echo 重命名目录: !dir! -> !new_dir!
            if not exist "!new_dir!" (
                mkdir "!new_dir!"
                move /Y "!dir!" "!new_dir!"
            )
        )
    )
)

for /r "%project_root%" %%f in (*) do (
    echo 处理文件: %%f
    powershell -Command "(Get-Content -Path '%%f') -replace '%old_module_prefix%', '%new_module_prefix%' | Set-Content -Path '%%f'"
)

rem 6. 删除空的 com 文件夹
echo 开始删除空的 com 文件夹...
for /d /r "%project_root%" %%d in (com) do (
    if not exist "%%d\*" (
        echo 删除空的 com 文件夹: %%d
        rmdir /s /q "%%d"
    )
)

echo 所有替换操作完成！