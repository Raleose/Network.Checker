chcp 65001

#количество запросов на один адрес
$requestsQuantity = 1
#тайм-аут на проверку одного адреса
$waitTimeoutMillis = 500
#префикс сети
$networkPrefix = "188.32.15."
#начальное значение четвертого байта (исключенный)
$minExclusiveByte = 0
#конечное значение четвертого байта (исключенный)
$maxExclusiveByte = 256
#сюда будут сохранены объекты IpInfo
$ipList = @()

$adressesCount = $maxExclusiveByte - $minExclusiveByte - 2
$maxTimeForScan = $adressesCount * $waitTimeoutMillis / 1000

echo "Идет сканирование..."
echo "Будет просканировано $($adressesCount) адресов"
echo "Сканирование займет $($maxTimeForScan) сек. максимум"

for($n = $minExclusiveByte; $n -clt $maxExclusiveByte; $n++){

    $adress = "$($networkPrefix)$($n)"
    $ping = ping $adress -n $requestsQuantity -w $waitTimeoutMillis
    $isAdressExist = $ping[2].Contains("TTL=")

    if($isAdressExist){
        
        $ipName = (nslookup $adress).Get(3).Replace("Name:    ", "")
        $ipInfo = [IpInfo]::new($ipName, $adress)
        echo "Найден адрес! $($ipInfo.ToString())"
        $ipList += $ipInfo
    }
}

echo "Сеть просканирована..."
if(!($ipList.Count -eq 0)){
    echo "Найдено $($ipList.Count) адресов"
}
else{
    echo "На эхо-запрос никто не откликнулся..."
}

Class IpInfo{
    IpInfo([String]$name, [String]$address){
        $this.Name = $name
        $this.Address = $address
    }
    [String]ToString(){
        return "$($this.Address): $($this.Name)"
    }

    [String]$Name
    [String]$Address
}