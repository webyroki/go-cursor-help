# Устанавливаем вывод в UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Определение цветов
[string]$RED = "`e[31m"
[string]$GREEN = "`e[32m"
[string]$YELLOW = "`e[33m"
[string]$BLUE = "`e[34m"
[string]$NC = "`e[0m"

# Пути к файлам конфигурации
$STORAGE_FILE = Join-Path $env:APPDATA "Cursor\User\globalStorage\storage.json"
$BACKUP_DIR = Join-Path $env:APPDATA "Cursor\User\globalStorage\backups"

# Функция инициализации Cursor (очистка)
function Cursor-Инициализация {
    [CmdletBinding()]
    param()
    
    BEGIN {
        Write-Information "$GREEN[Информация]$NC Выполняется инициализация и очистка Cursor..."
        $BASE_PATH = Join-Path $env:APPDATA "Cursor\User"

        $filesToDelete = @(
            (Join-Path -Path $BASE_PATH -ChildPath "globalStorage\state.vscdb"),
            (Join-Path -Path $BASE_PATH -ChildPath "globalStorage\state.vscdb.backup")
        )
        
        $folderToCleanContents = Join-Path -Path $BASE_PATH -ChildPath "History"
        $folderToDeleteCompletely = Join-Path -Path $BASE_PATH -ChildPath "workspaceStorage"

        Write-Information "$BLUE[Отладка]$NC Базовый путь: $($BASE_PATH)"
    }

    PROCESS {
        # Удаление указанных файлов
        foreach ($file in $filesToDelete) {
            Write-Information "$BLUE[Отладка]$NC Проверка файла: $($file)"
            if (Test-Path -Path $file) {
                try {
                    Remove-Item -Path $file -Force -ErrorAction Stop
                    Write-Information "$GREEN[Успех]$NC Файл удалён: $($file)"
                }
                catch {
                    Write-Warning "$RED[Ошибка]$NC Не удалось удалить файл $($file): $($_.Exception.Message)"
                }
            } else {
                Write-Warning "$YELLOW[Предупреждение]$NC Файл не найден, пропуск: $($file)"
            }
        }

        # Очистка содержимого папки
        Write-Information "$BLUE[Отладка]$NC Проверка папки для очистки: $($folderToCleanContents)"
        if (Test-Path -Path $folderToCleanContents) {
            try {
                Get-ChildItem -Path $folderToCleanContents -Recurse | 
                    Remove-Item -Recurse -Force -ErrorAction Stop
                Write-Information "$GREEN[Успех]$NC Содержимое папки очищено: $($folderToCleanContents)"
            }
            catch {
                Write-Warning "$RED[Ошибка]$NC Не удалось очистить папку $($folderToCleanContents): $($_.Exception.Message)"
            }
        } else {
            Write-Warning "$YELLOW[Предупреждение]$NC Папка не найдена, пропуск очистки: $($folderToCleanContents)"
        }

        # Удаление папки полностью
        Write-Information "$BLUE[Отладка]$NC Проверка папки для удаления: $($folderToDeleteCompletely)"
        if (Test-Path -Path $folderToDeleteCompletely) {
            try {
                Remove-Item -Path $folderToDeleteCompletely -Recurse -Force -ErrorAction Stop
                Write-Information "$GREEN[Успех]$NC Папка удалена: $($folderToDeleteCompletely)"
            }
            catch {
                Write-Warning "$RED[Ошибка]$NC Не удалось удалить папку $($folderToDeleteCompletely): $($_.Exception.Message)"
            }
        } else {
            Write-Warning "$YELLOW[Предупреждение]$NC Папка не найдена, пропуск удаления: $($folderToDeleteCompletely)"
        }
    }

    END {
        Write-Information "$GREEN[Информация]$NC Инициализация и очистка Cursor завершена."
        Write-Information "" # Пустая строка для форматирования
    }
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

# Получение версии Cursor
function Get-CursorVersion {
    [CmdletBinding()]
    param()

    BEGIN {
        $mainPath = Join-Path $env:LOCALAPPDATA "Programs\cursor\resources\app\package.json"
        $altPath = Join-Path $env:LOCALAPPDATA "cursor\resources\app\package.json"
    }

    PROCESS {
        try {
            foreach ($packagePath in @($mainPath, $altPath)) {
                if (Test-Path -Path $packagePath) {
                    $packageJson = Get-Content -Path $packagePath -Raw | ConvertFrom-Json
                    if ($packageJson.version) {
                        Write-Information "$GREEN[Информация]$NC Текущая установленная версия Cursor: v$($packageJson.version)"
                        return $packageJson.version
                    }
                }
            }

            Write-Warning "$YELLOW[Предупреждение]$NC Не удалось определить версию Cursor"
            Write-Warning "$YELLOW[Подсказка]$NC Убедитесь, что Cursor установлен правильно"
            return $null
        }
        catch {
            Write-Error "$RED[Ошибка]$NC Получение версии Cursor не удалось: $_"
            return $null
        }
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ProcessName
    )

    PROCESS {
        Write-Information "$BLUE[Отладка]$NC Получение информации о процессе $ProcessName"
        Get-WmiObject -Class Win32_Process -Filter "name='$ProcessName'" | 
            Select-Object -Property ProcessId, ExecutablePath, CommandLine | 
            Format-List
    }
}

# Определение максимального количества попыток и времени ожидания
[int]$MAX_RETRIES = 5
[int]$WAIT_TIME = 1

function Close-CursorProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ProcessName
    )

    BEGIN {
        $retryCount = 0
    }

    PROCESS {
        $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        
        if ($process) {
            Write-Warning "$YELLOW[Предупреждение]$NC Обнаружен процесс $ProcessName"
            Get-ProcessDetails -ProcessName $ProcessName
            
            Write-Warning "$YELLOW[Предупреждение]$NC Попытка завершения процесса $ProcessName..."
            Stop-Process -Name $ProcessName -Force
            
            while ($retryCount -lt $MAX_RETRIES) {
                $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
                if (-not $process) { 
                    Write-Information "$GREEN[Информация]$NC Процесс $ProcessName успешно завершен"
                    break 
                }
                
                $retryCount++
                if ($retryCount -ge $MAX_RETRIES) {
                    Write-Error "$RED[Ошибка]$NC Не удалось завершить процесс $ProcessName после $MAX_RETRIES попыток"
                    Get-ProcessDetails -ProcessName $ProcessName
                    Write-Error "$RED[Ошибка]$NC Пожалуйста, завершите процесс вручную и повторите попытку"
                    Read-Host "Нажмите Enter для выхода"
                    exit 1
                }
                
                Write-Warning "$YELLOW[Предупреждение]$NC Ожидание завершения процесса, попытка $retryCount/$MAX_RETRIES..."
                Start-Sleep -Seconds $WAIT_TIME
            }
        }
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
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateRange(1, 1024)]
        [int]$Length
    )

    PROCESS {
        try {
            $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
            try {
                $bytes = New-Object byte[] ($Length)
                $rng.GetBytes($bytes)
                return [System.BitConverter]::ToString($bytes) -replace '-',''
            }
            catch {
                Write-Error "Ошибка генерации случайных данных: $_"
                return $null
            }
            finally {
                if ($rng) {
                    $rng.Dispose()
                }
            }
        }
        catch {
            Write-Error "Ошибка создания генератора случайных чисел: $_"
            return $null
        }
    }
}

# 改进 ID 生成函数
function New-StandardMachineId {
    [CmdletBinding()]
    param()

    BEGIN {
        $template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
        $guidRegex = '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
    }

    PROCESS {
        try {
            $result = $template -replace '[xy]', {
                param($match)
                $r = [Random]::new().Next(16)
                $v = if ($match.Value -eq "x") { $r } else { ($r -band 0x3) -bor 0x8 }
                return $v.ToString("x")
            }

            # Проверка валидности сгенерированного GUID
            if ($result -match $guidRegex) {
                return $result
            } else {
                throw "Сгенерированный ID не соответствует формату GUID"
            }
        }
        catch {
            Write-Error "Ошибка генерации Machine ID: $_"
            return $null
        }
    }
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
    [CmdletBinding()]
    param()

    BEGIN {
        $registryPath = "HKLM:\SOFTWARE\Microsoft\Cryptography"
        $backupFile = $null
        $originalGuid = $null
    }

    PROCESS {
        try {
            # Проверка существования пути реестра
            if (-not (Test-Path -Path $registryPath)) {
                Write-Warning "$YELLOW[Предупреждение]$NC Путь реестра не существует: $registryPath"
                New-Item -Path $registryPath -Force | Out-Null
                Write-Information "$GREEN[Информация]$NC Путь реестра успешно создан"
            }

            # Получение текущего значения
            try {
                $currentGuid = Get-ItemProperty -Path $registryPath -Name MachineGuid -ErrorAction SilentlyContinue
                if ($currentGuid) {
                    $originalGuid = $currentGuid.MachineGuid
                    Write-Information "$GREEN[Информация]$NC Текущее значение реестра:"
                    Write-Information "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography"
                    Write-Information "    MachineGuid    REG_SZ    $originalGuid"
                }
            }
            catch {
                Write-Warning "$YELLOW[Предупреждение]$NC Не удалось получить текущее значение MachineGuid: $($_.Exception.Message)"
            }

            # Создание резервной копии
            if ($originalGuid) {
                if (-not (Test-Path -Path $BACKUP_DIR)) {
                    New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
                }

                $backupFile = Join-Path $BACKUP_DIR "MachineGuid_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
                $backupResult = Start-Process -FilePath "reg.exe" `
                    -ArgumentList "export", "`"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography`"", "`"$backupFile`"" `
                    -NoNewWindow -Wait -PassThru
                
                if ($backupResult.ExitCode -eq 0) {
                    Write-Information "$GREEN[Информация]$NC Резервная копия создана: $backupFile"
                }
                else {
                    Write-Warning "$YELLOW[Предупреждение]$NC Не удалось создать резервную копию"
                }
            }

            # Генерация и установка нового GUID
            $newGuid = [System.Guid]::NewGuid().ToString()
            Set-ItemProperty -Path $registryPath -Name MachineGuid -Value $newGuid -Force -ErrorAction Stop

            # Проверка обновления
            $verifyGuid = (Get-ItemProperty -Path $registryPath -Name MachineGuid -ErrorAction Stop).MachineGuid
            if ($verifyGuid -ne $newGuid) {
                throw "Ошибка проверки: обновленное значение ($verifyGuid) не соответствует ожидаемому ($newGuid)"
            }

            Write-Information "$GREEN[Информация]$NC Реестр успешно обновлен:"
            Write-Information "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography"
            Write-Information "    MachineGuid    REG_SZ    $newGuid"
            return $true
        }
        catch {
            Write-Error "$RED[Ошибка]$NC Операция с реестром не удалась: $($_.Exception.Message)"
            
            if ($backupFile -and (Test-Path -Path $backupFile)) {
                Write-Warning "$YELLOW[Восстановление]$NC Попытка восстановления из резервной копии..."
                $restoreResult = Start-Process -FilePath "reg.exe" `
                    -ArgumentList "import", "`"$backupFile`"" `
                    -NoNewWindow -Wait -PassThru
                
                if ($restoreResult.ExitCode -eq 0) {
                    Write-Information "$GREEN[Успех]$NC Восстановлено исходное значение"
                }
                else {
                    Write-Error "$RED[Ошибка]$NC Восстановление не удалось. Файл резервной копии: $backupFile"
                }
            }
            else {
                Write-Warning "$YELLOW[Предупреждение]$NC Резервная копия не найдена, автоматическое восстановление невозможно"
            }
            return $false
        }
    }
}

function Update-CursorConfig {
    [CmdletBinding()]
    param()

    BEGIN {
        Write-Information "$GREEN[Информация]$NC Обновление конфигурации..."
    }

    PROCESS {
        try {
            # Проверка существования файла
            if (-not (Test-Path -Path $STORAGE_FILE)) {
                Write-Error "$RED[Ошибка]$NC Файл конфигурации не найден: $STORAGE_FILE"
                Write-Warning "$YELLOW[Подсказка]$NC Установите и запустите Cursor хотя бы один раз"
                return $false
            }

            # Чтение и обновление конфигурации
            try {
                $originalContent = Get-Content -Path $STORAGE_FILE -Raw -Encoding UTF8
                $config = $originalContent | ConvertFrom-Json

                # Сохранение текущих значений
                $oldValues = @{
                    'machineId' = $config.'telemetry.machineId'
                    'macMachineId' = $config.'telemetry.macMachineId'
                    'devDeviceId' = $config.'telemetry.devDeviceId'
                    'sqmId' = $config.'telemetry.sqmId'
                }

                # Обновление значений
                $config.'telemetry.machineId' = $MACHINE_ID
                $config.'telemetry.macMachineId' = $MAC_MACHINE_ID
                $config.'telemetry.devDeviceId' = $UUID
                $config.'telemetry.sqmId' = $SQM_ID

                # Сохранение обновленной конфигурации
                $updatedJson = $config | ConvertTo-Json -Depth 10
                [System.IO.File]::WriteAllText(
                    [System.IO.Path]::GetFullPath($STORAGE_FILE),
                    $updatedJson,
                    [System.Text.Encoding]::UTF8
                )

                Write-Information "$GREEN[Информация]$NC Конфигурация успешно обновлена"
                return $true
            }
            catch {
                if ($originalContent) {
                    [System.IO.File]::WriteAllText(
                        [System.IO.Path]::GetFullPath($STORAGE_FILE),
                        $originalContent,
                        [System.Text.Encoding]::UTF8
                    )
                }
                throw "Ошибка обработки JSON: $_"
            }
        }
        catch {
            Write-Error "$RED[Ошибка]$NC Не удалось обновить конфигурацию: $_"
            return $false
        }
    }

    END {
        # Вывод результатов
        Write-Information ""
        Write-Information "$GREEN[Информация]$NC Обновленные значения:"
        Write-Information "$BLUE[Отладка]$NC machineId: $MACHINE_ID"
        Write-Information "$BLUE[Отладка]$NC macMachineId: $MAC_MACHINE_ID"
        Write-Information "$BLUE[Отладка]$NC devDeviceId: $UUID"
        Write-Information "$BLUE[Отладка]$NC sqmId: $SQM_ID"

        # Структура файлов
        Write-Information ""
        Write-Information "$GREEN[Информация]$NC Структура файлов:"
        Write-Information "$BLUE${env:APPDATA}\Cursor\User$NC"
        Write-Information "├── globalStorage"
        Write-Information "│   ├── storage.json (изменён)"
        Write-Information "│   └── backups"

        # Список резервных копий
        $backupFiles = Get-ChildItem -Path "$BACKUP_DIR\*" -ErrorAction SilentlyContinue
        if ($backupFiles) {
            foreach ($file in $backupFiles) {
                Write-Information "│       └── $($file.Name)"
            }
        }
        else {
            Write-Information "│       └── (пусто)"
        }
    }
}

function Disable-CursorAutoUpdate {
    [CmdletBinding()]
    param()

    BEGIN {
        $updaterPath = Join-Path $env:LOCALAPPDATA "cursor-updater"
    }

    PROCESS {
        try {
            # Проверка существования файла/директории
            if (Test-Path -Path $updaterPath) {
                $item = Get-Item -Path $updaterPath
                if ($item -is [System.IO.FileInfo]) {
                    Write-Information "$GREEN[Информация]$NC Файл-блокировщик уже существует"
                    return $true
                }
                else {
                    Remove-Item -Path $updaterPath -Force -Recurse -ErrorAction Stop
                    Write-Information "$GREEN[Информация]$NC Директория cursor-updater удалена"
                }
            }

            # Создание файла-блокировщика
            New-Item -Path $updaterPath -ItemType File -Force -ErrorAction Stop | Out-Null
            Set-ItemProperty -Path $updaterPath -Name IsReadOnly -Value $true -ErrorAction Stop

            # Настройка прав доступа
            $result = Start-Process -FilePath "icacls.exe" `
                -ArgumentList "`"$updaterPath`" /inheritance:r /grant:r `"`$($env:USERNAME):(R)`"" `
                -NoNewWindow -Wait -PassThru

            if ($result.ExitCode -eq 0) {
                Write-Information "$GREEN[Информация]$NC Автообновление успешно отключено"
                return $true
            }
            else {
                throw "Ошибка выполнения команды icacls"
            }
        }
        catch {
            Write-Error "$RED[Ошибка]$NC Не удалось отключить автообновление: $_"
            Show-ManualUpdateDisableGuide
            return $false
        }
    }
}

function Show-ManualUpdateDisableGuide {
    [CmdletBinding()]
    param()

    PROCESS {
        $updaterPath = Join-Path $env:LOCALAPPDATA "cursor-updater"

        Write-Warning ""
        Write-Warning "$YELLOW[Предупреждение]$NC Автоматическая настройка не удалась. Выполните следующие шаги вручную:"
        Write-Warning "$YELLOW[Инструкция]$NC Шаги для ручного отключения обновлений:"
        Write-Information "1. Откройте PowerShell от имени администратора"
        Write-Information "2. Выполните следующие команды:"
        Write-Information "$BLUE[Команда 1]$NC Удаление директории (если существует):"
        Write-Information "Remove-Item -Path `"$updaterPath`" -Force -Recurse -ErrorAction SilentlyContinue"
        Write-Information ""
        Write-Information "$BLUE[Команда 2]$NC Создание файла-блокировщика:"
        Write-Information "New-Item -Path `"$updaterPath`" -ItemType File -Force | Out-Null"
        Write-Information ""
        Write-Information "$BLUE[Команда 3]$NC Установка атрибута 'только для чтения':"
        Write-Information "Set-ItemProperty -Path `"$updaterPath`" -Name IsReadOnly -Value `$true"
        Write-Information ""
        Write-Information "$BLUE[Команда 4]$NC Настройка прав доступа:"
        Write-Information "icacls `"$updaterPath`" /inheritance:r /grant:r `"`$($env:USERNAME):(R)`""
        Write-Information ""
        Write-Information "$YELLOW[Проверка]$NC"
        Write-Information "1. Get-ItemProperty `"$updaterPath`""
        Write-Information "2. Проверьте IsReadOnly = True"
        Write-Information "3. icacls `"$updaterPath`""
        Write-Information "4. Убедитесь, что установлены только права на чтение"
        Write-Information ""
        Write-Information "$YELLOW[Подсказка]$NC После выполнения всех шагов перезапустите Cursor"
    }
}

# Основной блок скрипта
try {
    # Обновление конфигурации
    if (-not (Update-CursorConfig)) {
        exit 1
    }

    # Обновление MachineGuid
    if (-not (Update-MachineGuid)) {
        exit 1
    }

    # Информация о канале
    Write-Host ""
    Write-Host "$GREEN================================$NC"
    Write-Host "$YELLOW  Подпишитесь на канал «Блинчик с AI» и общайтесь по Cursor и AI (скрипт бесплатный, больше советов в чате канала)  $NC"
    Write-Host "$GREEN================================$NC"
    Write-Host ""
    Write-Host "$GREEN[Информация]$NC Пожалуйста, перезапустите Cursor для применения новых настроек"
    Write-Host ""

    # Запрос на отключение автообновления
    Write-Host ""
    Write-Host "$YELLOW[Вопрос]$NC Отключить автоматическое обновление Cursor?"
    Write-Host "0) Нет - оставить по умолчанию (Enter)"
    Write-Host "1) Да - отключить обновление"
    $choice = Read-Host "Введите вариант (0)"

    if ($choice -eq "1") {
        Write-Host ""
        Write-Host "$GREEN[Информация]$NC Обработка автоматического обновления..."
        if (-not (Disable-CursorAutoUpdate)) {
            exit 1
        }
    }
    else {
        Write-Information "$GREEN[Информация]$NC Настройки автообновления оставлены без изменений"
    }
}
catch {
    Write-Error "$RED[Ошибка]$NC Необработанная ошибка: $_"
    exit 1
}
finally {
    Write-Host ""
    Read-Host "Нажмите Enter для выхода"
}

function Write-ConfigFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [PSObject]$Config,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$FilePath
    )

    BEGIN {
        # Создаем кодировку UTF8 без BOM
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    }

    PROCESS {
        try {
            # Преобразуем конфигурацию в JSON
            $jsonContent = $Config | ConvertTo-Json -Depth 10

            # Заменяем CRLF на LF для совместимости
            $jsonContent = $jsonContent.Replace("`r`n", "`n")

            # Получаем полный путь к файлу
            $fullPath = [System.IO.Path]::GetFullPath($FilePath)

            # Создаем директорию, если не существует
            $directory = [System.IO.Path]::GetDirectoryName($fullPath)
            if (-not (Test-Path -Path $directory)) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
                Write-Information "$GREEN[Информация]$NC Создана директория: $directory"
            }

            # Записываем файл
            [System.IO.File]::WriteAllText($fullPath, $jsonContent, $utf8NoBom)
            Write-Information "$GREEN[Информация]$NC Конфигурационный файл успешно записан: $fullPath"
            Write-Information "$BLUE[Отладка]$NC Использована кодировка: UTF8 без BOM"
            return $true
        }
        catch {
            Write-Error "$RED[Ошибка]$NC Не удалось записать конфигурационный файл: $_"
            return $false
        }
    }
} 
