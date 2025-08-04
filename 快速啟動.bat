@echo off
chcp 65001 >nul
echo 正在啟動系統...
start "AI Content Server" cmd /c "node simple-server.js && pause"
timeout /t 3 >nul
start "" "Jab.html"