<#/*
 * @Author: Joseph Iannone
 * @Date: 2023-02-06 23:57:35
 * @Last Modified by: Woz
 * @Last Modified time: 2023-06-21 23:18:20
 */#>


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
        >>      Name = 'Joe'
        >>      Language = 'PowerShell'
        >>      Address = @{
        >>          Street = '123 Fitzwater Street'
        >>          City = 'Philadelphia'
        >>          State = 'Pennsylvania'
        >>          ZIP = 19147
        >>      }
        >>    }
        PS C:> $Ini = $Obj | ConvertTo-Ini
        PS C:> $Ini > Config.ini
        PS C:> cat .\Config.ini
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
  Param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Object]$InputObject,
    [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
    [switch]$Compress
  )
  Process {
    # normalize / validate input object as json
    $Obj = $InputObject | ConvertTo-Json | ConvertFrom-Json
    $Result = [ConvertIni.IniWriter]::Write($Obj, $Compress.IsPresent)
    $Result
  }
}