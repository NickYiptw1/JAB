@echo off
chcp 65001 >nul
echo 正在啟動最終版系統...
start "AI Content Server" cmd /c "node ultimate-server.js && pause"
timeout /t 3 >nul
start "" "ultimate-frontend.html"