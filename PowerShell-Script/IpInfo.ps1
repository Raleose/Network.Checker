
Namespace Raleose.Network.Checker{

    #Класс, хранящий в себе сопоставление IP-адреса и его NetBIOS-имени
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
}