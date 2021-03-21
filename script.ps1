Function GetProcess($chosen) {
    if ($chosen -eq 1){
        #getting process by name
        $name = Read-Host -Prompt 'Input the process name'
        try {
            Write-Host 'Getting process list!' -ForegroundColor Green
            Get-Process -Name $name -ErrorAction Stop 
            #trying to stop the process
            Write-Host 'Trying to stop the process' -ForegroundColor Green
            Stop-Process -Name $name -Confirm
        }
        catch {
            Write-Host "There is no such process" -ForegroundColor Cyan
        }
    }
    elseif ($chosen -eq 2){
        #getting process by part name
        $name = Read-Host -Prompt 'Input the part of process name'
        try {
            Write-Host 'Getting process list!' -ForegroundColor Green
            Get-Process -Name $name* -ErrorAction Stop 
        }
        catch {
            Write-Host "There is no such process" -ForegroundColor Cyan
        }
    }
    elseif ($chosen -eq 3){
        #getting process by ID
        $id = Read-Host -Prompt 'Input the ID'
        try {
            Write-Host 'Getting process list!' -ForegroundColor Green
            Get-Process -Id $id -ErrorAction Stop
            #trying to stop the process
            Write-Host 'Trying to stop the process' -ForegroundColor Green
            Stop-Process -Id $id -Confirm 
        }
        catch {
            Write-Host "There is no such process" -ForegroundColor Cyan
        }
   }
}

Function WriteProcess {
    while($true){
        $numberOfItems = (Get-ChildItem -filter FilteredProcessList*.csv).Count
        if ($numberOfItems -eq 5){
            Write-Host 'Reached 5 files. Removing oldest one...' -ForegroundColor Red
            Get-ChildItem -filter FilteredProcessList*.csv | Sort CreationTime | Select -First 1 | Remove-item
        }

        Write-Host 'Writting process list into a file' -ForegroundColor Green
        Get-Process | Sort-Object -Property VM -Descending | Select-Object ProcessName, Id, VM | Export-Csv -Path ".\FilteredProcessList_$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv" -NoTypeInformation | Out-Null #Sorting table by process value
        sleep(30) #Runs every 30 seconds        
    }
}

Function EditRegistry {
    $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm"
    try {
        New-Item -Path "HKCU:\Software" -Name PowershellScriptRunTime -ErrorAction Stop
        
    }
    catch [System.IO.IOException], [Microsoft.PowerShell.Commands.NewItemCommand] {
        Write-Host 'Folder exists' -ForegroundColor Red
        $error.clear() #clearing automatic variable 
    }
    
    try{
        New-ItemProperty -Path "HKCU:\Software\PowershellScriptRunTime" -Name "RunTime" -Value $currentTime -PropertyType "String" -ErrorAction Stop
    }
    catch [System.IO.IOException], [Microsoft.PowerShell.Commands.NewItemPropertyCommand]{
        $error.clear() #clearing automatic variable 
        Write-Host 'Key exists' -ForegroundColor Red
        Write-Host 'Attempting to update the key!' -ForegroundColor Cyan
        try{
            Set-ItemProperty -path "HKCU:\Software\PowershellScriptRunTime" -Name "RunTime" -value $currentTime
        }
        catch {
            Write-Host 'Could not update :(' -ForegroundColor DarkCyan
            return
        }
    }
    if (!$error) {
        Write-Host 'Success!' -ForegroundColor Green
    }
}


do {
    Write-Host "1. Get process"
    Write-Host "2. Get process table by value, sort it by VM and write into a file"
    Write-Host "3. Create new registry and save the date"
    Write-Host "4. Close"

    $number = Read-Host -Prompt 'Choose a number'
    switch($number) {
        1 {
            Write-Host "1. Get process by name"
            Write-Host "2. Get process by part name"
            Write-Host "3. Get process by ID"
            Write-Host "4. Back"
            $chosen = Read-Host -Prompt 'Which function to do?'
            if ($chosen -ge 1 -and $chosen -le 3){
                GetProcess($chosen) #$_
            }
            elseif($chosen -eq 4){
                break
            }
            else{
                Write-Host "There is no such option!" -ForegroundColor Red
            }

            break
        }

        2 {
            WriteProcess
            break
        }

        3 {
            EditRegistry
            break
        }

        4 {
            Write-Host "bye" -ForegroundColor Green
            break
        }
         
        default{
            Write-Host "There is no such option!" -ForegroundColor Red
        }
    }
} while ($number -ne 4)

