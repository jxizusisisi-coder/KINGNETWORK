# ================================
# MINI SCAN UI SYSTEM + KEY LOGIN
# ================================
$ErrorActionPreference = 'SilentlyContinue'

# ---------- MINI WINDOW ----------
$Host.UI.RawUI.WindowTitle = "NITROPRIME STORE..."
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Green"

$size = New-Object System.Management.Automation.Host.Size
$size.Width  = 45
$size.Height = 18
$Host.UI.RawUI.WindowSize = $size

$buffer = New-Object System.Management.Automation.Host.Size
$buffer.Width  = 45
$buffer.Height = 300
$Host.UI.RawUI.BufferSize = $buffer

Clear-Host

# ================= TYPE EFFECT =================
function Write-Type {
    param($text)
    foreach ($c in $text.ToCharArray()) {
        Write-Host -NoNewline $c
        Start-Sleep -Milliseconds 15
    }
    Write-Host ""
}

# ================= KEY SYSTEM =================
function Show-KeyScreen {

    Clear-Host
    $script:Mode = "NITROPRIME STORE"

    $validKey = "Admin"
    $attempt = 0
    $maxTry = 3

    while ($true) {

        Clear-Host
        Write-Host "=============================" -ForegroundColor Green
        Write-Host "      NITROPRIME LOGIN       " -ForegroundColor Green
        Write-Host "=============================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Enter Access Key:" -ForegroundColor Cyan
        Write-Host ""

        $key = Read-Host "KEY"

        if ($key -eq $validKey) {
            Write-Host ""
            Write-Host "ACCESS GRANTED" -ForegroundColor Green
            Start-Sleep 1
            break
        }
        else {
            $attempt++
            Write-Host "INVALID KEY ($attempt/$maxTry)" -ForegroundColor Red
            Start-Sleep 1

            if ($attempt -ge $maxTry) {
                Write-Host "ACCESS DENIED" -ForegroundColor Red
                Start-Sleep 2
                exit
            }
        }
    }
}

# ================= TITLE ENGINE =================
$script:Mode = "NITROPRIME STORE"
$script:TitleBase = "  Scan System ...  "
$script:Index = 0

function Update-Title {

    if ($script:Mode -eq "BOOT") {
        $Host.UI.RawUI.WindowTitle = "BOOTING..."
        return
    }

    if ($script:Mode -eq "SCAN") {
        $t = $script:TitleBase
        $len = $t.Length

        $rot = $t.Substring($script:Index) + $t.Substring(0,$script:Index)
        $Host.UI.RawUI.WindowTitle = $rot

        $script:Index++
        if ($script:Index -ge $len) { $script:Index = 0 }
    }

    if ($script:Mode -eq "MENU") {
        $Host.UI.RawUI.WindowTitle = "NITROPRIME STORE"
    }
}

# ================= REAL SCAN =================
function Scan-CPU {
    $cpu = Get-CimInstance Win32_Processor
    return @(
        "[CPU]",
        "Name: $($cpu.Name)",
        "Cores: $($cpu.NumberOfCores)",
        "Threads: $($cpu.NumberOfLogicalProcessors)",
        "Clock: $($cpu.MaxClockSpeed) MHz",
        "Load: $($cpu.LoadPercentage)%"
    )
}

function Scan-RAM {
    $os = Get-CimInstance Win32_OperatingSystem
    $total = [math]::Round($os.TotalVisibleMemorySize/1MB,2)
    $free  = [math]::Round($os.FreePhysicalMemory/1MB,2)

    return @(
        "[RAM]",
        "Total: $total GB",
        "Free: $free GB",
        "Used: $([math]::Round($total-$free,2)) GB"
    )
}

function Scan-GPU {
    $gpu = Get-CimInstance Win32_VideoController
    return @(
        "[GPU]",
        "Name: $($gpu.Name)",
        "Driver: $($gpu.DriverVersion)",
        "VRAM: $([math]::Round($gpu.AdapterRAM/1MB,2)) MB"
    )
}

function Scan-WINDOWS {
    $os = Get-CimInstance Win32_OperatingSystem
    return @(
        "[WINDOWS]",
        "Edition: $($os.Caption)",
        "Version: $($os.Version)",
        "Build: $($os.BuildNumber)"
    )
}

function Scan-NETWORK {
    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
    $ip = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "169.*"} | Select-Object -First 1
    $dns = Get-DnsClientServerAddress -AddressFamily IPv4 | Select-Object -First 1

    return @(
        "[NETWORK]",
        "Adapter: $($adapter.Name)",
        "IP: $($ip.IPAddress)",
        "DNS: $($dns.ServerAddresses -join ', ')"
    )
}

# ================= SCAN =================
function Show-ScanIntro {

    Clear-Host
    $script:Mode = "SCAN"

    $scans = @(
        { Scan-CPU },
        { Scan-RAM },
        { Scan-GPU },
        { Scan-WINDOWS },
        { Scan-NETWORK }
    )

    foreach($s in $scans){

        $result = & $s

        Write-Host "=================================="
        Write-Host "LOADING..."
        Write-Host ""

        Start-Sleep -Milliseconds 250   # ⏳ รอขึ้นหัวข้อ

        foreach($line in $result){
            Update-Title
            Write-Host $line
            Start-Sleep -Milliseconds 200   # 👀 อ่านทันแน่นอน แต่ยังไว
        }

        Write-Host ""
        Write-Host "SCAN COMPLETE"
        Write-Host "=================================="
        Start-Sleep -Milliseconds 1000   # ⏳ เว้นช่วงก่อนล้างจอ
        Clear-Host
    }

    Write-Host "SCAN COMPLETE" -ForegroundColor Green
    Write-Host "[SYSTEM READY]" -ForegroundColor Cyan
    Start-Sleep -Milliseconds 250
}
# ================= MENU =================
function Show-MenuFade {

    Clear-Host
    $script:Mode = "MENU"

    $lines = @(
        "====== NETWORK POOL KING ======",
        "",
        "1. Install",
        "2. Clear",
        "3. Exit",
        ""
    )

    foreach($l in $lines){
        Update-Title
        Write-Host $l
        Start-Sleep -Milliseconds 40   # 🔥 เร็ว ลื่น
    }
}

# ================= START =================
Show-KeyScreen
Show-ScanIntro

# ================= LOOP =================
while($true){

Show-MenuFade
$choice = Read-Host "Select"

switch($choice){

"1"{
    Clear-Host
$ErrorActionPreference = 'SilentlyContinue'

$InterfaceAlias = "Ethernet"
$GameProcessName = "FiveM"
$DNSv4 = @("1.1.1.1","8.8.8.8")
$DNSv6 = @("2001:4860:4860::8888","2001:4860:4860::8844")
$MTU = 1500

# TCP
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global congestionprovider=ctcp
netsh int tcp set global rss=enabled
netsh int tcp set global chimney=disabled
netsh int tcp set global dca=enabled
netsh int tcp set global ecncapability=default
netsh int tcp set global timestamps=disabled
netsh int tcp set global rsc=disabled
netsh int tcp set global fastopen=enabled
netsh int tcp set heuristics disabled
netsh int tcp set global maxsynretransmissions=2
netsh int tcp set global initialrto=1000
netsh int tcp set global delayedacktimeout=100
netsh int tcp set global datalinklayerretries=3
netsh int tcp set global netdma=disabled
netsh int tcp set global minrto=100

# PORT
netsh int ipv4 set dynamicport tcp start=1024 num=64511
netsh int ipv4 set dynamicport udp start=1024 num=64511

# MTU
netsh interface ipv4 set subinterface "$InterfaceAlias" mtu=$MTU store=persistent
netsh interface ipv6 set subinterface "$InterfaceAlias" mtu=$MTU store=persistent

# IP
netsh int ip set global taskoffload=enabled
netsh interface ipv4 set global icmpredirects=disabled
netsh interface ipv4 set global multicastforwarding=disabled

netsh interface ipv6 set global randomizeidentifiers=disabled
netsh interface ipv6 set privacy state=disabled
netsh interface ipv6 set teredo disabled

# DNS
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DNSv4
netsh interface ipv6 set dnsservers "$InterfaceAlias" static $($DNSv6[0])
netsh interface ipv6 add dnsservers "$InterfaceAlias" $($DNSv6[1]) index=2

# REGISTRY
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpNoDelay" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpAckFrequency" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TCPDelAckTicks" -Value 0 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpDelAckFrequency" -Value 1 -PropertyType DWord -Force

# TIMER
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class TimerResolution {
    [DllImport("ntdll.dll", SetLastError=true)]
    public static extern uint NtSetTimerResolution(uint DesiredResolution, bool SetResolution, ref uint CurrentResolution);
}
"@

$cur = 0
[void][TimerResolution]::NtSetTimerResolution(5000, $true, [ref]$cur)

# MULTIMEDIA
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -PropertyType DWord -Force

New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Value 8
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Value 6
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Value "High"

# OFFLOAD
Disable-NetAdapterPowerManagement -Name $InterfaceAlias
Enable-NetAdapterRss -Name $InterfaceAlias
Set-NetOffloadGlobalSetting -ReceiveSideScaling Enabled
Set-NetOffloadGlobalSetting -ReceiveSegmentCoalescing Disabled
Set-NetOffloadGlobalSetting -TaskOffload Enabled

# NIC
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Receive Buffers" -DisplayValue "4096"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Transmit Buffers" -DisplayValue "4096"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Interrupt Moderation" -DisplayValue "Disabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Flow Control" -DisplayValue "Disabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Advanced EEE" -DisplayValue "Disabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Green Ethernet" -DisplayValue "Disabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Power Saving Mode" -DisplayValue "Disabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Selective Suspend" -DisplayValue "Disabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Receive Side Scaling" -DisplayValue "Enabled"

# ENABLE ADAPTER
netsh interface set interface "$InterfaceAlias" admin=enabled

# PROCESS
$proc = Get-Process -Name "$GameProcessName*" -ErrorAction SilentlyContinue
if ($proc) {
    foreach ($p in $proc) {
        try {
            $p.ProcessorAffinity = 0xFFF
            $p.PriorityClass = "High"
        } catch {}
    }
}

# POWER
powercfg -setactive SCHEME_MIN
    Clear-Host
    Write-Type "Start Success PooL King ..."
    Start-Sleep 1
    Write-Type "Success network..."
    Start-Sleep 1
    Write-Type "System stabilized."

    Write-Host ""
    Write-Host "Done. Restart Your PC." -ForegroundColor Green
    Read-Host "Press Enter"
}

"2"{
    Clear-Host
# ================================
# FULL NETWORK + SYSTEM RESET
# ================================
$ErrorActionPreference = 'SilentlyContinue'

Write-Host "RESETTING SYSTEM SETTINGS..." -ForegroundColor Yellow

# ================================
# 1. TCP RESET
# ================================
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global congestionprovider=default
netsh int tcp set global rss=enabled
netsh int tcp set global chimney=disabled
netsh int tcp set global dca=disabled
netsh int tcp set global ecncapability=default
netsh int tcp set global timestamps=disabled
netsh int tcp set global rsc=enabled
netsh int tcp set global fastopen=disabled
netsh int tcp set heuristics enabled
netsh int tcp set global maxsynretransmissions=2
netsh int tcp set global initialrto=3000

# ================================
# 2. PORT RESET
# ================================
netsh int ipv4 set dynamicport tcp start=49152 num=16384
netsh int ipv4 set dynamicport udp start=49152 num=16384

# ================================
# 3. MTU RESET
# ================================
netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent
netsh interface ipv6 set subinterface "Ethernet" mtu=1500 store=persistent

# ================================
# 4. IP GLOBAL RESET
# ================================
netsh int ip set global taskoffload=disabled
netsh interface ipv4 set global icmpredirects=enabled
netsh interface ipv4 set global multicastforwarding=enabled

netsh interface ipv6 set global randomizeidentifiers=enabled
netsh interface ipv6 set privacy state=enabled
netsh interface ipv6 set teredo default

# ================================
# 5. DNS RESET
# ================================
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses

# ================================
# 6. REMOVE REGISTRY TWEAKS
# ================================
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpNoDelay" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TCPDelAckTicks" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpDelAckFrequency" -ErrorAction SilentlyContinue

# ================================
# 7. MULTIMEDIA RESET
# ================================
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -ErrorAction SilentlyContinue

# ================================
# 8. POWER PLAN RESET
# ================================
powercfg -setactive SCHEME_BALANCED

# ================================
# 9. NIC RESET (DEFAULT VALUES)
# ================================
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Receive Buffers" -DisplayValue "Default"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Transmit Buffers" -DisplayValue "Default"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Interrupt Moderation" -DisplayValue "Enabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Flow Control" -DisplayValue "Enabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Advanced EEE" -DisplayValue "Enabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Green Ethernet" -DisplayValue "Enabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Power Saving Mode" -DisplayValue "Enabled"

# ================================
# 10. NETWORK RESET COMMANDS
# ================================
netsh int ip reset
netsh winsock reset

Write-Host "RESET COMPLETE. PLEASE RESTART PC." -ForegroundColor Green
    Clear-Host
    Write-Type "Removing NETWORK..."
    Start-Sleep 150
    Write-Type "RestorE default..."

    Write-Host "`nDONE. REBOOT REQUIRED." -ForegroundColor Green
    Read-Host "Press Enter"
}

"3"{ exit }

default{
    Write-Host "Invalid command" -ForegroundColor Red
    Start-Sleep 150
}

}

}