Function ConvertTo-Ini {
    <#
.SYNOPSIS
Convert PSObjects to INI text

.DESCRIPTION
Convert PSObjects to INI text

.PARAMETER InputObject
A PSObject to convert to INI

.EXAMPLE
PS C:> $Obj = @{
  Name = 'Joe'
  Language = 'PowerShell'
  Address = @{
      Street = '123 Fitzwater Street'
      City = 'Philadelphia'
      State = 'Pennsylvania'
      ZIP = 19147
  }
}
PS C:> $Ini = $Obj | ConvertTo-Ini
PS C:> $Ini | Out-File -FilePath Config.ini
PS C:> Get-Content .\Config.ini
Name=Joe
Language=PowerShell

[Address]
ZIP=19147
Street=123 Fitzwater Street
State=Pennsylvania
City=Philadelphia

#>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Object]$InputObject,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [switch]$Compress
    )
    Process {
        # normalize / validate input object as json
        try {
            $Obj = $InputObject | ConvertTo-Json | ConvertFrom-Json
            $Result = [ConvertIni.IniWriter]::Write($Obj, $Compress.IsPresent)
            $Result
        }
        catch {
            Write-Error -ErrorRecord $_
        }
    }
}
