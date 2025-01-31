# CodeCollator

## Overview

**CodeCollator** is a PowerShell script designed to recursively collect all text-format source files from a specified directory into a single text file. This consolidated file can be used for various purposes, such as presenting the project to an AI, printing, or converting to PDF for documentation. This tool is particularly useful for developers who want to compile their source files into a single document for easier sharing and review.

## Features

- Recursively collects text-format source files from a specified directory.
- Allows users to skip specific files and folders.
- Processes the content of each found file and combines it into one output file.
- Generates a summary file containing the contents of all processed files.
- Provides logging for actions taken and errors encountered.

## Requirements

- PowerShell 5.1 or later (Windows) or PowerShell Core (cross-platform).
- Access to the directory containing the source files.

## Usage

### Parameters

The script accepts the following parameters:

- `-Directory`: **(Mandatory)** The path to the directory where the search will be performed.
- `-Output`: **(Optional)** The name of the output summary file. Default is `summary.txt`.
- `-Skip`: **(Optional)** A list of file names or extensions to skip during the search (e.g., `ff`, `fd`).
- `-SkipFolders`: **(Optional)** A list of folder names to skip during the search (e.g., `assets`).
- `-Extensions`: **(Optional)** A list of valid file extensions to look for (e.g., `.txt`, `.cs`, `.py`). If not specified, defaults to common text formats.

### Example Command

To run the script, use the following command:

```
.\CodeCollator.ps1 -Directory 'D:/Workspace/YourProject/' -SkipFolders 'assets' -Extensions '.txt', '.cs', '.py' -Output 'summary.txt'
```

### Output

The script generates a summary file (`summary.txt`) that includes:

- The content of each processed source file.
- Any errors encountered during processing.

## Installation

1. Clone this repository to your local machine using:

   ```
   git clone https://github.com/sathya-py/codec-powershell.git
   ```

2. Navigate to the project directory:

   ```
   cd codec-powershell
   ```

3. Open PowerShell and run the script with appropriate parameters.

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This project was developed with assistance from an AI language model created by OpenAI, which provided guidance and support throughout its creation. Special thanks to all contributors and users who have helped improve this script!
