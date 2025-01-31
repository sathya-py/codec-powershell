param (
    [Parameter(Mandatory = $true)]
    [string]$Directory,
    [string[]]$Skip = @(),
    [string[]]$SkipFolders = @(),
    [string[]]$Extensions = @()
)

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
                Write-Host "Found file: $($_.FullName)"
                
                # Add valid file path to list
                $fileList += $_.FullName
            } else {
                Write-Host "Excluded file: $($_.FullName)"
            }
        }
    }
    
    return $fileList
}

# Function to process file content
function Process-File {
    param (
        [string]$FilePath
    )
    
    if ([string]::IsNullOrWhiteSpace($FilePath)) {
        Write-Host "Skipping empty file path." 'WARNING'
        return
    }

    try {
        # Read file content and output it to console
        Write-Host "Processing file: $FilePath"  # Log which file is being processed.
        $content = Get-Content -Path $FilePath -ErrorAction Stop | Out-String
        
        # Output the content of the file
        Write-Host "Content of ${FilePath}:`n${content}"
        
    } catch {
        Write-Host "Error processing file '$FilePath': $_" 'ERROR'
    }
}

# Main execution logic
Write-Host "Starting file search in '$Directory'"

$fileList = Find-Files -Path $Directory `
                        -ValidExtensions $validExtensions `
                        -SkipNames $Skip `
                        -SkipFolders $SkipFolders

Write-Host "Found $(($fileList.Count)) matching files."

if ($fileList.Count -gt 0) {
   foreach ($file in $fileList) {
       Process-File -FilePath $file  # Call Process-File for each found file.
   }
} else {
   Write-Host "No matching files found." 'WARNING'
}
