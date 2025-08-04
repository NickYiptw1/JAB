@echo off
chcp 65001 >nul
title Jab內容生產器啟動工具
color 0A
setlocal EnableDelayedExpansion

echo.
echo 🚀 === Jab內容生產器啟動工具 ===
echo.

:: 檢查必要檔案
echo 📝 檢查系統檔案...
if not exist "Jab.html" (
    echo ❌ 錯誤：找不到 Jab.html
    echo 請確認檔案位置正確
    pause
    exit /b 1
)

:: 檢查 Node.js
echo 📝 檢查 Node.js 環境...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 錯誤：Node.js 未安裝
    echo 請安裝 Node.js 後再試
    pause
    exit /b 1
)

:: 關閉已存在的 Node.js 進程
echo 📝 清理環境...
taskkill /f /im node.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: 檢查並創建日誌目錄
if not exist "logs" mkdir logs

:: 啟動伺服器（優先使用與 Jab.html 相容的伺服器）
echo 📝 啟動伺服器...
if exist "enhanced-server.js" (
    echo    使用增強版伺服器（與 Jab.html 完全相容）...
    start "Jab Content Server" cmd /c "node enhanced-server.js && pause"
    set SERVER_TYPE=enhanced
) else if exist "simple-server.js" (
    echo    使用基礎版伺服器（與 Jab.html 相容）...
    start "Jab Content Server" cmd /c "node simple-server.js && pause"
    set SERVER_TYPE=simple
) else if exist "ultimate-server.js" (
    echo    使用終極版伺服器（注意：API 端點可能不同）...
    start "Jab Content Server" cmd /c "node ultimate-server.js && pause"
    set SERVER_TYPE=ultimate
) else (
    echo ❌ 錯誤：找不到任何伺服器檔案
    echo 請確認以下檔案之一存在：
    echo    - enhanced-server.js（推薦）
    echo    - simple-server.js
    echo    - ultimate-server.js
    pause
    exit /b 1
)

:: 等待伺服器啟動
echo 📝 等待伺服器就緒...
timeout /t 8 /nobreak >nul

:: 簡單的端口檢查
echo 📝 檢查伺服器狀態...
netstat -an | find "3001" | find "LISTENING" >nul 2>&1
if %errorlevel%==0 (
    echo ✅ 伺服器啟動成功！
    echo.
    echo 📋 系統資訊：
    echo    🌐 伺服器：http://localhost:3001
    echo    📊 狀態檢查：http://localhost:3001/health
    echo    📝 介面：Jab.html
    
    :: 啟動瀏覽器
    echo.
    echo 🌐 正在打開 Jab.html...
    start "" "Jab.html"
    
    echo.
    echo 💡 操作提示：
    echo    1. 確認右上角顯示"已連接"
    echo    2. 如果頁面顯示"內容生成失敗"，請檢查伺服器類型
    echo    3. 生成內容時請耐心等待（約30-60秒）
    echo    4. 當前使用：!SERVER_TYPE! 伺服器
    echo.
    
    :menu
    echo 🔧 管理選項：
    echo    [1] 重新啟動
    echo    [2] 查看日誌
    echo    [3] 重新打開頁面
    echo    [4] 結束程式
    echo.
    
    choice /c 1234 /n /m "請選擇 [1-4]: "
    set choice_result=!errorlevel!
    
    if !choice_result!==1 (
        echo.
        echo 🔄 重新啟動中...
        taskkill /f /im node.exe >nul 2>&1
        timeout /t 2 /nobreak >nul
        start "" "%~f0"
        exit
    )
    
    if !choice_result!==2 (
        echo.
        echo 📋 日誌內容：
        if exist "logs\server-system.log" (
            type "logs\server-system.log"
        ) else if exist "logs\system.log" (
            type "logs\system.log"
        ) else if exist "logs\api.log" (
            type "logs\api.log"
        ) else (
            echo 未找到日誌檔案
        )
        pause
        goto :menu
    )
    
    if !choice_result!==3 (
        echo.
        echo 🌐 重新打開頁面...
        start "" "Jab.html"
        goto :menu
    )
    
    if !choice_result!==4 (
        echo.
        echo 🔄 關閉系統...
        taskkill /f /im node.exe >nul 2>&1
        echo ✅ 系統已關閉
        timeout /t 2 /nobreak >nul
        exit
    )
    
) else (
    echo ❌ 伺服器啟動失敗
    echo.
    echo 🔍 故障排除建議：
    echo    1. 檢查端口 3001 是否被佔用
    echo    2. 確認防火牆設定
    echo    3. 檢查 Node.js 安裝狀態
    echo    4. 查看日誌檔案
    echo.
    pause
)