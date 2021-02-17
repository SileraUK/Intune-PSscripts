<#
        .SYNOPSIS
            Removes shortcuts from user's desktop.
            Use with Proactive Remediations or PowerShell scripts
 
        .NOTES
 	        NAME: Remediate-DuplicateShortcuts.ps1
	        VERSION: 1.0
	        AUTHOR: Aaron Parker
	        TWITTER: @stealthpuppy
 
        .LINK
            http://stealthpuppy.com
    #>
[CmdletBinding()]
Param ()

#region Functions
Function Get-KnownFolderPath {
    <#
        .SYNOPSIS
            Gets a known folder's path using GetFolderPath.
        .PARAMETER KnownFolder
            The known folder whose path to get. Validates set to ensure only known folders are passed.
        .NOTES
            https://stackoverflow.com/questions/16658015/how-can-i-use-powershell-to-call-shgetknownfolderpath
    #>
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('AdminTools', 'ApplicationData', 'CDBurning', 'CommonAdminTools', 'CommonApplicationData', 'CommonDesktopDirectory', 'CommonDocuments', 'CommonMusic', `
                'CommonOemLinks', 'CommonPictures', 'CommonProgramFiles', 'CommonProgramFilesX86', 'CommonPrograms', 'CommonStartMenu', 'CommonStartup', 'CommonTemplates', `
                'CommonVideos', 'Cookies', 'Desktop', 'DesktopDirectory', 'Favorites', 'Fonts', 'History', 'InternetCache', 'LocalApplicationData', 'LocalizedResources', 'MyComputer', `
                'MyDocuments', 'MyMusic', 'MyPictures', 'MyVideos', 'NetworkShortcuts', 'Personal', 'PrinterShortcuts', 'ProgramFiles', 'ProgramFilesX86', 'Programs', 'Recent', `
                'Resources', 'SendTo', 'StartMenu', 'Startup', 'System', 'SystemX86', 'Templates', 'UserProfile', 'Windows')]
        [System.String] $KnownFolder
    )
    [Environment]::GetFolderPath($KnownFolder)
}
#endregion

# Get shortcuts from the Public desktop
try {
    $Path = Get-KnownFolderPath -KnownFolder "Desktop"
    $Filter = "$Path\Microsoft Edge*copy*.lnk", "$Path\Microsoft Teams*copy*.lnk"
    $Shortcuts = Get-ChildItem -Path $Filter
}
catch {
    Write-Host "Failed when enumerating shortcuts at: $Path."
    Write-Host $_.Exception.Message
    Exit 1
}    

try {
    If ($Shortcuts.Count -gt 0) { $Shortcuts | Remove-Item -Force -ErrorAction "SilentlyContinue" }
}
catch {
    Write-Host "Failed when deleting shortcuts at: $Path."
    Write-Host $_.Exception.Message
    Exit 1
}

# All settings are good exit cleanly
# Output all shortcuts in a list with line breaks in a single output
ForEach ($Shortcut in $Shortcuts) {
    $Output += "$($Shortcut.FullName)`n"
}
Write-Host "Removed shortcuts:`n$Output"
Exit 0
