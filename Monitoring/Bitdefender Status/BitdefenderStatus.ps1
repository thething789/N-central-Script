$wmierror = $null
$GetService = $null
$AV

$AVProduct = Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct -ErrorVariable wmierror -ErrorAction SilentlyContinue

#Comment if you want to user wmi
$wmierror = "Bypass"

if ($wmierror -ne $null) {
    $GetService = Get-Service -DisplayName "Bitdefender Endpoint*"
    if ($GetService -ne $null) {
        $AVName = "Antimalware Bitdefender Endpoint Security Tools"
        $AVUpdateStatus = "A jour / Info ne faisant pas foi"
        $AVProtection = "Activé / Info ne faisant pas foi"
    } else {
        $AVName = "Inconnu / Serveur"
        $AVUpdateStatus = "Inconnu"
        $AVProtection = "Inconnu"
}
} else {
    If (($AVProduct | Measure-Object).count -gt 1) {
    $AV = Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-object displayName -ne "Windows Defender" -ErrorVariable $error1
    } Else {
        $AV = $AVProduct
    }

    switch ($AV.productState) {
        "262144" {$UpdateStatus = "A jour" ;$RealTimeProtectionStatus = "Désactivé"}
        "262160" {$UpdateStatus = "Pas à jour" ;$RealTimeProtectionStatus = "Désactivé"}
        "266240" {$UpdateStatus = "A jour" ;$RealTimeProtectionStatus = "Activé"}
        "266256" {$UpdateStatus = "Pas à jour" ;$RealTimeProtectionStatus = "Activé"}
        "393216" {$UpdateStatus = "A jour" ;$RealTimeProtectionStatus = "Désactivé"}
        "393232" {$UpdateStatus = "Pas à jour" ;$RealTimeProtectionStatus = "Désactivé"}
        "393488" {$UpdateStatus = "Pas à jour" ;$RealTimeProtectionStatus = "Désactivé"}
        "397312" {$UpdateStatus = "A jour" ;$RealTimeProtectionStatus = "Activé"}
        "397328" {$UpdateStatus = "Pas à jour" ;$RealTimeProtectionStatus = "Activé"}
        "397584" {$UpdateStatus = "Pas à jour" ;$RealTimeProtectionStatus = "Activé"}
        "397568" {$UpdateStatus = "A jour"; $RealTimeProtectionStatus = "Activé"}
        "393472" {$UpdateStatus = "A jour" ;$RealTimeProtectionStatus = "Désactivé"}
        default {$UpdateStatus = "Inconnu" ;$RealTimeProtectionStatus = "Inconnu"}
        }

$AVName = $AV.displayname
$AVUpdateStatus = $UpdateStatus
$AVProtection = $RealTimeProtectionStatus

}
