Describe "New-LogFile" {
    BeforeAll {
        Import-Module ".\pwsh-log.psm1" -force
    }

    Context "no parameter" {

        $noPram = New-LogFile
        It "File Path Should be True" {
            (Test-Path -Path $noPram.File) | Should -Be $true
        }
    }
    Context "Log File" {
        $path = $TestDrive
        $name = "Test123"
        $param = New-LogFile -Path $path -Name $name

        $file = Get-Content -Path $param.File

        It "path should be True" {
            (Test-Path -Path $param.File) | Should -Be $true
        }
        It "content should contain 'Start of Log'" {
            ($file -match 'Start of Log') | Should -Be $true
        }
    }
    Context "Log Object" {
        $path = $TestDrive
        $name = "Test123"
        $param = New-LogFile -Path $path -Name $name

        It "Should contain 'Start of Log'" {
            $param.Logs -match 'Start of Log' | Should -Be $true
        }
    }
    
    AfterAll {
        Remove-Module pwsh-log
    }
}

Describe "Get-LogDate" {
    BeforeAll {
        Import-Module '.\pwsh-log.psm1' -Force
    }

    It "Date should be a datetime value" {
        { [datetime](Get-LogDate) } | Should -Not -Throw
    }

    AfterAll {
        Remove-Module pwsh-log
    }
}

Describe "New-LogEntry" {
    BeforeAll {
        Import-Module '.\pwsh-log.psm1' -Force
    }
    $test = @{
        Note  = 'NOTIFICATION'
        Debug = 'DEBUG'
        WARN  = 'WARNING'
        ERROR = 'ERROR'
    }

    Context "$($test.Note)" {
        $type = $test.Note
        $message = 'Test'
        $noteification = New-LogEntry -Type $type -Message $message

        It "return object type $type" {
            $noteification.Type | Should -Be $type
        }
        It "return Message should be $message" {
            $noteification.Message | Should -Be $message
        }
        It "Return Date should be of type DateTime" {
            ([DateTime]$noteification.Date).GetType() | Should -Be 'DateTime'
        }
    }
    Context "$($test.Warn)" {
        $type = $test.Warn
        $message = 'Test'
        $noteification = New-LogEntry -Type $type -Message $message

        It "return object type $type" {
            $noteification.Type | Should -Be $type
        }
        It "return Message should be $message" {
            $noteification.Message | Should -Be $message
        }
        It "Return Date should be of type DateTime" {
            ([DateTime]$noteification.Date).GetType() | Should -Be 'DateTime'
        }
    }
    Context "$($test.Error)" {
        $type = $test.Error
        $message = 'Test'
        $noteification = New-LogEntry -Type $type -Message $message

        It "return object type $type" {
            $noteification.Type | Should -Be $type
        }
        It "return Message should be $message" {
            $noteification.Message | Should -Be $message
        }
        It "Return Date should be of type DateTime" {
            ([DateTime]$noteification.Date).GetType() | Should -Be 'DateTime'
        }
    }
    Context "$($test.Debug)" {
        $type = $test.Debug
        $message = 'Test'
        $noteification = New-LogEntry -Type $type -Message $message

        It "return object type $type" {
            $noteification.Type | Should -Be $type
        }
        It "return Message should be $message" {
            $noteification.Message | Should -Be $message
        }
        It "Return Date should be of type DateTime" {
            ([DateTime]$noteification.Date).GetType() | Should -Be 'DateTime'
        }
    }

    AfterAll {
        Remove-Module pwsh-log
    }
}

Describe "ConvertTo-LogMessageString" {
    BeforeAll {
        Import-Module '.\pwsh-log.psm1' -Force
    }

    $log = [PSCustomObject]@{
        Date    = '2020-02-23'
        Type    = "NOTIFICATION"
        Message = "test message"
    }
    
    $logString = ConvertTo-LogMessageString -LogObject $log

    It "Date Type Message Should match" {
        $logString | Should -Be ("{0} {1} {2}" -f $log.Date, $log.Type, $log.Message)
    }

    AfterAll {
        Remove-Module pwsh-log
    }
}

Describe "Write-LogError" {
    BeforeAll {
        Import-Module '.\pwsh-log.psm1' -Force
    }

    Context "No LogObject Found" {       
        It "No LogObject should Throw" {
            {Write-LogError -Message "log"} | Should -Throw
        }
    }

    Context "LogObject" {

        $data = @{
            File = (Join-Path -Path $TestDrive -ChildPath "test.log")
            Logs = @(
                "Test"
            )
        }
        $testMessage = "Test2"

        $log = Write-LogError -Message $testMessage -LogObject $data
        It "Error Log Object Logs should match $testMessage" {
            $log.Logs[($log.Logs.count - 1)] | Should -Match $testMessage
        }
        It "Error Log file should contain '$("ERROR {0}" -f $testMessage)'" {
            (Get-Content $log.File) | Should -Match $("ERROR {0}" -f $testMessage)
        }
    }

    AfterAll {
        Remove-Module pwsh-log
    }
}

Describe "Write-LogWarning" {
    BeforeAll {
        Import-Module '.\pwsh-log.psm1' -Force
    }

    Context "No LogObject Found" {       
        It "No LogObject should Throw" {
            {Write-LogWarning -Message "log"} | Should -Throw
        }
    }

    Context "LogObject" {

        $data = @{
            File = (Join-Path -Path $TestDrive -ChildPath "test.log")
            Logs = @(
                "Test"
            )
        }
        $testMessage = "Test2"

        $log = Write-LogWarning -Message $testMessage -LogObject $data
        It "Warning Log Object Logs should match $testMessage" {
            $log.Logs[($log.Logs.count - 1)] | Should -Match $testMessage
        }
        It "Warning Log file should contain '$("WARNING {0}" -f $testMessage)'" {
            (Get-Content $log.File) | Should -Match $("WARNING {0}" -f $testMessage)
        }
    }

    AfterAll {
        Remove-Module pwsh-log
    }
}

Describe "Write-LogNotification" {
    BeforeAll {
        Import-Module '.\pwsh-log.psm1' -Force
    }

    Context "No LogObject Found" {       
        It "No LogObject should Throw" {
            {Write-LogNotification -Message "log"} | Should -Throw
        }
    }

    Context "LogObject" {

        $data = @{
            File = (Join-Path -Path $TestDrive -ChildPath "test.log")
            Logs = @(
                "Test"
            )
        }
        $testMessage = "Test2"

        $log = Write-LogNotification -Message $testMessage -LogObject $data
        It "Notification Log Object Logs should match $testMessage" {
            $log.Logs[($log.Logs.count - 1)] | Should -Match $testMessage
        }
        It "Notification Log file should contain '$("NOTIFICATION {0}" -f $testMessage)'" {
            (Get-Content $log.File) | Should -Match $("NOTIFICATION {0}" -f $testMessage)
        }
    }

    AfterAll {
        Remove-Module pwsh-log
    }
}

Describe "Write-LogDebug" {
    BeforeAll {
        Import-Module '.\pwsh-log.psm1' -Force
    }

    Context "No LogObject Found" {       
        It "No LogObject should Throw" {
            {Write-LogDebug -Message "log"} | Should -Throw
        }
    }

    Context "LogObject" {

        $data = @{
            File = (Join-Path -Path $TestDrive -ChildPath "test.log")
            Logs = @(
                "Test"
            )
        }
        $testMessage = "Test2"

        $log = Write-LogDebug -Message $testMessage -LogObject $data
        It "Debug Log Object Logs should match $testMessage" {
            $log.Logs[($log.Logs.count - 1)] | Should -Match $testMessage
        }
        It "Debug Log file should contain '$("DEBUG {0}" -f $testMessage)'" {
            (Get-Content $log.File) | Should -Match $("DEBUG {0}" -f $testMessage)
        }
    }

    AfterAll {
        Remove-Module pwsh-log
    }
}

