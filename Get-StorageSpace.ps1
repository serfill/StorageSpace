Param(
    [Parameter(Mandatory = $true)][string]$ActionType,
    [parameter(Mandatory = $true)][string]$Key,
    [parameter(Mandatory = $false)][string]$Value
)

$ActionType = $ActionType.ToLower().Replace("'","")
$Key = $Key.ToLower().Replace("'","")
$Value = $Value.ToLower().Replace("'","")

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if ($ActionType -eq 'discover') {
    if ($Key -eq 'pool') {
        $result_json = [pscustomobject]@{
            'data' = @(
                foreach($i in Get-StoragePool -IsPrimordial $false) {
                    [pscustomobject]@{'{#POOL}' = $i.FriendlyName}
                }
            )
        } | ConvertTo-Json
        [console]::WriteLine($result_json)
    }

    if ($Key -eq 'disk') {
        $result_json = [pscustomobject]@{
            'data' = @(
                foreach($i in Get-PhysicalDisk) {
                    [pscustomobject]@{
                       '{#DISK}' = $i.SerialNumber
                        '{#MODEL}' = $i.Model
                    }
                }
            )
        } | ConvertTo-Json
        [console]::WriteLine($result_json)
    }
}

if ($ActionType -eq 'get') {
    if ($Value -eq 'pool') {
        $Storage = Get-StoragePool -FriendlyName $Key
        $State = if($Storage.HealthStatus -eq "Healthy") { 1 } else { 0 }

        $result_json = New-Object PSCustomObject

        $result_json | Add-Member -Type NoteProperty -Name state -Value $State
        $result_json | Add-Member -type NoteProperty -name OperationalStatus -Value $Storage.OperationalStatus
        $result_json | Add-Member -type NoteProperty -name RepairPolicy -Value $Storage.RepairPolicy
        $result_json | Add-Member -type NoteProperty -name Version -Value $Storage.Version
        $result_json | Add-Member -type NoteProperty -name SupportsDeduplication -Value $Storage.SupportsDeduplication
        $result_json | Add-Member -type NoteProperty -name ResiliencySettingNameDefault -Value $Storage.ResiliencySettingNameDefault
        
        $result_json = $result_json | ConvertTo-Json
        [Console]::WriteLine($result_json)       
    }

    if ($Value -eq 'disk') {

        $disk = Get-PhysicalDisk -SerialNumber $Key
        $State = if($disk.HealthStatus -eq "Healthy") { 1 } else { 0 }   
        $result_json = [pscustomobject]@{
            'OperationalStatus' = $disk.OperationalStatus
            'BusType' = $disk.BusType
            'State' = $State
            'MediaType' = $disk.MediaType
            'Model' = $disk.Model
            'PhysicalLocation' = $disk.PhysicalLocation
            'FirmwareVersion' = $disk.FirmwareVersion
        } | ConvertTo-Json
        
        [console]::WriteLine($result_json)
        
    }

}