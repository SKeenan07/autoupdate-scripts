#!/bin/sh

# Sarah Keenan - April 14-16, 2020
# This script will update Zoom if it is installed.

# Sarah Keenan - April 21, 2020
# Moved Update Zoom and Verify Zoom sections to function.

# Sarah Keenan - April 23, 2020
# Added more log outputs for clarification.

logfile="/Library/Logs/zoomAutoupdate.log"

# Define function to install Zoom
installZoom() {
	# ---------------------- Update Zoom ----------------------
	
	# Download URL
	url="https://zoom.us/client/latest/ZoomInstallerIT.pkg"

	# DMG 
	dmgFile="ZoomInstallerIT.pkg"
	
	# Download
	/bin/echo "`date`: Downloading Zoom..." >> ${logfile}
	/usr/bin/curl -sLo /tmp/${dmgFile} ${url} && /bin/echo "`date`: Downloaded." >> ${logfile}

	# Install
	/usr/sbin/installer -pkg /tmp/${dmgFile} -target /  && /bin/echo "`date`: Installed." >> ${logfile}
	
	# ------------------ Verify Installation ------------------
	
	# Get installed version
	newInstalledVer=$(defaults read "/Applications/zoom.us.app/Contents/Info.plist" CFBundleVersion)
	
	if [[ "$newInstalledVer" == "$latestVer" ]]; then
		/bin/echo "`date`: Zoom successfully updated to version $latestVer." >> ${logfile}
	elif [[ "$newInstalledVer" == "$installedVer" ]]; then
		/bin/echo "`date`: Zoom FAILED to update." >> ${logfile}
		/bin/echo "`date`: Zoom remains at version $installedVer." >> ${logfile}
	fi

}

# -------------------- Is Zoom installed? ---------------------

if [[ -e "/Applications/zoom.us.app/" ]]; then
	
	# Zoom is installed
	zoomInstalled="Yes"
	
	# Get the installed version
	installedVer=$(defaults read "/Applications/zoom.us.app/Contents/Info.plist" CFBundleVersion)
else
	
	# Zoom is not installed
	zoomInstalled="No"
fi

# ---------------- What is the latest version? ----------------

# Get the latest version - from https://www.jamf.com/jamf-nation/discussions/29561/script-to-install-update-zoom
OSvers_URL=$(sw_vers -productVersion | sed 's/[.]/_/g')
userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"
latestVer=$(/usr/bin/curl -s -A "$userAgent" https://zoom.us/download | grep 'ZoomInstallerIT.pkg' | awk -F'/' '{print $3}')

# --------------- To install or not to install? ---------------


if [[ "$zoomInstalled" == "No" ]]; then
	
	# ---------- Install Zoom if it is not installed ----------
	/bin/echo "`date`: Zoom is not installed." >> ${logfile}
	/bin/echo "`date`: Installing Zoom..." >> ${logfile}
	installZoom

elif [[ -z "$latestVer" ]]; then
	
	# --------- Can't get latest version? No internet? --------
	/bin/echo "`date`: Could not get latest version." >> ${logfile}
	/bin/echo "`date`: The Mac is probably not connected to the internet or the download url has changed." >> ${logfile}
	/bin/echo "`date`: Exiting..." >> ${logfile}

elif [[ "$latestVer" != "$installedVer" ]]; then
	
	# ---- Update Zoom if installed and latest don't match ----
	/bin/echo "`date`: Latest Version: $latestVer" >> ${logfile}
	/bin/echo "`date`: Installed Version: $installedVer" >> ${logfile}
	/bin/echo "`date`: There is a new version of Zoom." >> ${logfile}
	/bin/echo "`date`: Updating..." >> ${logfile}
	installZoom
	
elif [[ "$latestVer" == "$installedVer" ]]; then
	/bin/echo "`date`: Zoom is up to date." >> ${logfile}
fi

/bin/echo "---" >> ${logfile}

# ------------------------ Pseudocode -------------------------
# Set the log file.
# 
# Define the function to install Zoom. 
# 
# If zoom is installed
# 	Then set the variable to Yes
# 	and get the version of Zoom that is installed.
#
# If zoom is not installed
# 	Then set the variable to No.
# 
# Get the latest version of Zoom available. 
# 
# If Zoom is not installed
# 	Then install Zoom
#
# If the latest version variable is empty
# 	Then the Mac is probablt not connected to the internet.
#
# If the installed and latest versions don't match
# 	Then install the latest version.
#
# If the installed and latest versions match
# 	Then log
