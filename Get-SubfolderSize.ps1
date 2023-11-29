<#
.SYNOPSIS
    Get the size of all subfolders in a folder
#>
param (
    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$Path,

    [Parameter()]
    [ValidateSet("MB", "GB", "B")]
    [string]$Unit = "MB"
)

function Get-SubfolderSize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$Path,

        [Parameter()]
        [ValidateSet("MB", "GB", "B")]
        [string]$Unit = "MB"
    )

    $folders = Get-ChildItem -Path $Path -Directory
    foreach ($folder in $folders) {
        $size = Get-ChildItem -Path $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        
        [pscustomobject]@{
            Name = $folder.Name
            Size = if($Unit -eq "B") {
                [System.Convert]::ToUInt64($size.Sum)
            } else {
               '{0:N1} {1}' -f ($size.Sum / (1MB, 1GB)[$Unit -eq "GB"]), $Unit
            }
        }
    }
}

# Call the Get-SubfolderSize function with the Path and Unit parameters
& Get-SubfolderSize -Path $Path -Unit $Unit

