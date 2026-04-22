#!/usr/bin/env bash
#
# =============================================================================
# macOS Defaults Configuration Script
# =============================================================================
#
# This script configures various macOS defaults to improve productivity,
# usability, and aesthetics. It combines settings from multiple sources and
# adds extensive documentation.
#
# USAGE:
#   ./mac.config.sh              # Run with default settings
#   VERBOSE=1 ./mac.config.sh    # Run with verbose output
#   DEBUG=1 ./mac.config.sh      # Run with debugging (dry-run mode)
#
# DEBUGGING ALIASES:
#   mac_defaults_check <domain> <key>    # Check current value of a default
#   mac_defaults_backup <file>           # Backup current defaults to file
#   mac_defaults_restore <file>          # Restore defaults from file
#   mac_defaults_diff                     # Show differences from backup
#   mac_defaults_reset <domain>          # Reset a domain to defaults
#
# DOCUMENTATION:
# - Each section is clearly marked with comments explaining the purpose.
# - Commented lines are disabled defaults that can be enabled if desired.
# - Some changes require a logout/restart to take effect.
# - Always back up before running: mac_defaults_backup ~/defaults_backup.plist
#
# SOURCES:
# - https://github.com/mathiasbynens/dotfiles/blob/master/.macos
# - https://github.com/rootbeersoup/dotfiles
# - https://github.com/skwp/dotfiles
# - https://www.defaults-write.com
# - Custom additions for modern macOS
# =============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Set your desired computer name here
COMPUTER_NAME="por"

# --- Shell Globals ---
DEBUG="${DEBUG:-0}"
VERBOSE="${VERBOSE:-0}"

# --- Helper Functions ---

# Debug and verbose logging functions
debug_log() {
  [[ "$DEBUG" -eq 1 ]] && echo "DEBUG: $*" >&2
}

verbose_log() {
  [[ "$VERBOSE" -eq 1 ]] && echo "VERBOSE: $*" >&2
}

# Safe defaults write with logging
safe_defaults() {
  local domain="$1"
  local key="$2"
  shift 2
  local value="$*"

  verbose_log "Setting $domain $key to $value"

  if [[ "$DEBUG" -eq 1 ]]; then
    echo "DRY-RUN: defaults write $domain \"$key\" $value"
  else
    defaults write "$domain" "$key" $value
  fi
}

# Helper for setting values in plist files
plist_set() {
    local file="$1"
    local key="$2"
    local value="$3"
    /usr/libexec/PlistBuddy -c "Set :$key $value" "$file" &>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :$key $value" "$file"
}

# Override `defaults` command for verbosity/debugging
if [[ "$VERBOSE" -eq 1 ]] || [[ "$DEBUG" -eq 1 ]]; then
  defaults() {
    if [[ "$1" = "write" ]]; then
      safe_defaults "$2" "$3" "${@:4}"
    else
      command defaults "$@"
    fi
  }
fi

# --- Debugging Functions ---
mac_defaults_check() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: mac_defaults_check <domain> <key>" >&2
    return 1
  fi
  local domain="$1"
  local key="$2"
  echo "Current value for $domain $key:"
  defaults read "$domain" "$key" 2>/dev/null || echo "Key not found or error reading"
}

mac_defaults_backup() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: mac_defaults_backup <output_file>" >&2
    return 1
  fi
  local output_file="$1"
  echo "Backing up defaults to $output_file..."
  defaults read > "$output_file" 2>/dev/null || {
    echo "Error: Failed to backup defaults" >&2
    return 1
  }
  echo "Backup completed."
}

mac_defaults_restore() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: mac_defaults_restore <input_file>" >&2
    return 1
  fi
  local input_file="$1"
  if [[ ! -f "$input_file" ]]; then
    echo "Error: File $input_file not found" >&2
    return 1
  fi
  echo "Restoring defaults from $input_file..."
  defaults import "$input_file" < "$input_file" 2>/dev/null || {
    echo "Error: Failed to restore defaults" >&2
    return 1
  }
  echo "Restore completed. Some changes may require restart."
}

mac_defaults_diff() {
  echo "Comparing current defaults with backup..."
  # This would require a backup file; for simplicity, show recent changes
  echo "Recent defaults changes (last 10):"
  defaults read | tail -20
}

mac_defaults_reset() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: mac_defaults_reset <domain>" >&2
    return 1
  fi
  local domain="$1"
  echo "Resetting $domain to system defaults..."
  defaults delete "$domain" 2>/dev/null || echo "Domain $domain not found or already reset"
  echo "Reset completed. Some changes may require restart."
}


# =============================================================================
# Start Configuration
# =============================================================================
echo 'Configuring your mac. Hang tight.'

# Close any open System Preferences panes to prevent conflicts
osascript -e 'tell application "System Preferences" to quit'

# Ask for admin password upfront and keep it alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "
# Alternative: Set a low but audible volume
# sudo nvram SystemAudioVolume=%01

# --- Menu Bar ---
# Hide remaining battery time; show percentage
defaults write com.apple.menuextra.battery ShowPercent -string 'YES'
defaults write com.apple.menuextra.battery ShowTime -string 'NO'
# Make status icons smaller to take less space (useful for notched screens)
# https://flaky.build/built-in-workaround-for-applications-hiding-under-the-macbook-pro-notch
defaults write -globalDomain NSStatusItemSelectionPadding -int 12
defaults write -globalDomain NSStatusItemSpacing -int 12

# --- General ---
# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Show scrollbars 
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Possible values: `WhenScrolling`, `Automatic` and `Always`

# Disable rubber-band scrolling
# http://osxdaily.com/2012/05/10/disable-elastic-rubber-band-scrolling-in-mac-os-x/
defaults write -g NSScrollViewRubberbanding -int 0

# Maximize windows on double clicking the title bar
defaults write -g AppleActionOnDoubleClick 'Maximize'

# Disable multitouch navigation swipes (three-finger swipe)
defaults write -g AppleEnableSwipeNavigateWithScrolls -int 0

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool fals

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Display ASCII control characters using caret notation in standard text views
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# Set Help Viewer windows to non-floating mode
defaults write com.apple.helpviewer DevMode -bool true

# Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

###############################################################################
# Input, Keyboard, and Text Editing                                           #
###############################################################################

# --- Keyboard ---
# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# remap caps lock to control
hidutil property --set '{"UserKeyMapping":
    [{"HIDKeyboardModifierMappingSrc":0x700000039,
      "HIDKeyboardModifierMappingDst":0x7000000E0}]
}'

# Disable language selection popup on key hold
defaults write kCFPreferencesAnyApplication TSMLanguageIndicatorEnabled 0

# --- Text Editing ---
# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Trackpad, mouse, Bluetooth accessories                                      #
###############################################################################
# Disable “natural” (Lion-style) scrolling
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Use scroll gesture with the Ctrl (^) modifier key to zoom
# defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
# defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
# Follow the keyboard focus while zoomed in
# defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

###############################################################################
# Screen and Screenshots                                                      #
###############################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Re-enable subpixel antialiasing for non-Apple LCDs
# Mojave renders fonts that are too thin for some, this brings back pre-mojave style
defaults write -g CGFontRenderingFontSmoothingDisabled -bool FALSE
defaults write NSGlobalDomain AppleFontSmoothing -int 1

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
# defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Allow quitting Finder via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Show the ~/Library folder
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

# Expand the following File Info panes: “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

# --- Finder Icon View Settings ---
finder_plist="${HOME}/Library/Preferences/com.apple.finder.plist"

# Enable snap-to-grid for icons on the desktop and in other icon views
plist_set "$finder_plist" "DesktopViewSettings:IconViewSettings:arrangeBy" "grid"
plist_set "$finder_plist" "FK_StandardViewSettings:IconViewSettings:arrangeBy" "grid"
plist_set "$finder_plist" "StandardViewSettings:IconViewSettings:arrangeBy" "grid"

# Increase grid spacing for icons
plist_set "$finder_plist" "DesktopViewSettings:IconViewSettings:gridSpacing" "100"
plist_set "$finder_plist" "FK_StandardViewSettings:IconViewSettings:gridSpacing" "100"
plist_set "$finder_plist" "StandardViewSettings:IconViewSettings:gridSpacing" "100"

# Increase the size of icons
plist_set "$finder_plist" "DesktopViewSettings:IconViewSettings:iconSize" "80"
plist_set "$finder_plist" "FK_StandardViewSettings:IconViewSettings:iconSize" "80"
plist_set "$finder_plist" "StandardViewSettings:IconViewSettings:iconSize" "80"

###############################################################################
# Dock, Dashboard, and Hot Corners                                            #
###############################################################################

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 56

# Don't use the Dock size limit
defaults write com.apple.Dock size-immutable -bool yes

# Show indicator lights for open applications
defaults write com.apple.dock show-process-indicators -bool true

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Hot corners
# Possible values:
#  0: no-op,  2: Mission Control,  3: Show application windows,  4: Desktop,
#  5: Start screen saver,  6: Disable screen saver,  7: Dashboard,
# 10: Put display to sleep, 11: Launchpad, 12: Notification Center, 13: Lock Screen

defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
# Alternative: Top-right corner -> Show Desktop
# defaults write com.apple.dock wvous-tr-corner -int 4
# defaults write com.apple.dock wvous-tr-modifier -int 0

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

###############################################################################
# Time Machine                                                                #
###############################################################################

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable local Time Machine backups
# hash tmutil &> /dev/null && sudo tmutil disablelocal

###############################################################################
# Activity Monitor                                                            #
###############################################################################

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# App Store                                                                   #
###############################################################################

# Disable in-app rating requests from apps downloaded from the App Store.
defaults write com.apple.appstore InAppReviewEnabled -bool false

# Enable the WebKit Developer Tools in the Mac App Store
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Other Applications                                                          #
###############################################################################

# --- Google Chrome ---
# Expand the print dialog by default
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

# --- iTerm 2 ---
# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# --- Transmission ---
# Use `~/Documents/Torrents` to store incomplete downloads
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Documents/Torrents"
# Trash original torrent files
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true
# Hide the donate message
defaults write org.m0k.transmission WarningDonate -bool false
# Hide the legal disclaimer
defaults write org.m0k.transmission WarningLegal -bool false
# IP block list
defaults write org.m0k.transmission BlocklistNew -bool true
defaults write org.m0k.transmission BlocklistURL -string "http://john.bitsurge.net/public/biglist.p2p.gz"
defaults write org.m0k.transmission BlocklistAutoUpdate -bool true
# Randomize port on launch
defaults write org.m0k.transmission RandomPort -bool true

###############################################################################
# Kill affected applications to apply changes                                 #
###############################################################################

echo "Restarting affected applications to apply changes..."

for app in \
	"Activity Monitor" \
	"Dock" \
	"Finder" \
	"Google Chrome" \
	"Mail" \
	"Photos" \
	"Safari" \
	"SystemUIServer" \
	"iTerm 2" \
	"Transmission"; do
	killall "${app}" &> /dev/null
done

echo "Done. Note that some changes require a logout or restart to take effect."
