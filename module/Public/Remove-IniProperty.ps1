<#/*
 * @Author: Joseph Iannone
 * @Date: 2023-02-10 18:49:37
 * @Last Modified by: Woz
 * @Last Modified time: 2023-06-21 23:18:20
 */#>


Function Remove-IniProperty {
  <#
    .SYNOPSIS
        Remove Sections or properties from ini files

    .DESCRIPTION
        Remove Sections or properties from ini files

    .PARAMETER $Path
        Path to ini file

    .PARAMETER $Section
        Section key in ini file to remove or remove from

    .PARAMETER $Property
        Property key in ini file to remove

    .EXAMPLE
        PS > Remove-IniProperty -Path .\test001.ini -Section "Model" -Property "test"

    .EXAMPLE
        PS > type .\test.ini
        Test1 = hello
        Test2 = world

        [TestSection]
        test1 = updated
        test2 = world

        [TestSection2]
        hello = world

        PS > .\test.ini | Remove-IniProperty -Section "TestSection" -Property "test1"
        PS > .\test.ini | Remove-IniProperty -Section "TestSection2"
        PS > .\test.ini | Remove-IniProperty -Property "Test2"
        PS > type .\test.ini
        Test1 = hello

        [TestSection]
        test2 = world

        PS >

    #>
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$Path,
    [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
    [string]$Property,
    [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
    [string]$Section
  )
  Process {
    try {
      # get object
      [PSCustomObject]$Obj = Get-Content $Path | ConvertFrom-Ini
      If ($Section) {
        If ($Property) {
          if ($null -eq $Obj.$Section.$Property) {
            throw "No key '$($Section).$($Property)' found in $($Path)"
          }
          $Obj.$Section.PSObject.Properties.Remove($Property)
        }
        Else {
          if ($null -eq $Obj.$Section) {
            throw "No key '$($Section)' found in $($Path)"
          }
          $Obj.PSObject.Properties.Remove($Section)
        }
      }
      ElseIf ($Property) {
        if ($null -eq $Obj.$Property) {
          throw "No key '$($Property)' found in $($Path)"
        }
        $Obj.PSObject.Properties.Remove($Property)
      }
      # Write changes to specified ini file
      $Obj | ConvertTo-Ini | Out-File -FilePath $Path -Force
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
}