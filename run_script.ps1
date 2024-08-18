param (
    [string]$logFilePath = "D:\YandexDisk\DropBox\Инвестиции\Биржевые\Роботы\Планка\Продать\log.txt"  # Значение по умолчанию
)

# Функция для URL-кодирования строки
function UrlEncode {
    param ([string]$text)
    [System.Uri]::EscapeDataString($text)
}

# Функция для отправки сообщений в Telegram
function Send-TelegramMessage {
    param (
        [String]$message
    )

    # Преобразование строки в UTF-8 и URL-кодирование
    $encodedMessage = UrlEncode $message
    
    $url = "https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatID&text=$encodedMessage"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
        Write-Host "Сообщение отправлено: $message"
    } catch {
        Write-Host "Не удалось отправить сообщение: $_"
    }
}

# Параметры
$botToken = "6833790298:AAEBgbEo5vMYochw_bsBcDwr1MBcXkrKNjY"
$chatID = "267638693"
$intervalSeconds = 60  # Интервал проверки в секундах

# Основной цикл
while ($true) {
    Write-Host "Проверка наличия файла лога по пути: $logFilePath..."
    
    if (Test-Path $logFilePath) {
        Write-Host "Файл лога найден. Чтение содержимого..."
        $logLines = Get-Content $logFilePath

        Write-Host "Количество строк в логе: $($logLines.Count)"
        
        # Отфильтровываем пустые строки и выбираем последнюю непустую строку
        $lastNonEmptyLine = $logLines | Where-Object { $_.Trim() -ne "" } | Select-Object -Last 1

        if ($lastNonEmptyLine) {
            Write-Host "Последняя непустая строка: '$lastNonEmptyLine'"

            # Извлекаем временную метку из строки
            $lastTimeStr = $lastNonEmptyLine -replace ' -.*$', ''
            Write-Host "Извлеченная временная метка: $lastTimeStr"
            
            try {
                $lastTime = [datetime]::ParseExact($lastTimeStr, "yyyy-MM-dd HH:mm:ss", $null)
                Write-Host "Распарсенная дата и время: $lastTime"
            } catch {
                Write-Host "Ошибка: Невозможно распарсить временную метку '$lastTimeStr'"
                Start-Sleep -Seconds $intervalSeconds
                continue
            }

            $currentTime = Get-Date
            Write-Host "Текущее время: $currentTime"
            
            # Проверка интервала времени
            if (($currentTime - $lastTime).TotalSeconds -gt ($intervalSeconds * 2)) {
                Write-Host "Интервал превышен, отправляем сообщение..."
                Send-TelegramMessage "Внимание! Больше двух минут нет записей в логе!"
            } else {
                Write-Host "Интервал не превышен, сообщение не отправлено."
            }
        } else {
            Write-Host "Файл лога пуст или содержит только пустые строки."
            Send-TelegramMessage "Log file is empty."
        }
    } else {
        Write-Host "Файл лога не найден."
        Send-TelegramMessage "Log file does not exist."
    }
    
    Write-Host "Ждем $intervalSeconds секунд перед следующей проверкой..."
    Start-Sleep -Seconds $intervalSeconds
}
