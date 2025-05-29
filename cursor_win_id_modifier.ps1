# Устанавливаем вывод в UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Определение цветов
$RED = "`e[31m"
$GREEN = "`e[32m"
$YELLOW = "`e[33m"
$BLUE = "`e[34m"
$NC = "`e[0m"

# Пути к файлам конфигурации
$STORAGE_FILE = "$env:APPDATA\Cursor\User\globalStorage\storage.json"
$BACKUP_DIR = "$env:APPDATA\Cursor\User\globalStorage\backups"

# Функция инициализации Cursor (очистка)
function Cursor-Инициализация {
    Write-Host "$GREEN[Информация]$NC Выполняется инициализация и очистка Cursor..."
    $BASE_PATH = "$env:APPDATA\Cursor\User"

    $filesToDelete = @(
        (Join-Path -Path $BASE_PATH -ChildPath "globalStorage\\state.vscdb"),
        (Join-Path -Path $BASE_PATH -ChildPath "globalStorage\\state.vscdb.backup")
    )
    
    $folderToCleanContents = Join-Path -Path $BASE_PATH -ChildPath "History"
    $folderToDeleteCompletely = Join-Path -Path $BASE_PATH -ChildPath "workspaceStorage"

    Write-Host "$BLUE[Отладка]$NC Базовый путь: $($BASE_PATH)"

    # Удаление указанных файлов
    foreach ($file in $filesToDelete) {
        Write-Host "$BLUE[Отладка]$NC Проверка файла: $($file)"
        if (Test-Path $file) {
            try {
                Remove-Item -Path $file -Force -ErrorAction Stop
                Write-Host "$GREEN[Успех]$NC Файл удалён: $($file)"
            }
            catch {
                Write-Host "$RED[Ошибка]$NC Не удалось удалить файл $($file): $($_.Exception.Message)"
            }
        } else {
            Write-Host "$YELLOW[Предупреждение]$NC Файл не найден, пропуск: $($file)"
        }
    }

    # Очистка содержимого папки
    Write-Host "$BLUE[Отладка]$NC Проверка папки для очистки: $($folderToCleanContents)"
    if (Test-Path $folderToCleanContents) {
        try {
            # Удаляем содержимое, не саму папку
            Get-ChildItem -Path $folderToCleanContents -Recurse | Remove-Item -Recurse -Force -ErrorAction Stop
            Write-Host "$GREEN[Успех]$NC Содержимое папки очищено: $($folderToCleanContents)"
        }
        catch {
            Write-Host "$RED[Ошибка]$NC Не удалось очистить папку $($folderToCleanContents): $($_.Exception.Message)"
        }
    } else {
        Write-Host "$YELLOW[Предупреждение]$NC Папка не найдена, пропуск очистки: $($folderToCleanContents)"
    }

    # Удаление папки полностью
    Write-Host "$BLUE[Отладка]$NC Проверка папки для удаления: $($folderToDeleteCompletely)"
    if (Test-Path $folderToDeleteCompletely) {
        try {
            Remove-Item -Path $folderToDeleteCompletely -Recurse -Force -ErrorAction Stop
            Write-Host "$GREEN[Успех]$NC Папка удалена: $($folderToDeleteCompletely)"
        }
        catch {
            Write-Host "$RED[Ошибка]$NC Не удалось удалить папку $($folderToDeleteCompletely): $($_.Exception.Message)"
        }
    } else {
        Write-Host "$YELLOW[Предупреждение]$NC Папка не найдена, пропуск удаления: $($folderToDeleteCompletely)"
    }

    Write-Host "$GREEN[Информация]$NC Инициализация и очистка Cursor завершена."
    Write-Host "" # Пустая строка для форматирования
}

# 检查管理员权限
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($user)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host "$RED[Ошибка]$NC 请以管理员身份运行此脚本"
    Write-Host "请右键点击脚本，选择'以管理员身份运行'"
    Read-Host "Нажмите Enter для выхода"
    exit 1
}

# 显示 Logo
Clear-Host
Write-Host @"

    ██████╗██╗   ██╗██████╗ ███████╗ ██████╗ ██████╗ 
   ██╔════╝██║   ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗
   ██║     ██║   ██║██████╔╝███████╗██║   ██║██████╔╝
   ██║     ██║   ██║██╔══██╗╚════██║██║   ██║██╔══██╗
   ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██║  ██║
    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝

"@
Write-Host "$BLUE================================$NC"
Write-Host "$GREEN   Cursor 设备ID 修改工具          $NC"
Write-Host "$YELLOW   Подпишитесь на канал «Блинчик с AI» $NC"
Write-Host "$YELLOW  Общайтесь и делитесь опытом по Cursor и AI (скрипт бесплатный, больше советов в чате канала)  $NC"
Write-Host "$YELLOW  [Важное замечание]  Этот инструмент бесплатный, если он вам помог, пожалуйста подпишитесь на канал «Блинчик с AI»  $NC"
Write-Host "$BLUE================================$NC"
Write-Host ""

# 获取并显示 Cursor 版本
function Get-CursorVersion {
    try {
        # 主要检测路径
        $packagePath = "$env:LOCALAPPDATA\\Programs\\cursor\\resources\\app\\package.json"
        
        if (Test-Path $packagePath) {
            $packageJson = Get-Content $packagePath -Raw | ConvertFrom-Json
            if ($packageJson.version) {
                Write-Host "$GREEN[Информация]$NC Текущая установленная версия Cursor: v$($packageJson.version)"
                return $packageJson.version
            }
        }

        # 备用路径检测
        $altPath = "$env:LOCALAPPDATA\\cursor\\resources\\app\\package.json"
        if (Test-Path $altPath) {
            $packageJson = Get-Content $altPath -Raw | ConvertFrom-Json
            if ($packageJson.version) {
                Write-Host "$GREEN[Информация]$NC Текущая установленная версия Cursor: v$($packageJson.version)"
                return $packageJson.version
            }
        }

        Write-Host "$YELLOW[Предупреждение]$NC Не удалось определить версию Cursor"
        Write-Host "$YELLOW[Подсказка]$NC Убедитесь, что Cursor установлен правильно"
        return $null
    }
    catch {
        Write-Host "$RED[Ошибка]$NC Получение версии Cursor не удалось: $_"
        return $null
    }
}

# 获取并显示版本信息
$cursorVersion = Get-CursorVersion
Write-Host ""

Write-Host "$YELLOW[Важное замечание]$NC Последняя версия 0.50.x (поддерживается)"
Write-Host ""

# 检查并关闭 Cursor 进程
Write-Host "$GREEN[信息]$NC 检查 Cursor 进程..."

function Get-ProcessDetails {
    param($processName)
    Write-Host "$BLUE[调试]$NC 正在获取 $processName 进程详细信息："
    Get-WmiObject Win32_Process -Filter "name='$processName'" | 
        Select-Object ProcessId, ExecutablePath, CommandLine | 
        Format-List
}

# 定义最大重试次数和等待时间
$MAX_RETRIES = 5
$WAIT_TIME = 1

# 处理进程关闭
function Close-CursorProcess {
    param($processName)
    
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "$YELLOW[警告]$NC 发现 $processName 正在运行"
        Get-ProcessDetails $processName
        
        Write-Host "$YELLOW[警告]$NC 尝试关闭 $processName..."
        Stop-Process -Name $processName -Force
        
        $retryCount = 0
        while ($retryCount -lt $MAX_RETRIES) {
            $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
            if (-not $process) { break }
            
            $retryCount++
            if ($retryCount -ge $MAX_RETRIES) {
                Write-Host "$RED[错误]$NC 在 $MAX_RETRIES 次尝试后仍无法关闭 $processName"
                Get-ProcessDetails $processName
                Write-Host "$RED[错误]$NC 请手动关闭进程后重试"
                Read-Host "按回车键退出"
                exit 1
            }
            Write-Host "$YELLOW[警告]$NC 等待进程关闭，尝试 $retryCount/$MAX_RETRIES..."
            Start-Sleep -Seconds $WAIT_TIME
        }
        Write-Host "$GREEN[信息]$NC $processName 已成功关闭"
    }
}

# 关闭所有 Cursor 进程
Close-CursorProcess "Cursor"
Close-CursorProcess "cursor"

# 执行 Cursor 初始化清理
Cursor-Инициализация

# 创建备份目录
if (-not (Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR | Out-Null
}

# 备份现有配置
if (Test-Path $STORAGE_FILE) {
    Write-Host "$GREEN[信息]$NC 正在备份配置文件..."
    $backupName = "storage.json.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $STORAGE_FILE "$BACKUP_DIR\$backupName"
}

# 生成新的 ID
Write-Host "$GREEN[信息]$NC 正在生成新的 ID..."

# 在颜色定义后添加此函数
function Get-RandomHex {
    param (
        [int]$length
    )
    
    $bytes = New-Object byte[] ($length)
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
    $rng.GetBytes($bytes)
    $hexString = [System.BitConverter]::ToString($bytes) -replace '-',''
    $rng.Dispose()
    return $hexString
}

# 改进 ID 生成函数
function New-StandardMachineId {
    $template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    $result = $template -replace '[xy]', {
        param($match)
        $r = [Random]::new().Next(16)
        $v = if ($match.Value -eq "x") { $r } else { ($r -band 0x3) -bor 0x8 }
        return $v.ToString("x")
    }
    return $result
}

# 在生成 ID 时使用新函数
$MAC_MACHINE_ID = New-StandardMachineId
$UUID = [System.Guid]::NewGuid().ToString()
# 将 auth0|user_ 转换为字节数组的十六进制
$prefixBytes = [System.Text.Encoding]::UTF8.GetBytes("auth0|user_")
$prefixHex = -join ($prefixBytes | ForEach-Object { '{0:x2}' -f $_ })
# 生成32字节(64个十六进制字符)的随机数作为 machineId 的随机部分
$randomPart = Get-RandomHex -length 32
$MACHINE_ID = "$prefixHex$randomPart"
$SQM_ID = "{$([System.Guid]::NewGuid().ToString().ToUpper())}"

# 在Update-MachineGuid函数前添加权限检查
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "$RED[错误]$NC 请使用管理员权限运行此脚本"
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Update-MachineGuid {
    try {
        # 检查注册表路径是否存在，不存在则创建
        $registryPath = "HKLM:\SOFTWARE\Microsoft\Cryptography"
        if (-not (Test-Path $registryPath)) {
            Write-Host "$YELLOW[警告]$NC 注册表路径不存在: $registryPath，正在创建..."
            New-Item -Path $registryPath -Force | Out-Null
            Write-Host "$GREEN[信息]$NC 注册表路径创建成功"
        }

        # 获取当前的 MachineGuid，如果不存在则使用空字符串作为默认值
        $originalGuid = ""
        try {
            $currentGuid = Get-ItemProperty -Path $registryPath -Name MachineGuid -ErrorAction SilentlyContinue
            if ($currentGuid) {
                $originalGuid = $currentGuid.MachineGuid
                Write-Host "$GREEN[信息]$NC 当前注册表值："
                Write-Host "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography" 
                Write-Host "    MachineGuid    REG_SZ    $originalGuid"
            } else {
                Write-Host "$YELLOW[警告]$NC MachineGuid 值不存在，将创建新值"
            }
        } catch {
            Write-Host "$YELLOW[警告]$NC 获取 MachineGuid 失败: $($_.Exception.Message)"
        }

        # 创建备份目录（如果不存在）
        if (-not (Test-Path $BACKUP_DIR)) {
            New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
        }

        # 创建备份文件（仅当原始值存在时）
        if ($originalGuid) {
            $backupFile = "$BACKUP_DIR\MachineGuid_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
            $backupResult = Start-Process "reg.exe" -ArgumentList "export", "`"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography`"", "`"$backupFile`"" -NoNewWindow -Wait -PassThru
            
            if ($backupResult.ExitCode -eq 0) {
                Write-Host "$GREEN[信息]$NC 注册表项已备份到：$backupFile"
            } else {
                Write-Host "$YELLOW[警告]$NC 备份创建失败，继续执行..."
            }
        }

        # 生成新GUID
        $newGuid = [System.Guid]::NewGuid().ToString()

        # 更新或创建注册表值
        Set-ItemProperty -Path $registryPath -Name MachineGuid -Value $newGuid -Force -ErrorAction Stop
        
        # 验证更新
        $verifyGuid = (Get-ItemProperty -Path $registryPath -Name MachineGuid -ErrorAction Stop).MachineGuid
        if ($verifyGuid -ne $newGuid) {
            throw "注册表验证失败：更新后的值 ($verifyGuid) 与预期值 ($newGuid) 不匹配"
        }

        Write-Host "$GREEN[信息]$NC 注册表更新成功："
        Write-Host "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography"
        Write-Host "    MachineGuid    REG_SZ    $newGuid"
        return $true
    }
    catch {
        Write-Host "$RED[错误]$NC 注册表操作失败：$($_.Exception.Message)"
        
        # 尝试恢复备份（如果存在）
        if (($backupFile -ne $null) -and (Test-Path $backupFile)) {
            Write-Host "$YELLOW[恢复]$NC 正在从备份恢复..."
            $restoreResult = Start-Process "reg.exe" -ArgumentList "import", "`"$backupFile`"" -NoNewWindow -Wait -PassThru
            
            if ($restoreResult.ExitCode -eq 0) {
                Write-Host "$GREEN[恢复成功]$NC 已还原原始注册表值"
            } else {
                Write-Host "$RED[错误]$NC 恢复失败，请手动导入备份文件：$backupFile"
            }
        } else {
            Write-Host "$YELLOW[警告]$NC 未找到备份文件或备份创建失败，无法自动恢复"
        }
        return $false
    }
}

# 创建或更新配置文件
Write-Host "$GREEN[信息]$NC 正在更新配置..."

try {
    # 检查配置文件是否存在
    if (-not (Test-Path $STORAGE_FILE)) {
        Write-Host "$RED[错误]$NC 未找到配置文件: $STORAGE_FILE"
        Write-Host "$YELLOW[提示]$NC 请先安装并运行一次 Cursor 后再使用此脚本"
        Read-Host "按回车键退出"
        exit 1
    }

    # 读取现有配置文件
    try {
        $originalContent = Get-Content $STORAGE_FILE -Raw -Encoding UTF8
        
        # 将 JSON 字符串转换为 PowerShell 对象
        $config = $originalContent | ConvertFrom-Json 

        # 备份当前值
        $oldValues = @{
            'machineId' = $config.'telemetry.machineId'
            'macMachineId' = $config.'telemetry.macMachineId'
            'devDeviceId' = $config.'telemetry.devDeviceId'
            'sqmId' = $config.'telemetry.sqmId'
        }

        # 更新特定的值
        $config.'telemetry.machineId' = $MACHINE_ID
        $config.'telemetry.macMachineId' = $MAC_MACHINE_ID
        $config.'telemetry.devDeviceId' = $UUID
        $config.'telemetry.sqmId' = $SQM_ID

        # 将更新后的对象转换回 JSON 并保存
        $updatedJson = $config | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText(
            [System.IO.Path]::GetFullPath($STORAGE_FILE), 
            $updatedJson, 
            [System.Text.Encoding]::UTF8
        )
        Write-Host "$GREEN[信息]$NC 成功更新配置文件"
    } catch {
        # 如果出错，尝试恢复原始内容
        if ($originalContent) {
            [System.IO.File]::WriteAllText(
                [System.IO.Path]::GetFullPath($STORAGE_FILE), 
                $originalContent, 
                [System.Text.Encoding]::UTF8
            )
        }
        throw "处理 JSON 失败: $_"
    }
    # 直接执行更新 MachineGuid，不再询问
    Update-MachineGuid
    # 显示结果
    Write-Host ""
    Write-Host "$GREEN[信息]$NC 已更新配置:"
    Write-Host "$BLUE[调试]$NC machineId: $MACHINE_ID"
    Write-Host "$BLUE[调试]$NC macMachineId: $MAC_MACHINE_ID"
    Write-Host "$BLUE[Отладка]$NC devDeviceId: $UUID"
    Write-Host "$BLUE[Отладка]$NC sqmId: $SQM_ID"

    # Отображение структуры файлов
    Write-Host ""
    Write-Host "$GREEN[Информация]$NC Структура файлов:"
    Write-Host ("$BLUE" + $env:APPDATA + "\Cursor\User$NC")
    Write-Host "├── globalStorage"
    Write-Host "│   ├── storage.json (изменён)"
    Write-Host "│   └── backups"

    # Список резервных копий
    $backupFiles = Get-ChildItem "$BACKUP_DIR\*" -ErrorAction SilentlyContinue
    if ($backupFiles) {
        foreach ($file in $backupFiles) {
            Write-Host "│       └── $($file.Name)"
        }
    } else {
        Write-Host "│       └── (пусто)"
    }

    # Информация о канале
    Write-Host ""
    Write-Host "$GREEN================================$NC"
    Write-Host "$YELLOW  Подпишитесь на канал «Блинчик с AI» и общайтесь по Cursor и AI (скрипт бесплатный, больше советов в чате канала)  $NC"
    Write-Host "$GREEN================================$NC"
    Write-Host ""
    Write-Host "$GREEN[Информация]$NC Пожалуйста, перезапустите Cursor для применения новых настроек"
    Write-Host ""

    # Вопрос о запрете автообновления
    Write-Host ""
    Write-Host "$YELLOW[Вопрос]$NC Отключить автоматическое обновление Cursor?"
    Write-Host "0) Нет - оставить по умолчанию (Enter)"
    Write-Host "1) Да - отключить обновление"
    $choice = Read-Host "Введите вариант (0)"

    if ($choice -eq "1") {
        Write-Host ""
        Write-Host "$GREEN[Информация]$NC Обработка автоматического обновления..."
        $updaterPath = "$env:LOCALAPPDATA\cursor-updater"

        # Инструкция по ручной настройке
        function Show-ManualGuide {
            Write-Host ""
            Write-Host "$YELLOW[Предупреждение]$NC Автоматическая настройка не удалась, попробуйте вручную:"
            Write-Host "$YELLOWШаги для ручного отключения обновлений:$NC"
            Write-Host "1. Откройте PowerShell от имени администратора"
            Write-Host "2. Вставьте и выполните команды:"
            Write-Host "$BLUEКоманда 1 - удалить директорию (если есть):$NC"
            Write-Host "Remove-Item -Path `"$updaterPath`" -Force -Recurse -ErrorAction SilentlyContinue"
            Write-Host ""
            Write-Host "$BLUEКоманда 2 - создать файл-блокировщик:$NC"
            Write-Host "New-Item -Path `"$updaterPath`" -ItemType File -Force | Out-Null"
            Write-Host ""
            Write-Host "$BLUEКоманда 3 - установить только для чтения:$NC"
            Write-Host "Set-ItemProperty -Path `"$updaterPath`" -Name IsReadOnly -Value `$true"
            Write-Host ""
            Write-Host "$BLUEКоманда 4 - настроить права (опционально):$NC"
            Write-Host "icacls `"$updaterPath`" /inheritance:r /grant:r `"`$($env:USERNAME):(R)`""
            Write-Host ""
            Write-Host "$YELLOWПроверка:$NC"
            Write-Host "1. Get-ItemProperty `"$updaterPath`""
            Write-Host "2. Убедитесь, что IsReadOnly = True"
            Write-Host "3. icacls `"$updaterPath`""
            Write-Host "4. Только права на чтение"
            Write-Host ""
            Write-Host "$YELLOW[Подсказка]$NC После завершения перезапустите Cursor"
        }

        try {
            # Проверка существования cursor-updater
            if (Test-Path $updaterPath) {
                # Если файл — блокировка уже создана
                if ((Get-Item $updaterPath) -is [System.IO.FileInfo]) {
                    Write-Host "$GREEN[Информация]$NC Файл-блокировщик уже создан, повторное создание не требуется"
                    return
                }
                # Если директория — пробуем удалить
                else {
                    try {
                        Remove-Item -Path $updaterPath -Force -Recurse -ErrorAction Stop
                        Write-Host "$GREEN[Информация]$NC Директория cursor-updater успешно удалена"
                    }
                    catch {
                        Write-Host "$RED[Ошибка]$NC Не удалось удалить директорию cursor-updater"
                        Show-ManualGuide
                        return
                    }
                }
            }

            # Создание файла-блокировщика
            try {
                New-Item -Path $updaterPath -ItemType File -Force -ErrorAction Stop | Out-Null
                Write-Host "$GREEN[Информация]$NC Файл-блокировщик успешно создан"
            }
            catch {
                Write-Host "$RED[Ошибка]$NC Не удалось создать файл-блокировщик"
                Show-ManualGuide
                return
            }

            # Настройка прав
            try {
                # Только для чтения
                Set-ItemProperty -Path $updaterPath -Name IsReadOnly -Value $true -ErrorAction Stop
                # icacls
                $result = Start-Process "icacls.exe" -ArgumentList "`"$updaterPath`" /inheritance:r /grant:r `"`$($env:USERNAME):(R)`"" -Wait -NoNewWindow -PassThru
                if ($result.ExitCode -ne 0) {
                    throw "icacls команда завершилась с ошибкой"
                }
                Write-Host "$GREEN[Информация]$NC Права доступа к файлу успешно установлены"
            }
            catch {
                Write-Host "$RED[Ошибка]$NC Не удалось установить права доступа к файлу"
                Show-ManualGuide
                return
            }

            # Проверка
            try {
                $fileInfo = Get-ItemProperty $updaterPath
                if (-not $fileInfo.IsReadOnly) {
                    Write-Host "$RED[Ошибка]$NC Ошибка проверки: возможно, права доступа к файлу не применились"
                    Show-ManualGuide
                    return
                }
            }
            catch {
                Write-Host "$RED[Ошибка]$NC Не удалось проверить настройки"
                Show-ManualGuide
                return
            }

            Write-Host "$GREEN[Информация]$NC Автоматическое обновление успешно отключено"
        }
        catch {
            Write-Host "$RED[Ошибка]$NC Произошла неизвестная ошибка: $_"
            Show-ManualGuide
        }
    }
    else {
        Write-Host "$GREEN[Информация]$NC Оставить настройки по умолчанию, не изменять"
    }

    # Сохраняем изменения в реестре
    Update-MachineGuid

} catch {
    Write-Host "$RED[Ошибка]$NC Основная операция завершилась с ошибкой: $_"
    Write-Host "$YELLOW[Попытка]$NC Использую альтернативный способ..."
    try {
        # Альтернативный способ: Add-Content
        $tempFile = [System.IO.Path]::GetTempFileName()
        $config | ConvertTo-Json | Set-Content -Path $tempFile -Encoding UTF8
        Copy-Item -Path $tempFile -Destination $STORAGE_FILE -Force
        Remove-Item -Path $tempFile
        Write-Host "$GREEN[Информация]$NC Альтернативный способ записи конфигурации выполнен успешно"
    } catch {
        Write-Host "$RED[Ошибка]$NC Все попытки не удались"
        Write-Host "Подробности ошибки: $_"
        Write-Host "Целевой файл: $STORAGE_FILE"
        Write-Host "Убедитесь, что у вас достаточно прав для доступа к этому файлу"
        Read-Host "Нажмите Enter для выхода"
        exit 1
    }
}

Write-Host ""
Read-Host "Нажмите Enter для выхода"
exit 0

# Функция для записи конфигурации
function Write-ConfigFile {
    param($config, $filePath)
    try {
        # Используем UTF8 без BOM
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        $jsonContent = $config | ConvertTo-Json -Depth 10
        # LF вместо CRLF
        $jsonContent = $jsonContent.Replace("`r`n", "`n")
        [System.IO.File]::WriteAllText(
            [System.IO.Path]::GetFullPath($filePath),
            $jsonContent,
            $utf8NoBom
        )
        Write-Host "$GREEN[Информация]$NC Конфигурационный файл успешно записан (UTF8 без BOM)"
    }
    catch {
        throw "Не удалось записать конфигурационный файл: $_"
    }
} 
