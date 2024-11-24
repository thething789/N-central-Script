#Variable
[string]$NcentralUri = 'https://n-central.example.com'
[string]$jwt = 'your-api-key'
[int16]$customPropertyID = 'id-of-the-custom-property'
[string]$regex = '"^([A-Z0-9\-]+-\d+)-\d+$"'
[int16]$filterID = 'id-of-the-filter'

#Obtenir un token d'accès
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $($jwt)")
$response = Invoke-RestMethod "$NcentralUri/api/auth/authenticate" -Method 'POST' -Headers $headers

#Fonction pour recuperer les actifs et leurs ID
function Get-AllDevices {
    param (
        [string]$AccessToken
    )
    # Configuration des en-têtes pour l'API
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    $Devices = @()   # Liste pour accumuler tous les appareils
    $Page = 1        # Numéro de la première page
    $PageSize = 50   # Nombre d'éléments par page (modifiable selon les limites de l'API)

    do {
        # Construire l'URL pour la page courante
        $Url = "$NcentralUri/api/devices?filterId=$filterID&pageNumber=$Page&pageSize=$PageSize&select=deviceId%3Disnull%3Dfalse"

        try {
            # Récupérer les données pour la page courante
            $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method Get

            # Vérifier si des données sont disponibles
            if ($Response.data) {
                foreach ($Computer in $Response.data) {
                    $Devices += [PSCustomObject]@{
                        Name     = $Computer.Longname
                        DeviceID = $Computer.deviceId
                    }
                }
            }

            # Passer à la page suivante
            $Page++
        }
        catch {
            Write-Error "Erreur lors de la récupération des appareils à la page $Page : $_"
            break
        }
    } while ($Response -and $Response.itemCount -eq $PageSize)  # Continue tant que la page est pleine

    return $Devices
}

#Fonction pour reunir les actifs via TAG-NOMBRE
function Group-DevicesByBaseName {
    param (
        [array]$Devices
    )

    # Initialisation de la table de hachage pour regrouper les appareils
    $GroupedDevices = @{}

    # Grouper les appareils par leur nom principal jusqu'à la première occurrence d'un chiffre
    foreach ($Device in $Devices) {
        $Name = $Device.Name
        $DeviceID = $Device.DeviceID

        if (-not $Name) { continue }

        # Identifier le nom principal en excluant les parties incrémentées (exemple : "-02")
        $BaseName = ($Name -replace $regex, '$1')  # Supprime les suffixes incrémentés comme "-02"

        # Initialiser le tableau si la clé n'existe pas encore
        if (-not $GroupedDevices.ContainsKey($BaseName)) {
            $GroupedDevices[$BaseName] = @()
        }

        # Ajouter l'appareil au groupe correspondant
        $GroupedDevices[$BaseName] += [PSCustomObject]@{
            Name     = $Name
            DeviceID = $DeviceID
        }
    }

    return $GroupedDevices
}

#Fonction pour identifier les groupes ayant plusieurs clés
function Detect-Duplicates {
    param (
        [hashtable]$GroupedDevices
    )

    # Liste pour accumuler les doublons détectés
    $DuplicateDevices = @()

    # Parcourir chaque groupe basé sur les noms tronqués
    foreach ($BaseName in $GroupedDevices.Keys) {
        $DeviceGroup = $GroupedDevices[$BaseName]

        # Si le groupe contient plusieurs appareils, ils sont considérés comme doublons
        if ($DeviceGroup.Count -gt 1) {
            $DuplicateDevices += $DeviceGroup
        }
    }

    return $DuplicateDevices
}

#Fonction pour flaguer dans N-Central
function Flag-Duplicates{
    param (
        [array]$DuplicateDevices,
        [string]$AccessToken
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
        "accept" =  "application/json"
    }

    $Body = @{
        "value" = "Oui"
    }

    foreach($object in $DuplicateDevices){
        $Url = "$NcentralUri/api/devices/$($object.DeviceID)/custom-properties/$customPropertyID"
        $Request = Invoke-RestMethod -Uri $Url -Headers $Headers -Body ($Body | ConvertTo-Json) -Method Put
    }
}

#Fonction principal pour lancer le script
function Main {
    # Obtenez le jeton d'accès
    $AccessToken = $response.tokens.access.token

    # Récupérez les appareils
    $Devices = Get-AllDevices -AccessToken $AccessToken

    if (-not $Devices) {
        Write-Host "Aucun appareil récupéré." -ForegroundColor Yellow
        return
    }

    # Grouper les appareils par leur base name
    $GroupedDevices = Group-DevicesByBaseName -Devices $Devices

    # Détectez les doublons
    $DuplicateDevices = Detect-Duplicates -GroupedDevices $GroupedDevices

    # Flag les doublons dans NC
    $FlagDuplicateDevices = Flag-Duplicates -DuplicateDevices $DuplicateDevices -AccessToken $AccessToken
    
    # Affichez les résultats
    if ($DuplicateDevices.Count -gt 0) {
        Write-Host "Doublons détectés :" -ForegroundColor Green
        $DuplicateDevices | Out-GridView -Title "Doublons d'ordinateurs détectés"
    } else {
        Write-Host "Aucun doublon détecté." -ForegroundColor Yellow
    }
}

# Lancer le script
Main