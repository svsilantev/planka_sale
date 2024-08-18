param (
    [string]$logFilePath = "D:\YandexDisk\DropBox\����������\��������\������\������\�������\log.txt"  # �������� �� ���������
)

# ������� ��� URL-����������� ������
function UrlEncode {
    param ([string]$text)
    [System.Uri]::EscapeDataString($text)
}

# ������� ��� �������� ��������� � Telegram
function Send-TelegramMessage {
    param (
        [String]$message
    )

    # �������������� ������ � UTF-8 � URL-�����������
    $encodedMessage = UrlEncode $message
    
    $url = "https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatID&text=$encodedMessage"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
        Write-Host "��������� ����������: $message"
    } catch {
        Write-Host "�� ������� ��������� ���������: $_"
    }
}

# ���������
$botToken = "6833790298:AAEBgbEo5vMYochw_bsBcDwr1MBcXkrKNjY"
$chatID = "267638693"
$intervalSeconds = 60  # �������� �������� � ��������

# �������� ����
while ($true) {
    Write-Host "�������� ������� ����� ���� �� ����: $logFilePath..."
    
    if (Test-Path $logFilePath) {
        Write-Host "���� ���� ������. ������ �����������..."
        $logLines = Get-Content $logFilePath

        Write-Host "���������� ����� � ����: $($logLines.Count)"
        
        # ��������������� ������ ������ � �������� ��������� �������� ������
        $lastNonEmptyLine = $logLines | Where-Object { $_.Trim() -ne "" } | Select-Object -Last 1

        if ($lastNonEmptyLine) {
            Write-Host "��������� �������� ������: '$lastNonEmptyLine'"

            # ��������� ��������� ����� �� ������
            $lastTimeStr = $lastNonEmptyLine -replace ' -.*$', ''
            Write-Host "����������� ��������� �����: $lastTimeStr"
            
            try {
                $lastTime = [datetime]::ParseExact($lastTimeStr, "yyyy-MM-dd HH:mm:ss", $null)
                Write-Host "������������ ���� � �����: $lastTime"
            } catch {
                Write-Host "������: ���������� ���������� ��������� ����� '$lastTimeStr'"
                Start-Sleep -Seconds $intervalSeconds
                continue
            }

            $currentTime = Get-Date
            Write-Host "������� �����: $currentTime"
            
            # �������� ��������� �������
            if (($currentTime - $lastTime).TotalSeconds -gt ($intervalSeconds * 2)) {
                Write-Host "�������� ��������, ���������� ���������..."
                Send-TelegramMessage "��������! ������ ���� ����� ��� ������� � ����!"
            } else {
                Write-Host "�������� �� ��������, ��������� �� ����������."
            }
        } else {
            Write-Host "���� ���� ���� ��� �������� ������ ������ ������."
            Send-TelegramMessage "Log file is empty."
        }
    } else {
        Write-Host "���� ���� �� ������."
        Send-TelegramMessage "Log file does not exist."
    }
    
    Write-Host "���� $intervalSeconds ������ ����� ��������� ���������..."
    Start-Sleep -Seconds $intervalSeconds
}
