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
        #catching error if something went wrong
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
    #function to write processes into a csv every 30s
    while($true){
        $numberOfItems = (Get-ChildItem -filter FilteredProcessList*.csv).Count #saving the number of items in current directory
        if ($numberOfItems -eq 5){ #checking if there are 5 items
            Write-Host 'Reached 5 files. Removing oldest one...' -ForegroundColor Red #deleting the oldest file so the new one takes its place. "Housekeeping"
            Get-ChildItem -filter FilteredProcessList*.csv | Sort CreationTime | Select -First 1 | Remove-item
        }

        Write-Host 'Writting process list into a file' -ForegroundColor Green
        Get-Process | Sort-Object -Property VM -Descending | Select-Object ProcessName, Id, VM | Export-Csv -Path ".\FilteredProcessList_$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv" -NoTypeInformation | Out-Null #Sorting table by process value and writing to a csv with date
        sleep(30) #Runs every 30 seconds        
    }
}

Function EditRegistry {
    #function to create a folder and a property for it in registry
    $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm" #getting current date
    try {
        New-Item -Path "HKCU:\Software" -Name PowershellScriptRunTime -ErrorAction Stop #if there is such folder print message for user
        
    }
    catch [System.IO.IOException], [Microsoft.PowerShell.Commands.NewItemCommand] {
        Write-Host 'Folder exists' -ForegroundColor Red
        $error.clear() #clearing automatic variable 
    }
    
    try{
        New-ItemProperty -Path "HKCU:\Software\PowershellScriptRunTime" -Name "RunTime" -Value $currentTime -PropertyType "String" -ErrorAction Stop #try to create a property
    }
    catch [System.IO.IOException], [Microsoft.PowerShell.Commands.NewItemPropertyCommand]{
        #if there is such property try to update it with current values
        $error.clear() #clearing automatic variable 
        Write-Host 'Key exists' -ForegroundColor Red
        Write-Host 'Attempting to update the key!' -ForegroundColor Cyan
        try{
            Set-ItemProperty -path "HKCU:\Software\PowershellScriptRunTime" -Name "RunTime" -value $currentTime #updating the property
        }
        catch {
            Write-Host 'Could not update :(' -ForegroundColor DarkCyan #if something went wrong return from function
            return
        }
    }
    if (!$error) { 
        #a check so the function doesn't print Success! every time
        Write-Host 'Success!' -ForegroundColor Green
    }
}

#infinite loop for menu
do {
    #printing menu
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
                GetProcess($chosen) 
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

