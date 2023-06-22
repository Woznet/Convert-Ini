<#/*
 * @Author: Joseph Iannone
 * @Date: 2023-02-07 00:15:52
 * @Last Modified by: Woz
 * @Last Modified time: 2023-06-21 23:18:20
 */#>

# Global variable for module root directory
$PSModuleRoot = $PSScriptRoot

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSModuleRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSModuleRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($Import in @($Public + $Private)) {
  Try {
    . $Import.FullName
  }
  Catch {
    [System.Management.Automation.ErrorRecord]$e = $_
    [PSCustomObject]@{
      Type      = $e.Exception.GetType().FullName
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Message   = $e.InvocationInfo.PositionMessage
    }
    Write-Error -Message "Failed to import function $($Import.FullName): $_"
  }
}

Export-ModuleMember -Function $Public.Basename