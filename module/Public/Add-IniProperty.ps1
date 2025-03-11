Function Add-IniProperty {
    <#
.SYNOPSIS
Adds or Updates properties from an input object to a specified ini file

.DESCRIPTION
Adds or Updates properties from an input object to a specified ini file

.PARAMETER InputObject
Object containing properties to add or update

.EXAMPLE
PS > Get-Item .\test001.ini | Add-IniProperty -InputObject $MyObj
PS > Add-IniProperty -Path .\test001.ini -InputObject $MyObj

.EXAMPLE
PS > Get-Content .\test.ini
Test1 = hello
Test2 = world

[TestSection]
test1 = hello
test2 = world

PS > $MyObj = @{ TestSection = @{ test1 = 'updated'; }; TestSection2 = @{ hello = 'world'; } }
PS > Get-Content .\test.ini | Add-IniProperty -InputObject $MyObj
PS > Get-Content .\test.ini
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
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({
            if (-not (Test-Path $_ -PathType Leaf)) {
                throw ([System.IO.FileNotFoundException]::new('Unable to locate file.',$_))
            }
            return $true
        })]
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
                        try {
                            $Obj.$CurrentObjName.PSObject.Properties[$_.Name].Value = $_.Value
                        }
                        catch {
                            Write-Error -ErrorRecord $_
                        }
                    }
                }
                Else {
                    # when the type is different just overwrite
                    # In this case either an object is being replaced with a string or a string with an object
                    try {
                        $Obj.PSObject.Properties[$_.Name].Value = $_.Value
                    }
                    catch {
                        Write-Error -ErrorRecord $_
                    }
                }
            }
            Else {
                # add new property
                try {
                    $Obj.PSObject.Properties.Add([psnoteproperty]::new($_.Name, $_.Value))
                }
                catch {
                    Write-Error -ErrorRecord $_
                }
            }
            # Write changes to specified ini file
            $Obj | ConvertTo-Ini | Out-File -FilePath $Path -Force
        }
    }
}
