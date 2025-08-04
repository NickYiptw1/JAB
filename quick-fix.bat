@echo off
echo 正在修復系統...
taskkill /f /im node.exe >nul 2>&1
timeout /t 2 >nul
start "AI Content Server" cmd /c "node simple-server-fixed.js && pause"