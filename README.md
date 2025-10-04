# StarUML Patcher - An Educational Demonstration

This repository contains a PowerShell script (`installer.ps1`) designed to automate the process of patching StarUML. This project was created for educational purposes to demonstrate how easily Electron applications packaged with ASAR can be modified.

---

## ⚠️ Important Disclaimer

- **This project is for educational purposes ONLY.** Its goal is to highlight a security consideration in Electron app distribution and should not be used for software piracy.
- **Use this script at your own risk.** Modifying application files can lead to unexpected behavior or crashes. It is highly recommended to back up the original `app.asar` file before running this script.
- The author is not responsible for any damage caused to your software or system.

---

## Prerequisites

- Windows 10 or newer.
- A legally acquired installation of StarUML.
- **Administrator Access:** The script modifies files in `C:\Program Files`, so it **must** be run from an **Administrator PowerShell** terminal.

---

## How to Use

You can run the script using the convenient one-liner below.

1.  Right-click the Start Menu and select **"Windows PowerShell (Admin)"** or **"Terminal (Admin)"**.
2.  Paste the following command into the terminal and press Enter.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex (irm 'https://raw.githubusercontent.com/RyZeDZ/staruml-patch/main/installer.ps1')
```

---

## How The Script Works

This automated script performs the following actions:

1.  **Checks for Admin:** Ensures it has permissions to modify system files.
2.  **Validates StarUML Path:** Confirms that `C:\Program Files\StarUML` exists.
3.  **Ensures Dependencies:** Checks if `npm` (Node.js) is installed. If not, it automatically downloads and silently installs the LTS version.
4.  **Unpacks Archive:** Navigates to the `StarUML\resources` directory, installs the `asar` utility, and extracts `app.asar` into a temporary `app` folder.
5.  **Applies Patch:** Downloads the files specified in the configuration from this GitHub repository and overwrites the original files in the `app` folder.
6.  **Repacks Archive:** Uses `asar` to pack the modified `app` folder back into an `app.asar` file, overwriting the original.
7.  **Cleans Up:** Deletes the temporary `app` folder and displays a success message.
