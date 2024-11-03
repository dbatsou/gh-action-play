$gitShowOutput = git diff HEAD~1 example2.sql| Out-String
# Check if the gitShowOutput is provided
if (-not $gitShowOutput) {
    Write-Error "No input provided. Please provide the output of the git show command."
    git diff head~1
    exit
}

# Arrays to hold the lines starting with + or -
$matchingLines = @()

# Split the output into lines and process each line
$gitShowOutputLines = $gitShowOutput -split "`n"

#Write-Output "Debug: Extracting lines that start with '+' or '-'..."

foreach ($line in $gitShowOutputLines) {
    # Trim leading and trailing whitespace
    $line = $line.Trim()

    # Check if the first character of the line is + or -
    if ($line.Length -gt 0 -and ($line[0] -eq '-')) {
        # Add the line to the matchingLines array
        $matchingLines += $line
    }
}

# Print the matching lines for debugging
#Write-Output "Debug: Lines that start with '+' or '-':"
#$matchingLines | ForEach-Object { Write-Output $_ }

# Array to hold the Name values from matched lines
$nameValues = @()

#Write-Output "Debug: Extracting Name values and removing escape characters..."

foreach ($line in $matchingLines) {
    # Remove the leading + or - sign
    $cleanLine = $line.Substring(1).Trim()

    # Find the first occurrence of a string argument wrapped in single quotes
    if ($cleanLine -match "N'([^']+)'") {
        # Extract the matched value (Name)
        $name = $matches[1]

        # Remove any escape characters from the Name
        $cleanName = $name -replace '\\', ''  # Remove backslashes

        # Add the cleaned Name value to the nameValues array
        $nameValues += $cleanName

        # Output only the cleaned Name
        #Write-Output $cleanName
    }
}

# Print the extracted Name values for debugging
#Write-Output "Debug: Extracted Name values:"
#$nameValues | ForEach-Object { Write-Output $_ }

# Friendly message based on the number of extracted Name values
if ($nameValues.Count -eq 1) {
    Write-Output "Hey, we noticed you have removed setting '$($nameValues[0])', please double check that you have also done X."
} elseif ($nameValues.Count -gt 1) {
    Write-Output "Hey, we noticed you have removed the following settings: '$($nameValues -join "', '")'. Please double check that you have also done X."
} else {
    Write-Output "No settings were removed. Please verify the changes."
}
