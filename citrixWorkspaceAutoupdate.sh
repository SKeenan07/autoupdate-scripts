#!/bin/sh

# Sarah Keenan - June 2, 2020
# This script will install and update Citrix Workspace automatically

# Set log
logfile="/Library/Logs/citrixWorkspaceAutoupdate.log"

# ------------------ Install Citrix Function -----------------
installCitrixWorkspace() {
	# Get download URL
	initialURL=$(curl -s https://www.citrix.com/downloads/workspace-app/mac/workspace-app-for-mac-latest.html | grep "CitrixWorkspaceApp.dmg" | grep "downloadcomponent" | tr " " "\n" | grep "rel" | sed 's/rel=//g' | sed 's/\"//g')
	downloadURL="https:$initialURL"
	
	# DMG
	dmgFile="citrixWorkspace.dmg"
	
	# Download
	/bin/echo "`date`: Downloading Citrix Workspace $latestVersion..." >> ${logfile}
	/usr/bin/curl -sLo /tmp/${dmgFile} ${downloadURL}
	
	# Mount DMG
	/bin/echo "`date`: Mounting dmg..." >> ${logfile}
	/usr/bin/hdiutil attach /tmp/${dmgFile} -nobrowse -quiet
	
	# Get Volume name
	volume=$(ls /Volumes/ | grep "Citrix")
	
	# Install
	/bin/echo "`date`: Installing..." >> ${logfile}
	/usr/sbin/installer -pkg "/Volumes/$volume/Install Citrix Workspace.pkg" -target /
	sleep 10

	# Unmount
	/bin/echo "`date`: Unmounting volume..." >> ${logfile}
	/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep "Citrix" | awk '{ print $1 }') -quiet
	
	# Clean up /tmp/
	rm -rf /tmp/citrixWorkspace.dmg
}

# ---------------- To Install or Not Install? ----------------
# Get the latest version
latestVersion=$(curl -s https://www.citrix.com/downloads/workspace-app/mac/workspace-app-for-mac-latest.html | grep "Version: " | awk '{ print $2 }')

if [[ -e "/Applications/Citrix Workspace.app" ]] && [[ -n "$latestVersion" ]]; then
# 	echo "Citrix is installed and the Mac is connected to the internet";
	
	# Get the installed version
	installedVersion=$(defaults read /Applications/Citrix\ Workspace.app/Contents/Info.plist CitrixVersionString)
	
	if [[ "$installedVersion" == "$latestVersion" ]]; then

		/bin/echo "`date`: Citrix Workspace is up to date" >> ${logfile}
					
	elif [[ "$installedVersion" != "$latestVersion" ]]; then
	
		/bin/echo "`date`: $latestVersion update available" >> ${logfile}
		
		installCitrixWorkspace
		
		# Verify Update
		newInstalledVersion=$(defaults read /Applications/Citrix\ Workspace.app/Contents/Info.plist CitrixVersionString)
		if [[ "$newInstalledVersion" == "$latestVersion" ]]; then
			/bin/echo "`date`: Citrix Workspace v. $latestVersion installation SUCCESSFUL." >> ${logfile}
		else
			/bin/echo "`date`: Citrix Workspace v. $latestVersion installation FAILED." >> ${logfile}
		fi

	fi

	
elif [[ ! -e "/Applications/Citrix Workspace.app" ]] && [[ -n "$latestVersion" ]]; then
# 	echo "Citrix is NOT installed and the Mac is connected to the internet";
	
	/bin/echo "Citrix Workspace is not installed." >> ${logfile}

	installCitrixWorkspace
	
	# Verify Installation
	if [[ -e "/Applications/Citrix Workspace.app" ]]; then 
		/bin/echo "`date`: Citrix Workspace v. $latestVersion installation SUCCESSFUL." >> ${logfile}
	else
		/bin/echo "`date`: Citrix Workspace v. $latestVersion installation FAILED." >> ${logfile}
	fi
		
elif [[ -z "$latestVersion" ]]; then

	# The Mac is not connected to the internet OR Citrix changed the URL
	/bin/echo "`date`: Either the Mac is not connected to the internet or Citrix changed the download URL." >> ${logfile}

fi

/bin/echo "--" >> ${logfile}

# /bin/echo "`date`: " >> ${logfile}
# ------------------------ Pseudocode ------------------------
# Set log
#
# Define function to install Citrix
# 	Get the download URL
# 	Download and mount the DMG
# 	Install Citrix Workspace
# 	Umount and delete DMG
#
# Get the latest version of Citrix available
#
# If Citrix is installed AND the latest version variable is not empty
# 	Get the version that is installed
# 	If the installed version equals the latest version, then
# 		Citrix is up to date
# 	If the installed version does not equal the latest version, then
# 		Update Citrix
# 		Get the new installed version
# 		If the new version installed equals the latest version, then
# 			Citrix updated
# 		If the versions are not equal, then
# 			Citrix failed to update
#
# If Citrix is not installed AND the latest version variable is not empty
# 	Install Citrix
# 	If Citrix exists, then
# 		Citrix was installed successfully
# 	If Citrix does not exist, then
# 		The installation failed
#
# If the latest version variable is empty, then
# 	The Mac is not connected to the internet or the download URL has changed
#