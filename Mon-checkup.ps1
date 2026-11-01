$cheminRapport = "C:\Users\durel\Desktop\checkup_$env:COMPUTERNAME.txt"
Start-Transcript -Path $cheminRapport | out-Null

Write-Host "Bonjour, je suis un script réalisé par KYOUKAI qui va Réalisé le chek-up complet de votre PC et vous fournir une analyse "
$nomPC = $env:COMPUTERNAME
$utilisateur = $enV:USERNAME
$date = Get-date -Format "dd/MM/yyyy HH:mm:ss"
$dossierPersonnel = $env:USERPROFILE
Write-Host "Check-up du pc : $nomPC"
Write-Host "Utilisateur : $utilisateur"
Write-Host "Date : $date"
Write-Host "dossier personnel de l'utilisateur : $dossierPersonnel"


Write-Host ""
Write-Host "---SYSTEME---"

$os = Get-CimInstance -ClassName Win32_OperatingSystem
$machine = Get-CimInstance -ClassName Win32_ComputerSystem

$nomOS = $os.Caption
$marque = $machine.Manufacturer
$modele = $machine.Model

Write-Host "os : $nomOS"
Write-Host "Marque : $marque"
Write-Host "Modele : $modele"
$cpu = Get-CimInstance -ClassName win32_Processor
$nomProcessuer = $cpu.Name
Write-Host "Processeur: $nomProcessuer"


Write-Host ""
Write-Host "---MEMOIRE---"

$ramTotale = [math]::Round($os.TotalVisibleMemorySize * 1KB / 1GB, 1)
$ramLibre = [math]::Round($os.FreePhysicalMemory * 1KB / 1GB, 1)
$ramutilise = $ramTotale - $ramLibre

write-Host "MEMOIRE RAM TOTALE : $ramTotale"
write-Host "MEMOIRE RAM LIBRE : $ramLibre"
write-Host "MEMOIRE RAM UTILISE : $ramutilise"
$pourcentageRam = [math]::Round($ramutilise / $ramTotale * 100, 0)
Write-Host "MEMOIRE UTILISE : $pourcentageRam%"
 Write-Host ""
 Write-Host "---ETAT RAM---"

 if ($pourcentageRam -gt 85) {
    Write-Host "RAM: ATTENTION , saturation ($pourcentageRam%)"}
    else {
        Write-Host "RAM : OK ($pourcentageRam%)"}

Write-Host ""
Write-Host "---ETAT des disque---"

$tousLesDisques =Get-Volume |Where-Object {$_.DriveLetter -ne $null}

foreach ($disque in $tousLesDisques){
    $lettre= $disque.DriveLetter
    $total= [math]::Round($disque.size /1GB, 0)
    $libre=[math]::Round($disque.sizeRemaining /1GB, 0)
    $pourcentagelibre= [math]::Round($disque.sizeremaining/ $disque.size *100)
    if($pourcentagelibre -lt 15){
        Write-Host "Disque $lettre : ATTENTION, $libre Go sur $total Go soit ($pourcentagelibre %) Restant"}
     else {
        Write-Host "Disque $lettre : OK , $libre GO libre SUR $total Go soit ($pourcentagelibre%) Restant"
        }
    }


    Write-Host ""
    Write-Host "---BATTERIE---"
    powercfg /batteryreport /xml /output "$env:TEMP\bat.xml" | out-Null
    [xml]$rapportBat = Get-content "$env:TEMP\bat.xml"
    $bat = $rapportBat.BatteryReport.Batteries.Battery 
    $origine = [int]$bat.Designcapacity
    $actuelle = [int]$bat.Fullchargecapacity
    $cycles = $bat.cyclecount

    $sante= [math]::round($actuelle/$origine * 100)
    Write-Host "le cycle est de : $cycles"
    if ($sante -lt 80 ){
    Write-Host "ATTENTION, usure battérie à ($sante %) "}
    else
    {
        Write-Host " BATTERIE OK ($sante%) "
    }


    Stop-Transcript | out-Null
    Write-Host ""
    write-Host "Le rapport est enregistrer ici :$cheminRapport"