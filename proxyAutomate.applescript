set targetHost to "192.168.1.120"
set btnTurnOn to "Turn On"
set btnTurnOff to "Turn Off"
set btnSleepOnLAN to "SleepOnLAN"
set dlgTitle to "HTTPS Proxy"
set btnOK to "OK"
set btnCancel to "Cancel"
set btnReCheck to "ReCheck"
set btnWakeOnLAN to "WakeOnLAN"
set loop to true

repeat while loop is true
	try
		set pingResult to (do shell script "ping -c 1 -t 2 " & targetHost & " > /dev/null 2>&1")
		set enabledResult to (do shell script "networksetup -getsecurewebproxy Wi-Fi | grep Enabled: | awk {'print$2'} | head -n 1")
		
		if enabledResult is "Yes" then
			set dialogResult to display dialog "Enabled: " & enabledResult buttons {btnTurnOff, btnSleepOnLAN, btnCancel} default button btnTurnOff with title dlgTitle & " - Ping: Ok"
			
			if button returned of dialogResult is btnTurnOff then
				do shell script "networksetup -setsecurewebproxystate Wi-Fi off"
				
			else if button returned of dialogResult is btnSleepOnLAN then
				tell application "Terminal"
					activate
					do script "ssh _@" & targetHost
				end tell
				
			else if button returned of dialogResult is btnCancel then
				set loop to false
				
			end if
			
		else if enabledResult is "No" then
			set dialogResult to display dialog "Enabled: " & enabledResult buttons {btnTurnOn, btnCancel} default button btnTurnOn with title dlgTitle & " - Ping: Ok"
			
			if button returned of dialogResult is btnTurnOn then
				do shell script "networksetup -setsecurewebproxystate Wi-Fi on"
				
			else if button returned of dialogResult is btnCancel then
				set loop to false
				
			end if
			
		end if
		
		
	on error
		set enabledResult to (do shell script "networksetup -getsecurewebproxy Wi-Fi | grep Enabled: | awk {'print$2'} | head -n 1")
		set dialogResult to display dialog "Enabled: " & enabledResult buttons {btnReCheck, btnWakeOnLAN, btnCancel} default button btnReCheck with title dlgTitle & " - Ping: Error"
		
		if button returned of dialogResult is btnWakeOnLAN then
			tell application "Finder"
				open file "Macintosh HD:Applications:WakeOnCommand.app"
				delay 1
				tell application "System Events" to keystroke return using command down
				delay 1
				tell application "WakeOnCommand" to quit
			end tell
			
		else if button returned of dialogResult is btnCancel then
			if enabledResult is "Yes" then
				do shell script "networksetup -setsecurewebproxystate Wi-Fi off"
				set loop to false
				
			end if
			
		end if
		
	end try
	
end repeat