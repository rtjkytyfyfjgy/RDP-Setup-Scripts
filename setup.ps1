# Set Execution Policy to allow scripts to run
Set-ExecutionPolicy RemoteSigned -Force

# Function to enable Remote Desktop
function Enable-RDP {
    Write-Host "Enabling Remote Desktop..."
    # Enabling Remote Desktop in Registry
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
    # Allow RDP through Windows Firewall
    New-NetFirewallRule -DisplayName "Allow RDP" -Name "RDP" -Enabled True -Protocol TCP -Action Allow -LocalPort 3389
    Write-Host "Remote Desktop is enabled!"
}

# Function to install Windows Updates
function Install-WindowsUpdates {
    Write-Host "Installing Windows Updates..."
    # Trigger Windows Update to install latest updates
    Install-WindowsUpdate -AcceptAll -AutoReboot
    Write-Host "Windows updates completed!"
}

# Function to set screen resolution for RDP (optional, adjust as needed)
function Set-RDPScreenResolution {
    Write-Host "Setting screen resolution for RDP..."
    $width = 1920
    $height = 1080
    # Set screen resolution (for RDP optimization)
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Resolution {
        [DllImport("user32.dll")]
        public static extern int ChangeDisplaySettings(ref DEVMODE devMode, int flags);
        [DllImport("user32.dll")]
        public static extern int EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);
        [StructLayout(LayoutKind.Sequential)]
        public struct DEVMODE {
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
            public string dmDeviceName;
            public short dmSpecVersion;
            public short dmDriverVersion;
            public short dmSize;
            public short dmDriverExtra;
            public int dmFields;
            public short dmPositionX;
            public short dmPositionY;
            public int dmDisplayOrientation;
            public int dmPaperSize;
            public int dmPaperLength;
            public int dmPaperWidth;
            public int dmScale;
            public int dmCopies;
            public int dmDefaultSource;
            public int dmPrintQuality;
            public short dmColor;
            public short dmDuplex;
            public short dmYResolution;
            public short dmTTOption;
            public short dmCollate;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
            public string dmFacename;
            public short dmCharset;
            public int dmPelsWidth;
            public int dmPelsHeight;
            public int dmPelsWidthOld;
            public int dmPelsHeightOld;
        }
    }
"@
    $devMode = New-Object Resolution+DEVMODE
    $devMode.dmDeviceName = "DISPLAY1"
    $devMode.dmSize = [System.Runtime.InteropServices.Marshal]::SizeOf([Resolution+DEVMODE])
    [Resolution]::EnumDisplaySettings(0, 0, [ref]$devMode)
    $devMode.dmPelsWidth = $width
    $devMode.dmPelsHeight = $height
    [Resolution]::ChangeDisplaySettings([ref]$devMode, 0)
    Write-Host "Screen resolution set to $width x $height!"
}

# Function to disable unnecessary services for performance
function Disable-UnnecessaryServices {
    Write-Host "Disabling unnecessary services for better performance..."
    # Example: Disabling the Windows Search service
    Set-Service -Name "WSearch" -StartupType Disabled
    Stop-Service -Name "WSearch" -Force
    Write-Host "Unnecessary services have been disabled."
}

# Function to set up auto-login (Optional)
function Set-AutoLogin {
    Write-Host "Setting up Auto-Login..."
    # Adjust the username and password fields as per your needs
    $username = "YourUsername"
    $password = "YourPassword"
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "1"
    Set-ItemProperty -Path $regPath -Name "DefaultUsername" -Value $username
    Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value $password
    Write-Host "Auto-Login setup completed!"
}

# Call the functions
Enable-RDP
Install-WindowsUpdates
Set-RDPScreenResolution
Disable-UnnecessaryServices
# Set-AutoLogin   # Uncomment if you want Auto-Login enabled

Write-Host "RDP Setup and Optimizations Completed!"
