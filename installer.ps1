$BaseDir = "C:\Program Files\StarUML"
$npmExists = Get-Command npm -ErrorAction SilentlyContinue
$resourcesDir = Join-Path $BaseDir "resources"
$githubUser = "RyZeDZ"
$githubRepo = "staruml-patch"
$githubBranch = "main"    
$filesToReplace = @(
    "app/src/engine/diagram-export.js",
    "app/src/engine/license-store.js",
    "app/src/utils/license-client.js"
)

Write-Host "1. Checking for StarUML directory: $BaseDir"

if (-not (Test-Path $BaseDir)) {
    throw "Error: The directory '$BaseDir' was not found. Please ensure StarUML is installed correctly."
}

Write-Host "    Directory found." -ForegroundColor Green

Write-Host "2. Checking for npm (Node.js)..."


if (-not $npmExists) {
    Write-Warning "npm not found. Attempting to download and install Node.js LTS..."

    try {
        $NodeInstallerUrl = "https://nodejs.org/dist/v22.20.0/node-v22.20.0-x64.msi"
        $TempPath = Join-Path $env:TEMP "node-lts-x64.msi"
        
        Write-Host "   Downloading Node.js installer from $NodeInstallerUrl..."
        Invoke-WebRequest -Uri $NodeInstallerUrl -OutFile $TempPath -UseBasicParsing
        Write-Host "   Download complete." -ForegroundColor Green

        Write-Host "   Installing Node.js. This may take a moment..."
        Start-Process msiexec.exe -ArgumentList "/i `"$TempPath`" /qn /norestart" -Wait
        
        Write-Host "   Node.js installation completed." -ForegroundColor Green

        Remove-Item $TempPath -Force

        Write-Host "   Refreshing PATH environment variable for this session..."
        $newSystemPath = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'Path').Path
        $userPath = (Get-ItemProperty -Path 'HKCU:\Environment' -Name 'Path' -ErrorAction SilentlyContinue).Path
        $env:Path = "$newSystemPath;$userPath"
        Write-Host "   PATH refreshed." -ForegroundColor Green

        $npmExists = Get-Command npm -ErrorAction SilentlyContinue
        if (-not $npmExists) {
            throw "Node.js was installed, but 'npm' is still not found in the refreshed PATH. Please restart your terminal and re-run the script."
        }
    }
    catch {
        throw "An error occurred during the automated installation of Node.js. Please try installing it manually from https://nodejs.org/"
    }
}

Write-Host "   npm is installed!" -ForegroundColor Green


if (-not (Test-Path $resourcesDir)) {
    throw "Error: The resources directory '$resourcesDir' was not found."
}

Set-Location $resourcesDir
Write-Host "3. Changed directory to: $(Get-Location)"

Write-Host "4. Installing 'asar' globally and extracting archive..."

npm i -g asar | Out-Null

Write-Host "   'asar' installed successfully." -ForegroundColor Green

if (-not (Test-Path "app.asar")) {
    throw "Error: 'app.asar' not found in the resources directory. Cannot proceed."
}

if (Test-Path "app") {
    Write-Host "Found existing 'app' folder. Removing it first."
    Remove-Item -Path "app" -Recurse -Force
}

asar extract app.asar app
Write-Host "   'app.asar' extracted to 'app' folder." -ForegroundColor Green

Write-Host "5. Replacing files from GitHub repository..."

foreach ($file in $filesToReplace) {
    $url = "https://raw.githubusercontent.com/$githubUser/$githubRepo/$githubBranch/$file"
    
    $destinationPath = Join-Path $PWD "$file"

    Write-Host "   -> Downloading $file"
    
    $destinationDir = Split-Path -Path $destinationPath -Parent
    if (-not (Test-Path $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir | Out-Null
    }

    try {
        Invoke-WebRequest -Uri $url -OutFile $destinationPath -UseBasicParsing
        Write-Host "      Replaced: $destinationPath" -ForegroundColor Cyan
    }
    catch {
        throw "Error downloading file from '$url'. Please check the path and repository details. Error: $($_.Exception.Message)"
    }
}
Write-Host "   File replacement complete." -ForegroundColor Green

Write-Host "6. Repacking the 'app' folder into 'app.asar'..."

try {
    asar pack app app.asar | Out-Null
    Write-Host "   Archive repacked successfully." -ForegroundColor Green
}
catch {
    throw "An error occurred while repacking the asar archive. Error: $($_.Exception.Message)"
}

Write-Host "7. Cleaning up temporary folder..."

Remove-Item -Path "app" -Recurse -Force
Write-Host "   'app' folder removed." -ForegroundColor Green

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host " SCRIPT COMPLETED SUCCESSFULLY! " -ForegroundColor Green
Write-Host " StarUML has been patched. " -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green