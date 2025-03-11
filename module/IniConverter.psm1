#Get public and private function definition files.
$Public = Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue

#Dot source the files
Foreach ($Import in $Public) {
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