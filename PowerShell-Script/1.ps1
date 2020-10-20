chcp 65001

$myAdress = ipconfig
echo $myAdress | Where-Object { $_.Contains("   IPv4 Address") -and $myAdress.IndexOf($_) -gt $myAdress.IndexOf("Ethernet") }

$waitTimeoutMillis = 500
$minExclusiveByte = 0
$maxExclusiveByte = 256
$networkPreffix = "188.32.15."
$ipList = @()

$adressesCount = $maxExclusiveByte - $minExclusiveByte - 2
$maxTimeForScan = $adressesCount * $waitTimeoutMillis / 1000

echo "Идет сканирование..."
echo "Будет просканировано $($adressesCount) адресов"
echo "Сканирование займет $($maxTimeForScan) сек. максимум"

for($n = $minExclusiveByte; $n -clt $maxExclusiveByte; $n++){

    $adress = "$($networkPreffix)$($n)"
    $ping = ping $adress -n 1 -w $waitTimeoutMillis
    $isAdressExist = $ping[2].Contains("TTL=")

    if($isAdressExist){
        echo "Найден адрес! $($adress)"
        $ipList += $adress
    }
}

echo "Сеть просканирована..."
echo $ipList
if(!($ipList.Count -eq 0)){
    echo "Найдено $($ipList.Count) адресов"
}
else{
    echo "На эхо-запрос никто не откликнулся..."
}