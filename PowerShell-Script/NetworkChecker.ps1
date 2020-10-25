Class Test{
    static Main(){
        $networkChecker = [NetworkChecker]::new("1.1.1.", 1, 255)
        $networkChecker.Check()
    }
}

Class NetworkChecker{
    
    NetworkChecker([string] $networkPrefix, [byte] $minInclusiveByte, [byte] $maxInclusiveByte){
        $this.networkPrefix = $networkPrefix
        $this.minInclusiveByte = $minInclusiveByte
        $this.maxInclusiveByte = $maxInclusiveByte
        $this.ipList = @()
        $this.checker = [CheckerICMP]::new(1, 500)
    }
    
    
    #префикс сети
    [string] $networkPrefix
    #начальное значение четвертого байта (включающее)
    [int] $minInclusiveByte
    #конечное значение четвертого байта (включающее)
    [int] $maxInclusiveByte
    #сюда будут сохранены объекты IpInfo
    [IpInfo[]] $ipList
    #Проверка по Эхо-запросу
    [CheckerICMP] $checker

    Check(){
        $adressesCount = $this.maxInclusiveByte - $this.minInclusiveByte
        $maxTimeForScan = $adressesCount * $this.checker.waitTimeoutMillis / 1000
        
        $this.Log("Идет сканирование...")
        $this.Log("Будет просканировано $($adressesCount) адресов")
        $this.Log("Сканирование займет $($maxTimeForScan) сек. максимум")
        
        for($n = $this.minInclusiveByte; $n -clt $this.maxInclusiveByte; $n++){
        
            $adress = "$($this.networkPrefix)$($n)"
        
            if($this.checker.IsExists($adress)){
                
                $ipName = [IpInfo]::GetName($adress)
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

#Класс, который отправляет ICMP-пакет на удаленный адрес
Class CheckerICMP{

    CheckerICMP([int] $requestsQuantity, [int] $waitTimeoutMillis){
        $this.requestsQuantity = $requestsQuantity
        $this.waitTimeoutMillis = $waitTimeoutMillis
    }

    #количество запросов на один адрес
    [int] $requestsQuantity = 1
    #тайм-аут на проверку одного адреса
    [int] $waitTimeoutMillis = 500


    [bool] IsExists([string] $ip){
        return (ping $ip -n $this.requestsQuantity -w $this.waitTimeoutMillis)[2].Contains("TTL=")
    }
}

#Класс, хранящий в себе сопоставление IP-адреса и его NetBIOS-имени
Class IpInfo{
    IpInfo([string] $name, [string] $address){
        $this.Name = $name
        $this.Address = $address
    }

    [string] $Name
    [string] $Address
             
    [string] Tostring(){
        return "$($this.Address): $($this.Name)"
    }

    static [string] GetName([string] $ipAddress){
        $ipName = ""
        try{
            $ipName = (nslookup $ipAddress).Get(3).Replace("Name:    ", "")
        }
        catch{
            $ipName = "Unknown..."
        }
        return $ipName
    }
}

[Test]::Main();