# Convert plain texts in clipboard into keystrokes

# Why?
# To paste text into windows that normally don't allow it or have access to the clipboard.
# Examples: Virtual machines that do not yet have tools installed, websites that hijack paste

# Extended vs Simple?
# * Includes an initial delay to allow you to change active windows
# * Adds small delay between keypresses for slower responding windows like SSH sessions
# * Better handling of numbers
# * VMWare bug fix

# Setup using Apple Shortcuts app

# How?
#   1. Launch Automator (yup it comes with BigSur and already installed, no need to install it)
#   2. New Document
#   3. Click Quick Action
#   4. Change "Workflow Receives" to "No Input"
#   5. On the left scroll down and double click "Run AppleScript"
#   6. Erase the Template Text and Past the Code above "I used the basic workflow script" (you dont need both scripts)
#   7. Save the Script - I called mine Clip2Keystrokes
#   8. You will need to add the Automator and ANY app you plan to run this script in System Preferences > Security & Privacy > Privacy > Accessibility
#    - Allow `Shortcuts.app`
#    - Allow siriactionsd in /System/Library/PrivateFrameworks/VoiceShortcuts.framework/Versions/A/Support 
#   9. Copy your text to the clipboard
#   10. Then switch to the App you want to paste in (in my case it was a Teamviewer session)
#   11. Click the App name in the top left (next to the apple icon), you will see a Services Menu option.
#   12. Mouse over the Services menu and you will see your script name, "Clip2Keystrokes" in my case.
#   13. Be sure the cursor is already where you need it to be as clicking on the script will cause it to start typing.

on run
    tell application "System Events"
        # delay 2 # DELAY BEFORE BEGINNING KEYPRESSES IN SECONDS
        repeat with char in (the clipboard)
            set cID to id of char

            if ((cID ≥ 48) and (cID ≤ 57)) then
                # Converts numbers to ANSI_# characters rather than ANSI_Keypad# characters
                # https://apple.stackexchange.com/a/227940
                key code {item (cID - 47) of {29, 18, 19, 20, 21, 23, 22, 26, 28, 25}}
            else if (cID = 46) then
                # Fix VMware Fusion period bug
                # https://apple.stackexchange.com/a/331574
                key code 47
            else
                keystroke char
            end if

            # delay 0.5 # DELAY BETWEEN EACH KEYPRESS IN SECONDS
        end repeat
    end tell
end run
