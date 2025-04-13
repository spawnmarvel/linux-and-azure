# Function to log information to a file
# Function to append to the log file
function Write-Log {
    param(
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    $logFile = "../log.txt"
    Add-Content -Path $logFile -Value $logEntry
}

$resourceGroup = "Rg-iac-deploy-linux-fun-12"

try {
    $rv = Get-AzResourceGroup -Name $resourceGroup | Remove-AzResourceGroup -Force -AsJob
    Write-Log $rv.ToString()
    
}
catch [System.InvalidOperationException] {
    <#Do this if a terminating exception happens#>
    Write-Log "Caught an InvalidOperationException: $($_.Exception.Message)"
}
catch {
    Write-Log "An unexpected error occurred: $($_.Exception.Message)"
}
finally {
    <#Do this after the try block regardless of whether an exception occurred or not#>
    Write-Log "Done"
}
