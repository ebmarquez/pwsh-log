
$Script:Logs = [pscustomobject]@{ File = ""; Logs = @() }

function New-LogFile {
    <#
        .SYNOPSIS
        Start a log files and return an object

        .OUTPUTS
        psobject (File, Logs), File is the path the to log file, and Logs is the log entries.
    #>
    [CmdletBinding()]
    param (

        # c:\temp\
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path = (New-TempDirectory),

        # File Name
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name = (New-Guid).Guid
    )

    try {
        $lF = Join-Path -Path $Path -ChildPath $("{0}.log" -f $Name)
        $logMessage = New-LogEntry -Message "Start of Log"
        $log = ConvertTo-LogMessageString -LogObject $logMessage
        Out-File -FilePath $lF -Encoding utf8 -InputObject $log
    }
    catch {
        
        # Failed to resovle the path
        if (-Not (Test-Path -Path $Path)) {
            $dir = New-Item -Path $Path -ItemType Directory -Force
            $lF = Join-Path -Path $dir -ChildPath (New-Guid).guid -AdditionalChildPath ".log"
        }
    }
    
    $Script:Logs.File = $lf 
    $Script:Logs.Logs = $logMessage
    return $Script:Logs
}

function Get-LogDate {
    <#
        .SYNOPSIS
        Foramts that date to a string

        .OUTPUTS
        string containg the date and time 
    #>
    [CmdLetBinding()]
    param()
    
    return (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

function New-LogEntry {
    <#
        .SYNOPSIS
        Entry for a log file.

        .OUTPUTS
        PSCustomObject that contains Date, Type, Message
    #>
    [CmdletBinding()]
    param (

        # Type of Log Entry
        [Parameter(Mandatory = $false)]
        [ValidateSet("DEBUG", "ERROR", "WARNING", "NOTIFICATION")]
        [string]
        $Type = "NOTIFICATION",

        # Message in the log
        [Parameter(Mandatory = $false)]
        [string]
        $Message
    )

    $logMessage = [pscustomobject]@{
        Date    = (Get-LogDate)
        Type    = $type
        Message = $Message
    }
    return $logMessage
}

function ConvertTo-LogMessageString {
    [CmdLetBinding()]
    param(

        # Log Object
        [Parameter(Mandatory = $true)]
        [psobject]
        $LogObject
    )

    return ("{0} {1} {2}" -f $logObject.Date, $LogObject.Type, $LogObject.Message)
}

function New-TempDirectory {
    <#
        .SYNOPSIS
        This will return a new temp directory in $ENV:Temp with a GUID for a folder.

        .INPUTS
        None

        .OUTPUTS
        System.Object
    #>
    [CmdletBinding()]
    param ()

    $tempDir = Get-TempLocation
    $temp = Join-Path -Path $tempDir -ChildPath (New-Guid).Guid

    return $(New-Item -Path $temp -ItemType Directory)
}

function Get-TempLocation {
    <#
        .SYNOPSIS
        Determine the OS type and assign a temp location.

        .OUTPUTS
        string of the file path.
    #>
    [CmdLetBinding()]
    param ()

    switch ($PSVersionTable.Platform) {
        Unix { $temp = '/tmp' }
        Win32NT { $temp = $ENV:TEMP }
    }

    if (-Not (Test-Path -Path $temp)) {
        New-Item -Path $temp -ItemType Directory | Out-Null
    }
    return $temp
}

function Get-LogFile {
    [CmdLetBinding()]
    param(

        # LogObject
        [Parameter(Mandatory = $false)]
        [psobject]
        $LogObject = $Script:Logs
    )

    try {
        return (Get-Content $LogObject.File)
    }
    catch {
        Write-Error -Message "No LogObject found."
    }
}

function Write-LogError {
    [CmdLetBinding()]
    param (

        # Error Message
        [parameter(Mandatory = $false)]
        [string]
        $Message,

        # Input Log Object
        [parameter(Mandatory = $false)]
        [psobject]
        $LogObject = $Script:Logs
    )

    try {
        $logMessage = New-LogEntry -Type ERROR -Message $Message
        $log = ConvertTo-LogMessageString -LogObject $logMessage
        Out-File -FilePath $LogObject.File -Encoding utf8 -InputObject $log -Append
        $LogObject.Logs += $LogMessage
    }
    catch {
        $message = "Log was not object was not found.  New-LogFile must be run first or a LogObject must be used with this method."
        Write-Error -Message $message -ErrorAction Stop
    }
}

function Stop-Log {
    param(
        
        # Log object
        [parameter(Mandatory = $false)]
        [psobject]
        $LogObject = $Script:Logs
    )
    try {
        Write-LogNote -Message "End of Log" -LogObject $LogObject
        $Script:Logs = $null
    }
    catch {
        $message = "Log was not object was not found."
        Write-Error -Message $message    
    }
}

function Remove-Log {
    param(
        # Log object
        [parameter(Mandatory = $false)]
        [psobject]
        $LogObject = $Script:Logs
    )
    try {
        Remove-Item -Path $LogObject.File -Force
        $LogObject = $null
    }
    catch {
        $message = "Log was not object was not found."
        Write-Error -Message $message    
    }
}