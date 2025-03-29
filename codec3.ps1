<#
.SYNOPSIS
    Searches for files in a specified directory while skipping certain tools and folders, processes ths eir contents, and creates a summary file.

.DESCRIPTION
    This script recursively searches for files in the given directory based on specified valid extensions.
    It can skip specific tools, files, and folders. The script detects the encoding of text files,
    processes both regular text and gzip-compressed files, and generates a summary file containing the 
    paths and contents of the processed files.

.PARAMETER Directory
    The directory to search in. This parameter is required.

.PARAMETER Output
    The name of the output summary file. Default is 'summary.txt'.

.PARAMETER Skip
    A list of file names or extensions to skip during the search (e.g., ff fd). This parameter is optional.

.PARAMETER SkipFolders
    A list of folder names to skip during the search (e.g., folder1 folder2). This parameter is optional.

.PARAMETER Extensions
    A list of valid file extensions to look for (e.g., .txt .dart .json). If not specified, defaults to 
    common text-related extensions.

.EXAMPLE
    .\YourScript.ps1 -Directory 'C:\path\to\directory' -Output 'summary.txt' -Extensions '.dart' -Skip 'ff', 'fd' -SkipFolders 'assets'
    
    This command searches for `.dart` files in 'C:\path\to\directory', skips files named 'ff' and 'fd',
    and ignores any files in the 'assets' folder, writing the results to 'summary.txt'.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Directory,
    [string]$Output = 'summary.txt',
    [string[]]$Skip = @(),
    [string[]]$SkipFolders = @(),
    [string[]]$Extensions = @()
)

# Set up logging function
function Log-Message {
    param (
        [string]$Message,
        [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "$timestamp - $Level - $Message"
}

# Validate arguments
if (-Not (Test-Path $Directory -PathType Container)) {
    throw "The provided directory '$Directory' does not exist."
}

# Prepare valid extensions
$validExtensions = if ($Extensions) { @($Extensions) } else { @('.dart') }

# Function to find files
function Find-Files {
    param (
        [string]$Path,
        [string[]]$ValidExtensions,
        [string[]]$SkipNames,
        [string[]]$SkipFolders
    )
    
    $fileList = @()
    
    Get-ChildItem -Path $Path -Recurse | ForEach-Object {
        # Log every file and folder being checked
        Write-Host "Checking: $($_.FullName)"
        
        if ($_.PSIsContainer -eq $false) {
            $extension = $_.Extension.ToLower()
            
            # Log the extension and base name for debugging
            Write-Host "File Extension: $extension, Base Name: $($_.BaseName)"
            
            # Check if this file should be included
            if ($ValidExtensions -contains $extension -and 
                -not ($SkipNames -contains $_.BaseName) -and 
                -not ($SkipFolders -contains $_.Parent.Name)) {
                
                # Log found file
                Log-Message "Found file: $($_.FullName)"
                
                # Add valid file path to list
                $fileList += $_.FullName
            } else {
                Write-Host "Excluded file: $($_.FullName)"
            }
        }
    }
    
    return $fileList
}

# Function to process file content and write to output
function Process-File {
    param (
        [string]$FilePath,
        [string]$OutputFile
    )
    
    if ([string]::IsNullOrWhiteSpace($FilePath)) {
        Log-Message "Skipping empty file path." 'WARNING'
        return
    }

    try {
        # Read file content
        Log-Message "Processing file: $FilePath"  # Log which file is being processed.
        $content = Get-Content -Path $FilePath -ErrorAction Stop | Out-String
        
        # Prepare output for the summary file
        Add-Content -Path $OutputFile -Value "Content of ${FilePath}:`n$content`n"
        
    } catch {
        Log-Message "Error processing file '$FilePath': $_" 'ERROR'
        Add-Content -Path $OutputFile -Value "Error processing file '$FilePath': $_`n"
    }
}

# Main execution logic
Log-Message "Starting file search in '$Directory'"

# Create or clear the output file at the start of the script
Set-Content -Path $Output -Value "" 

$fileList = Find-Files -Path $Directory `
                        -ValidExtensions $validExtensions `
                        -SkipNames $Skip `
                        -SkipFolders $SkipFolders

Log-Message "Found $(($fileList.Count)) matching files."

if ($fileList.Count -gt 0) {
   foreach ($file in $fileList) {
       Process-File -FilePath $file -OutputFile $Output  # Call Process-File for each found file.
   }
} else {
   Log-Message "No matching files found." 'WARNING'
   Add-Content -Path $Output -Value "No matching files found.`n"
}

Log-Message "Summary created: '$Output'"
