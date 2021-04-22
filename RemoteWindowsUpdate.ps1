#Let's ask if we can install the PSWindowsUpdate
$validAnswer = $false
While(-not $validAnswer)
{
    $yn = Read-Host "Do you want to install PSWindowsUpdate locally? (y/n)"
    Switch($yn.ToLower())
    {
        "y" {$validAnswer = $true
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
                #Let's install the PSWindowsUpdate app
                Install-Module PSWindowsUpdate
                Import-Module PSWindowsUpdate
                Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
                Invoke-WUJob
                Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
                Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
        }
        "n" {$validAnswer = $true
                #Here we need to perform a test for PSWindowsUpdate to be installed locally, then if it's not installed we can exit
                if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
                    #yay they have it installed already
                }
                else{
                    Write-Host "PSWindowsUpdate isn't installed, we will quit now."
                    Exit 1
                }
        }
        Default {Write-Host "Try entering 'y' or 'n'."}
    }
}

#Create a new variable to hold the machine name - this can be modded to read a list or txt file, etc
$machineName = Read-Host "What's the machine name"

#Let's ask if we need to install PSWindowsUpdate on the remote machine
$validAnswer = $false
While(-not $validAnswer)
{
    $yn = Read-Host "Do you want to install PSWindowsUpdate on the remote machine? (y/n)"
    Switch($yn.ToLower())
    {
        "y" {$validAnswer = $true
            #Let's send the commmands needed
            Invoke-Command -ComputerName $machineName {Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force}
            Invoke-Command -ComputerName $machineName {Set-PSRepository -Name PSGallery -InstallationPolicy Trusted}
            Invoke-Command -ComputerName $machineName {Install-Module PSWindowsUpdate -force}
            Invoke-Command -ComputerName $machineName {Import-Module PSWindowsUpdate}
            Invoke-Command -ComputerName $machineName {Add-WUServiceManager -MicrosoftUpdate -Confirm:$false}
            Invoke-Command -ComputerName $machineName {Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false}
        }
        "n" {$validAnswer = $true
        }
        Default {Write-Host "Try entering 'y' or 'n'."}
    }
}

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

#Let's ask if we should start the update
$validAnswer = $false
While(-not $validAnswer)
{
    $yn = Read-Host "Do you want to start the update? (y/n)"
    Switch($yn.ToLower())
    {
        "y" {$validAnswer = $true
        Write-Host "Attempting to add $machineName to TrustedHosts..."
        Set-Item WSMan:localhost\client\trustedhosts -value "$machineName" -force

        Write-Host "Attempting to install the updates on $machineName"
        #Invoke-WUJob -ComputerName $machineName -Script {ipmo PSWindowsUpdate; Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot} -RunNow -Confirm:$false | Out-File "\\$machineName\c$\temp\$machineName-$(Get-Date -f yyyy-MM-dd)-MSUpdates.log" -Force
        Invoke-WUJob -ComputerName $machineName -Script {ipmo PSWindowsUpdate; Install-WindowsUpdate -AcceptAll | Out-File C:\temp\PSWindowsUpdate.log } -RunNow -Confirm:$false

        Write-Host "Update commmand completed on $machineName"
        }
        "n" {$validAnswer = $true
            Exit 1
        }
        Default {Write-Host "Try entering 'y' or 'n'."}
    }
}
