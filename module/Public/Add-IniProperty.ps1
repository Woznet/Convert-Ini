<#/*
 * @Author: Joseph Iannone
 * @Date: 2023-02-10 22:52:35
 * @Last Modified by: Woz
 * @Last Modified time: 2023-06-21 23:18:20
 */#>


Function Add-IniProperty {
  <#
    .SYNOPSIS
        Adds or Updates properties from an input object to a specified ini file

    .DESCRIPTION
        Adds or Updates properties from an input object to a specified ini file

    .PARAMETER InputObject
        Object containing properties to add or update

    .EXAMPLE
        PS > .\test001.ini | Add-IniProperty -InputObject $MyObj
        PS > Add-IniProperty -Path .\test001.ini -InputObject $MyObj

    .EXAMPLE
        PS > type .\test.ini
        Test1 = hello
        Test2 = world

        [TestSection]
        test1 = hello
        test2 = world

        PS > $MyObj = @{ TestSection = @{ test1 = "updated"; }; TestSection2 = @{ hello = "world"; } }
        PS > .\test.ini | Add-IniProperty -InputObject $MyObj
        PS > type .\test.ini
        Test1 = hello
        Test2 = world

        [TestSection]
        test1 = updated
        test2 = world

        [TestSection2]
        hello = world

        PS >

    #>
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]$Path,
    [Parameter(Mandatory, ValueFromPipeline = $false)]
    [Object]$InputObject
  )
  Process {
    # Get ini contenet as object from specified path
    [PSCustomObject]$Obj = Get-Content $Path | ConvertFrom-Ini
    # normalize input object
    [PSCustomObject]$InputObject = $InputObject | ConvertTo-Ini | ConvertFrom-Ini
    # iterate over each input property
    $InputObject.PSObject.Properties | ForEach-Object {
      # if input property already exists
      If ($Obj.PSObject.Properties[$_.Name]) {
        $CurrentObjName = $_.Name
        $ObjItemType = $Obj.$CurrentObjName.GetType()
        # if the input property and file property values are same type but not string
        If ($ObjItemType -eq $_.Value.GetType() -and $ObjItemType.Name -ne 'String') {
          # iterate over each property of the child object
          $_.Value.PSObject.Properties | ForEach-Object {
            # update existing property with matching input porperty value
            $Obj.$CurrentObjName.PSObject.Properties[$_.Name].Value = $_.Value
          }
        }
        Else {
          # when the type is different just overwrite
          # In this case either an object is being replaced with a string or a string with an object
          $Obj.PSObject.Properties[$_.Name].Value = $_.Value
        }
      }
      Else {
        # add new property
        $Obj | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
      }
      # Write changes to specified ini file
      $Obj | ConvertTo-Ini | Out-File -FilePath $Path -Force
    }
  }
}