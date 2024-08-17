param (
    [String]$message,
    [String]$soundPath = ""  # Опциональный параметр для указания пути к звуковому файлу
)

$botToken = "6833790298:AAEBgbEo5vMYochw_bsBcDwr1MBcXkrKNjY"
$chatID = "267638693"
$url = "https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatID&text=$message"

# Отправка сообщения в Telegram
Invoke-WebRequest -Uri $url

# Если указан путь к звуковому файлу, воспроизводим звук
if ($soundPath -ne "") {
    $player = New-Object System.Media.SoundPlayer
    $player.SoundLocation = $soundPath
    $player.PlaySync()  # Воспроизвести звук и дождаться окончания
}
