Describe "New-logfile" {
    BeforeAll {
        Import-Module ".\pwsh-logs.psm1" -force
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
            (Test-Path -Path $param.File)| Should -Be $true
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
            $param.Logs -match 'Start of Log'| Should -Be $true
        }
    }
    
    AfterAll {
        Remove-Module pwsh-logs
    }
}

Describe "Get-LogDate" {
    BeforeAll {
        Import-Module '.\pwsh-logs.psm1' -Force
    }

    It "date" {
        $date = Get-Date -Format "yyyy-MM-dd"
        Get-Logdate | Should -Match $date
    }
    AfterAll {
        Remove-Item 'pwsh-logs'
    }
}