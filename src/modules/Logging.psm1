# Logging Module for XML Diff Analysis
# PowerShell 7.5.x Logging Functions

function Write-DiffLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Level = 'Information',
        
        [Parameter()]
        [string]$LogPath = "xml-diff.log"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    try {
        Add-Content -Path $LogPath -Value $logEntry -ErrorAction Stop
        if ($Level -eq 'Error') {
            Write-Error $Message
        }
        elseif ($Level -eq 'Warning') {
            Write-Warning $Message
        }
        else {
            Write-Verbose $Message
        }
    }
    catch {
        Write-Warning "Failed to write to log file: $_"
    }
}

Export-ModuleMember -Function Write-DiffLog