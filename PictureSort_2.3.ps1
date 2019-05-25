
#elevate to admin via UAC 
#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }


#Set the folder to move pictures from
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

#find the root script directory
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition


#Set Path of Pictures
$a = Get-Folder

#Run script from set location
Set-Location -Path $a


#Get Total Number of Items to be moved.
$i = 0



ForEach($File in (Get-ChildItem '.\*.*')){
    $DestFolder = Join-Path $PSScriptRoot $File.LastWriteTime.ToString('yyyy-MM-dd')
    if (!(Test-Path $DestFolder)){MD $DestFolder|Out-Null}
    $finalDest = $DestFolder + "\" + $File.Name

    if(!(Test-Path $finalDest)){$i++}

    }


#calculate percantages

$percentageAmount = $i/100
$percent = $i/$percentageAmount
$x = 0
ForEach($File in (Get-ChildItem '.\*.*')){
$x++
$percentagevalue = $x/$percentageAmount
    Write-Progress -Activity "Move in Progress" -Status "$percentagevalue% Complete:" -PercentComplete $percentagevalue;

    $DestFolder = Join-Path $PSScriptRoot $File.LastWriteTime.ToString('yyyy-MM-dd')
    if (!(Test-Path $DestFolder)){MD $DestFolder|Out-Null}
    $finalDest = $DestFolder + "\" + $File.Name

    if(!(Test-Path $finalDest)){$File | Move-Item -Destination $DestFolder}
    else{
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Cannot move file $File. because it already exists in the destination",0,"Done",0x1)
    }
    }



