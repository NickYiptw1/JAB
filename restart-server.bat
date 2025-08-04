@echo off
chcp 65001 >nul
title AI內容生產器 - 重啟工具
color 0A

echo.
echo 🔄 正在重啟 AI內容生產器...
echo.

:: 關閉所有 Node.js 進程
echo 📍 步驟 1: 關閉現有伺服器...
taskkill /f /im node.exe >nul 2>&1
timeout /t 3 /nobreak >nul

:: 檢查是否存在終極版伺服器
if exist "ultimate-server.js" (
    echo 📍 步驟 2: 啟動終極版伺服器...
    start "AI Content Server" cmd /c "node ultimate-server.js && pause"
) else if exist "enhanced-server.js" (
    echo 📍 步驟 2: 啟動增強版伺服器...
    start "AI Content Server" cmd /c "node enhanced-server.js && pause"
) else (
    echo ❌ 錯誤：找不到伺服器檔案
    echo 請確認 ultimate-server.js 或 enhanced-server.js 存在
    pause
    exit /b 1
)

:: 等待伺服器啟動
echo 📍 步驟 3: 等待伺服器就緒...
timeout /t 5 /nobreak >nul

:: 檢查伺服器狀態
powershell -Command "try { Invoke-RestMethod http://localhost:3001/health -TimeoutSec 5 } catch { exit 1 }" >nul 2>&1
if %errorlevel%==0 (
    echo ✅ 伺服器重啟成功！
    echo.
    echo 📋 系統資訊:
    echo    🔗 伺服器: http://localhost:3001
    echo    📊 健康檢查: http://localhost:3001/health
    echo    📋 日誌查看: http://localhost:3001/api/logs
    
    :: 檢查並啟動前端界面
    if exist "ultimate-frontend.html" (
        echo 📍 步驟 4: 啟動終極版前端...
        start "" "ultimate-frontend.html"
    ) else if exist "enhanced-frontend.html" (
        echo 📍 步驟 4: 啟動增強版前端...
        start "" "enhanced-frontend.html"
    )
    
    echo.
    echo 🎉 系統已成功重啟！
) else (
    echo ❌ 伺服器重啟失敗
    echo.
    echo 🔍 故障排除建議:
    echo    1. 檢查端口 3001 是否被佔用
    echo    2. 查看 logs 目錄下的錯誤日誌
    echo    3. 確認 Node.js 正確安裝
    echo    4. 檢查網路防火牆設定
)

echo.
pause