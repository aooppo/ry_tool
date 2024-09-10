### `README.md`

本代码为了快速修改若依（若依/RuoYi-Vue）框架内，所有包名及依赖(com.ruoyi)

# Replace Package Script

该项目包含两个脚本 (`.sh` 和 `.bat`)，用于在项目中自动化地替换包名、模块前缀和日志路径。根据不同的操作系统，提供了适用于 **Linux/macOS** 的 `Shell` 脚本和适用于 **Windows** 的批处理脚本。

## 项目功能

1. **替换包名**：将项目中的旧包名替换为新包名。
2. **替换模块前缀**：将旧模块前缀替换为新模块前缀。
3. **替换日志路径**：修改 `logback.xml` 文件中的日志存放路径。
4. **删除空的 `com` 文件夹**：如果在替换后某些 `com` 文件夹为空，自动删除这些空文件夹。

## 文件结构


```
/
│
├── replace_package.sh    # 适用于 Linux/macOS 的 Shell 脚本
├── rp.bat   # 适用于 Windows 的批处理脚本
└── README.md             # 使用说明
```

## 环境要求

### Linux/macOS

- 需要安装 `bash` 或 `zsh`，并确保脚本具备执行权限。
- `sed` 命令（大部分系统默认自带）。
- 适用于：**Linux** 和 **macOS**。

### Windows

- 需要 **Windows PowerShell** 来进行文本替换。
- 适用于：**Windows 10** 及以上版本，或支持 PowerShell 的其他 Windows 版本。

## 使用方法

### Linux/macOS (Shell 脚本)

1. **克隆 Git 仓库**：
   ```bash
   git clone https://github.com/your-repository-url/replace-package.git
   cd replace-package
   ```

2. **赋予 Shell 脚本执行权限**：
   ```bash
   chmod +x replace_package.sh
   ```

3. **运行脚本**：
   ```bash
   ./replace_package.sh
   ```

4. **输入要求的参数**：
   - 新的包名（例如：`cc.voox`）
   - 新的模块前缀（例如：`voox`）
   - 项目根目录路径（例如：`/path/to/your/project`）
   - 日志存放路径（例如：`/path/to/logs`）

### Windows (批处理脚本)

1. **克隆 Git 仓库**：
   ```bash
   git clone https://github.com/your-repository-url/replace-package.git
   cd replace-package
   ```

2. **运行批处理脚本**：
   - 打开 **命令提示符** (`cmd`) 或 **PowerShell**。
   - 导航到脚本所在目录，并运行：
     ```cmd
     rp.bat
     ```

3. **输入要求的参数**：
   - 新的包名（例如：`cc.voox`）
   - 新的模块前缀（例如：`voox`）
   - 项目根目录路径（例如：`C:\path\to\your\project`）
   - 日志存放路径（例如：`C:\path\to\logs`）

## 脚本功能详情

### 1. 替换包名和模块前缀

- **Linux/macOS**：使用 `sed` 命令进行包名替换和模块前缀替换。
- **Windows**：使用 PowerShell 的 `Get-Content` 和 `Set-Content` 命令替换文件中的包名和模块前缀。

### 2. 修改日志路径

- 修改 `logback.xml` 文件中的日志路径，默认查找 `ruoyi-admin/src/main/resources/logback.xml`。

### 3. 删除空的 `com` 文件夹

- 在所有替换操作完成后，检查项目中的 `com` 文件夹，如果为空，则自动删除该文件夹。

## 注意事项

1. 请确保脚本具有执行权限：
   - **Linux/macOS**：`chmod +x replace_package.sh`
   - **Windows**：不需要额外的执行权限。

2. 在执行脚本之前，建议**备份项目**，以防止意外的数据丢失或修改错误。

## 贡献

欢迎通过 `pull request` 或 `issue` 贡献您的想法和改进。

## 许可证

该项目遵循 MIT 许可证。详情请参考 `LICENSE` 文件。
```

### 如何使用

1. **文件结构**：
   - 将该 `README.md` 文件与脚本文件一起保存在项目中，确保项目结构清晰。
   - 示例项目结构：
     ```plaintext
     replace-package/
     ├── replace_package.sh    # Shell 脚本（Linux/macOS）
     ├── rp.bat   # 批处理脚本（Windows）
     └── README.md             # 使用说明
     ```

2. **克隆仓库**：
   - 在需要使用这个项目时，可以通过 `git clone` 命令克隆这个仓库到本地。
   - 在不同操作系统中，根据 `README.md` 中的说明，运行相应的脚本。

### 其他提示

- 如果你希望在 GitHub 上创建一个仓库，可以将此 `README.md` 文件和脚本文件推送到 GitHub 仓库中。
- 在 `README.md` 中的 `git clone` 链接部分，替换成你自己的仓库 URL。
