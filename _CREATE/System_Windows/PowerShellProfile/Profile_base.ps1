function prompt {
    $isRoot = (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    $color  = if ($isRoot) {"Red"} else {"Green"}
    $marker = if ($isRoot) {"#"}   else {"$"}
    $fn = python "C:\Program Files\PowerShell\7\get_fn.py" $pwd

    Write-Host "[$(Get-Date)]"
    Write-Host "|-$pwd\~" -ForegroundColor $color
    Write-Host "|-$env:USERNAME" -ForegroundColor $color -NoNewline
    Write-Host "::" -ForegroundColor Yellow -NoNewline
    Write-Host "$fn" -ForegroundColor Cyan -NoNewline
    Write-Host "::" -ForegroundColor Yellow -NoNewline
    Write-Host $marker -ForegroundColor $color -NoNewline
    return " "
  }
Clear-Host

function ll {
  python "C:\Program Files\PowerShell\7\ls.py" $pwd $args
  return 
}

$env:desktop = "C:\Users\zyose\Desktop"
$env:profile = "C:\Program Files\PowerShell\7\Profile.ps1"
$env:ws = "E:\202270121\SHO\stylegan3-editing-main\"
$env:project = "E:\202270121\ws\stylegan3-editing"
$env:sg3_editing = "E:\202270121\BACK_ENV\Stylegan3-editing\stylegan3_editing"
Set-Alias ls ll
