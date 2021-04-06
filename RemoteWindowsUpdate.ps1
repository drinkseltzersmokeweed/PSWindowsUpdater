#Let's ask if we can install the PSWindowsUpdate
$validAnswer = $false
While(-not $validAnswer)
{
    $yn = Read-Host "Do you want to install PSWindowsUpdate? (y/n)"
    Switch($yn.ToLower())
    {
        "y" {$validAnswer = $true
                #Let's install the PSWindowsUpdate app
                Install-Module PSWindowsUpdate
        }
        "n" {$validAnswer = $true
                #They said no, so leave
                Exit 1
        }
        Default {Write-Host "Try entering 'y' or 'n'."}
    }
}

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

Write-Host "Attempting to install the updates on $machineName"
Invoke-WUJob -ComputerName $machineName -Script {ipmo PSWindowsUpdate; Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot} -RunNow -Confirm:$false | Out-File "\\$machineName\temp\$machineName-$(Get-Date -f yyyy-MM-dd)-MSUpdates.log" -Force 
Write-Host "Update commmand completed on $machineName"

