$url = "https://{company}.sharepoint.com/sites/{site}"

$password = "password"

$password = ConvertTo-SecureString $password -AsPlainText -Force

#user with permissions on the site
$upn = "backup@company.com"

$appcredentials = New-Object System.Management.Automation.PSCredential($upn, $password)

#If you have a service runing and use this folder, you have to stop it before compressing
Stop-Service -Name servicename


#compress file with winrar in backgorund
$file_path = "C:\$((Get-Date).ToString('yyyy-MM-dd'))"

$argList = @("a",  ('"'+$file_path+'"'), ('"'+"C:\{folder}"+'"'))

Start-Process -FilePath "C:\Program Files\Winrar\winrar.exe" -ArgumentList $argList -NoNewWindow -Wait


#connect to SP online
Connect-PnPOnline $url -Credentials $appcredentials

$file_path = $file_path+'.rar'

Add-PnPFile -Folder "Documentos compartidos" -Path $file_path

Remove-Item -Path $file_path -Force





#Retention(21 days)--------------------------------------------------------------------------------------------------------------

$items = Get-PnPListItem -List "Documentos compartidos"  | Where {$_.FileSystemObjectType -eq "File"}

$data=@()
ForEach($item in $items)
{
 
    $data += New-Object PSObject -Property @{
    FileName = $item.FieldValues['FileLeafRef']
    FileURL = $item.FieldValues['FileRef']
    }
}

$data | ForEach-Object{
 
    #$file_day = [int]$_.FileName.Split(".")[0].Split("-")[2]
    #$file_date = [int]$file_date.Split("-")[2]
    #$current_day = Get-Date
    #$current_day = [int](Get-Date -Format "dd")
    
    $file_day = $_.FileName.Split(".")[0]
    $current_day = Get-Date -Format "yyyy-MM-dd"

    $difference_days = $(New-TimeSpan -Start $file_day -End $current_day).Days
    
    if($difference_days -gt 21){
       Remove-PnPFile -ServerRelativeUrl $_.FileURL -Force
    
    }

}
