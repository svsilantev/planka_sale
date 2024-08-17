param (
    [String]$message
)
$botToken = "6833790298:AAEBgbEo5vMYochw_bsBcDwr1MBcXkrKNjY"
$chatID = "267638693"
$url = "https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatID&text=$message"

Invoke-WebRequest -Uri $url