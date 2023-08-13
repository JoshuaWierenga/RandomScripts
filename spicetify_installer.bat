@echo off

:: Joshua's Spicetify installer v0.2
:: v0.2: Fixes icacls calls as they need admin privileges but running this script as admin causes spicetify to complain on install

:: A new version url can be obtained on Windows 10/11 as follows:
:: winget show Spotify.Spotify --versions --verbose
:: winget install Spotify.Spotify --version {A VERSION OBTAINED FROM THE PREVIOUS COMMAND} --force
:: At least on my machine this install fails but it prints the url which is all that this script needs, you can even press ctrl+c once it appears
:: Check supported x.y.z on https://github.com/spicetify/spicetify-cli/releases
:: After deciding on a specific x.y.z, use the newest x.y.z.w that exists unless you have a good reason
echo Installing spotify
curl -o spotify_installer.exe https://upgrade.scdn.co/upgrade/client/win32-x86/spotify_installer-1.2.11.916.geb595a67-2498.exe
spotify_installer.exe
del spotify_installer.exe

:: From https://gist.github.com/remzmike/2ec197130e24ce4e8bb10aeaa845689b
:: Reenable updates with icacls "%localappdata%\Spotify\Update" /reset /t
echo:
echo Disabling spotify updates
:: These powershell calls suck but icacls needs admin privileges to run but spicetify complains if you have them
:: It should be possible for Start-Proccess to call icacls but I couldn't make it work
powershell -Command $args = \"/k icacls `\"%localappdata%\Spotify\Update`\" /reset /t /q & exit\"; Start-Process -FilePath cmd.exe \"$args\" -verb runas"
del /f /s /q "%localappdata%\Spotify\Update" 2>nul
rmdir /s /q "%localappdata%\Spotify\Update" 2>nul
mkdir "%localappdata%\Spotify\Update"
powershell -Command $args = \"/k icacls `\"%localappdata%\Spotify\Update`\" /deny "%username%":D /q & exit\"; Start-Process -FilePath cmd.exe \"$args\" -verb runas"
powershell -Command $args = \"/k icacls `\"%localappdata%\Spotify\Update`\" /deny "%username%":R /q & exit\"; Start-Process -FilePath cmd.exe \"$args\" -verb runas"

echo:
echo Installing spicetify
powershell -Command "& {iwr -useb https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.ps1 | iex}"
spicetify >nul

echo:
echo Installing spicetify marketplace
powershell -Command "& {iwr -useb https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1 | iex}

:: This is optional, comment if not desired
echo:
echo Installing nord theme
echo Use option 2, theme is no longer updated so updater is useless
powershell -Command "& {iwr -useb https://raw.githubusercontent.com/Tetrax-10/Nord-Spotify/master/install-scripts/install.ps1 | iex}

:: This is optional, comment if not desired
echo:
echo Installing lyrics plus custom app
curl -L -o spicetify-git.zip https://github.com/spicetify/spicetify-cli/archive/refs/heads/master.zip
:: Can windows tar set the output dir? Currently its quite annoying as despite asking for just lyrics-plus, it extracts
:: the full dir structure relative to the original zip
tar -xf spicetify-git.zip spicetify-cli-master/CustomApps/lyrics-plus
xcopy "spicetify-cli-master\CustomApps" "%appdata%\spicetify\CustomApps" /s /e /y
del /f /s /q spicetify-git.zip "spicetify-cli-master" >nul
rmdir /s /q "spicetify-cli-master"
spicetify config custom_apps lyrics-plus
spicetify apply

:: This is optional, comment if not desired
echo:
echo Installing eternal jukebox custom app
curl -L -o eternal-jukebox.zip https://github.com/Pithaya/spicetify-apps-dist/archive/refs/heads/dist/eternal-jukebox.zip
tar -xf eternal-jukebox.zip
xcopy "spicetify-apps-dist-dist-eternal-jukebox" "%appdata%\spicetify\CustomApps\eternal-jukebox\" /s /e /y
del /f /s /q eternal-jukebox.zip "spicetify-apps-dist-dist-eternal-jukebox" >nul
rmdir /s /q "spicetify-apps-dist-dist-eternal-jukebox"
spicetify config custom_apps eternal-jukebox
spicetify apply
