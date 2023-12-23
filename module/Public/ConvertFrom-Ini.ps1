function ConvertFrom-Ini {
    <#
.SYNOPSIS
    Converts INI file content to a PowerShell object.

.DESCRIPTION
    The ConvertFrom-Ini function parses the content of an INI file and converts it into a PowerShell object.
    It can take the content of an INI file either directly as a string or from a file path.

.PARAMETER FilePath
    Specifies the path to the INI file. The content of the file at the specified path will be converted to a PowerShell object.

.PARAMETER IniContent
    Specifies the INI content as a string. The string content will be converted to a PowerShell object.

.EXAMPLE
    PS C:\> ConvertFrom-Ini -FilePath "C:\path\to\yourfile.ini"
    Converts the content of the INI file located at "C:\path\to\yourfile.ini" to a PowerShell object.

.EXAMPLE
    PS C:\> ConvertFrom-Ini -IniContent "[Section1]`nKey1=Value1`nKey2=Value2"
    Converts the provided INI content string to a PowerShell object.

.INPUTS
    String
    You can pipe a string to this function.

.OUTPUTS
    PSCustomObject
    The function returns a PowerShell custom object representing the parsed INI content.

.NOTES
    Author: Woz
    Version: 1.0
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'FilePath')]
        [ValidateScript({
                if (-not (Test-Path -Path $_ -PathType Leaf)) {
                    throw ('{0} - Was not found or is in accessible' -f $_)
                }
                return $true
            })]
        [string]$FilePath,

        [Parameter(Mandatory, Position = 0, ParameterSetName = 'IniContent')]
        [string]$IniContent
    )

    begin {
        # Load the ConvertIni assembly if it's not already loaded
        try {
            [void][ConvertIni.IniParser]
        }
        catch {
            Write-Verbose 'Loading Assembly ConvertIni.dll'
            Add-Type -Path $PSScriptRoot\..\lib\ConvertIni.dll
        }
    }

    process {
        # Read from file if FilePath is provided
        if ($FilePath) {
            $IniContent = Get-Content -Path $FilePath -Raw
        }

        try {
            # Parse the INI content into a PowerShell object
            $PsObject = [ConvertIni.IniParser]::Parse($IniContent)
            return $PsObject
        }
        catch {
            [System.Management.Automation.ErrorRecord]$e = $_
            [PSCustomObject]@{
                Exception = $e.Exception.Message
                Reason = $e.CategoryInfo.Reason
                Target = $e.CategoryInfo.TargetName
                Script = $e.InvocationInfo.ScriptName
                Message = $e.InvocationInfo.PositionMessage
            }
            throw $_
        }
    }
}
