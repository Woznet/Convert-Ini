<#/*
 * @Author: Joseph Iannone
 * @Date: 2023-02-06 12:35:13
 * @Last Modified by: Woz
 * @Last Modified time: 2023-06-21 23:18:20
 */#>


Function ConvertFrom-Ini {
  <#
    .SYNOPSIS
        Convert INI text to PSCustomObject

    .DESCRIPTION
        Convert INI text to PSCustomObject

    .PARAMETER InputObject
        A INI string to convert to PSCustomObject

    .EXAMPLE
        PS C:> $Ini = "
        >> Language=Powershell
        >> Name=Joe
        >> [Address]
        >> ZIP=19147
        >> Street=123 Fitzwater Street
        >> State=Pennsylvania
        >> "
        PS C:> $Obj = $Ini | ConvertFrom-Ini
        PS C:> $Obj


        Language   Name Address
        --------   ---- -------
        Powershell Joe  @{ZIP=19147; Street=123 Fitzwater Street; City=Philadelphia; State=Pennsylvania}


        PS C:> $Obj.Name
        Joe
        PS C:> $Obj.Address.Street
        123 Fitzwater Street

    .EXAMPLE
        PS C:> $Obj1 = Get-Content .\Config.ini | ConvertFrom-Ini
        PS C:> $Obj2 = Get-Content -Raw .\Config.ini | ConvertFrom-Ini
        PS C:> $Obj3 = ConvertFrom-Ini -InputObject (Get-Content .\Config.ini)

    #>
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  Param(
    [Parameter(Mandatory = $false, ValueFromPipeline)]
    [string]$InputObject
  )
  Begin {
    # [System.Collections.ArrayList]$InputBuffer = [System.Collections.ArrayList]::new()
    $InputBuffer = [System.Collections.Generic.List[string]]::new()
  }
  Process {
    try {
      [void]$InputBuffer.Add([string]$InputObject)
    }
    catch {
      [System.Management.Automation.ErrorRecord]$e = $_
      [PSCustomObject]@{
        Type      = $e.Exception.GetType().FullName
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Message   = $e.InvocationInfo.PositionMessage
      }
    }
  }
  End {
    [string]$InputStr = $InputBuffer -join [Environment]::NewLine
    [PSCustomObject]$Result = [ConvertIni.IniParser]::Parse($InputStr)
    $Result
  }
}