Using Namespace Raleose.Network.Checker
$networkChecker = [NetworkChecker]::new("188.32.15.", 1, 255)
$networkChecker.Check()

Class NetworkChecker{
    
    NetworkChecker([string] $networkPrefix, [byte] $minInclusiveByte, [byte] $maxInclusiveByte){
        $this.networkPrefix = $networkPrefix
        $this.minInclusiveByte = $minInclusiveByte
        $this.maxInclusiveByte = $maxInclusiveByte
    }
    
    #количество запросов на один адрес
    [int] $requestsQuantity = 1
    #тайм-аут на проверку одного адреса
    [int] $waitTimeoutMillis = 500
    #префикс сети
    [string] $networkPrefix
    #начальное значение четвертого байта (включающее)
    [int] $minInclusiveByte
    #конечное значение четвертого байта (включающее)
    [int] $maxInclusiveByte
    #сюда будут сохранены объекты IpInfo
    [IpInfo[]] $ipList = @()

    Check(){
        $adressesCount = $this.maxInclusiveByte - $this.minInclusiveByte - 2
        $maxTimeForScan = $adressesCount * $this.waitTimeoutMillis / 1000
        
        $this.Log("Идет сканирование...")
        $this.Log("Будет просканировано $($adressesCount) адресов")
        $this.Log("Сканирование займет $($maxTimeForScan) сек. максимум")
        
        for($n = $this.minInclusiveByte; $n -clt $this.maxInclusiveByte; $n++){
        
            $adress = "$($this.networkPrefix)$($n)"
            $ping = ping $adress -n $this.requestsQuantity -w $this.waitTimeoutMillis
            $isAdressExist = $ping[2].Contains("TTL=")
        
            if($isAdressExist){
                
                $ipName = (nslookup $adress).Get(3).Replace("Name:    ", "")
                $ipInfo = [IpInfo]::new($ipName, $adress)
                $this.Log("Найден адрес! $($ipInfo.ToString())")
                $this.ipList += $ipInfo
            }
        }
        
        $this.Log("Сеть просканирована...")
        if(!($this.ipList.Count -eq 0)){
            $this.Log("Найдено $($this.ipList.Count) адресов")
        }
        else{
            $this.Log("На эхо-запрос никто не откликнулся...")
        }
    }

    Log([string] $message){
        Write-Host $message
    }

}