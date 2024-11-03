# Sample git show command output
$gitShowOutput = @"
commit fad672aea1f11837e2114004625bde9c92e4ec92 (HEAD -> improv/content-check)
Author: XXXXX XXXXX <XXXXXX@XXXXX.com>
Date:   Sun Nov 3 21:59:10 2024 +0000

    removal from file

diff --git a/example2.sql b/example2.sql
index cca41c7..17a8dee 100644
--- a/example2.sql
+++ b/example2.sql
@@ -8,9 +8,7 @@ MERGE INTO [Config].[FeatureSwitches] AS Target
     USING (VALUES
     (@maxid + 1, N'Switch1', 0, 0, 'Enable Household','TeamV'),
     (@maxid + 26, N'Switch2', 0, 1, 'XXXX','TeamV'),
-    (@maxid + 30, N'Switch3', 0, 1, 'XXXXX','TeamV'),
-    (@maxid + 61, N'Switch4', 0, 1, 'X','TeamV'),
-    (@maxid + 65, N'Switch5', 1, 1, 'EXXXX','TeamV'),
+    (@maxid + 30, N'Switch6', 0, 1, 'XXXXX','TeamV')
            )   AS Source ([FeatureSwitchId], [Name], [IsEnabled], [NhVersion], [Description], [CategoryName])
     ON Target.Name = Source.Name
     WHEN MATCHED THEN
"@

# Arrays to hold the lines starting with + or -
$matchingLines = @()

# Split the output into lines and process each line
$gitShowOutputLines = $gitShowOutput -split "`n"

Write-Output "Debug: Extracting lines that start with '+' or '-'..."

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
Write-Output "Debug: Lines that start with '+' or '-':"
$matchingLines | ForEach-Object { Write-Output $_ }

# Array to hold the Name values from matched lines
$nameValues = @()

Write-Output "Debug: Extracting Name values and removing escape characters..."

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
        Write-Output $cleanName
    }
}

# Print the extracted Name values for debugging
Write-Output "Debug: Extracted Name values:"
$nameValues | ForEach-Object { Write-Output $_ }

# Friendly message based on the number of extracted Name values
if ($nameValues.Count -eq 1) {
    Write-Output "Hey, we noticed you have removed setting '$($nameValues[0])', please double check that you have also done X."
} elseif ($nameValues.Count -gt 1) {
    Write-Output "Hey, we noticed you have removed the following settings: '$($nameValues -join "', '")'. Please double check that you have also done X."
} else {
    Write-Output "No settings were removed. Please verify the changes."
}
