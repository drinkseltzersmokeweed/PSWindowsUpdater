#Create a new variable to hold the machine name - this can be modded to read a list or txt file, etc
$machineName = Read-Host "What's the machine name"

#Let's ask if we should scan the machine for updates
$validAnswer = $false
While(-not $validAnswer)
{
    $yn = Read-Host "Do you want to scan the machine first? (y/n)"
    Switch($yn.ToLower())
    {
        "y" {$validAnswer = $true
            #Scan the machine for updates
            $Updates = Invoke-Command -ComputerName $machineName {Start-WUScan}
            Write-Host "Updates Found on $machineName : " $Updates.Count
        }
        "n" {$validAnswer = $true
        }
        Default {Write-Host "Try entering 'y' or 'n'."}
    }
}

Write-Host "Attempting to get updates on $machineName"
$UpdatesToInstall = Invoke-Command -ComputerName $machineName -ScriptBlock {Start-WUScan -SearchCriteria "UpdateId='' AND IsInstalled=1"}

#Let's run the update commands now
$cimSession = New-CimSession -ComputerName $machineName

Write-Host "Attempting to install the updates on $machineName"
Install-WUUpdates -Updates $UpdatesToInstall -CimSession $cimSession

Write-Host "Update commmand completed on $machineName"
