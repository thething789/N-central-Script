#========================= Variable =========================#
$BitDefapikey = 'gravityzone-api-key'
$NCapikey = 'ncentral-jwt'
$ServerFQDN = 'ncentral-uri'
#==============================================================#


function CallApiBitDefenderKey {
    param (
        [string]$TAG
    )

    $api_key = $BitDefapikey

    $user = $api_key
    $pass = ""
    $login = $user + ":" + $pass

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($login)
    $encodedlogin = [Convert]::ToBase64String($bytes)

    $authheader = "Basic " + 
    $encodedlogin

    $base_uri = "https://cloudgz.gravityzone.bitdefender.com/api"

    $api_endpoint = "/v1.0/jsonrpc/packages"
    $request_uri = $base_uri + $api_endpoint


    $tag = "[" + $tag + "][DEFAULT][PACKAGE]"
    $request_data = '     {
      "params": {
    
    "packageName": "'+ $tag + '"
},
  "jsonrpc": "2.0",
  "method": "getInstallationLinks",
  "id": "426db9bb-e92a-4824-a21b-bba6b62d0a18"
}     '

    $headers = New-Object `
        "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization",
        $authheader)
    $headers.Add("Content-Type", "application/json")

    $response2 = Invoke-RestMethod -Uri $request_uri `
        -Headers $headers -ContentType 'application/json' `
        -Method Post -Body $request_data

    $url = $response2.result.installLinkWindows
    $pattern = 'setupdownloader_(.*?)\.exe'
    
    $match = [regex]::Match($url, $pattern)
    $chaine = $match.Groups[1].Value.Trim('[', ']')
    Write-Output $chaine

}
#############################################################################

$JWT = $NCapikey
# Connect to NC
$NCSession = New-NCentralConnection -ServerFQDN $ServerFQDN -JWT $JWT

$ListeClients = $NCSession.CustomerList() | Where-Object -FilterScript { ($_.CustomerName -notmatch "0 - ") }  | Select-Object -Property customername, customerid

$ListeClients | ForEach-Object {
    $TAG = $_.customername.split(" ")[0]
    $BitDefenderKey = CallApiBitDefenderKey -TAG $TAG
    $CustomerPropertyValue = Get-NCCustomerProperty -CustomerID $_.customerid -PropertyName "AV - Bitdefender Key"

    if ($CustomerPropertyValue -ne $BitDefenderKey) {
        Write-Host "$Tag Not equal : $BitDefenderKey"
        Pause
        Remove-NCCustomerPropertyValue -CustomerID $_.customerid -PropertyName "AV - Bitdefender Key" -ValueToDelete $CustomerPropertyValue
        Add-NCCustomerPropertyValue -CustomerID $_.customerid -PropertyName "AV - Bitdefender Key" -ValueToInsert $BitDefenderKey
    }
    else {
        Write-Host "$Tag Equal"
    }
    
}