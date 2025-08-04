@echo off
chcp 65001 >nul
title AI內容生產器 - 啟動程式

echo.
echo 🚀 ===============================================
echo    AI內容生產器 - 智能啟動系統
echo ===============================================
echo.

:: 設定顏色
color 0A

:: 獲取批處理文件所在目錄
set "SCRIPT_DIR=%~dp0"
echo 📍 腳本目錄: %SCRIPT_DIR%

:: 切換到正確的目錄
cd /d "%SCRIPT_DIR%"
echo 📂 已切換到正確目錄: %CD%
echo.

:: 檢查 Node.js
echo 🔍 檢查 Node.js 安裝...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 錯誤: Node.js 未安裝或未加入PATH
    echo.
    echo 📥 請先安裝 Node.js:
    echo    1. 前往 https://nodejs.org/
    echo    2. 下載 LTS 版本
    echo    3. 安裝後重新啟動此程式
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('node --version 2^>nul') do set NODE_VERSION=%%v
echo ✅ Node.js 版本: %NODE_VERSION%
echo.

:: 檢查必要文件
echo 🔍 檢查系統文件...
set "FILES_OK=1"

if not exist "simple-server-fixed.js" (
    echo ❌ 缺少: simple-server-fixed.js
    set "FILES_OK=0"
)

if not exist "Jab.html" (
    echo ❌ 缺少: Jab.html
    set "FILES_OK=0"
)

if not exist "package.json" (
    echo ❌ 缺少: package.json
    set "FILES_OK=0"
)

if %FILES_OK%==0 (
    echo.
    echo ❌ 缺少必要文件，請確認檔案完整性
    pause
    exit /b 1
)

echo ✅ 所有必要文件存在
echo.

:: 檢查依賴
echo 🔍 檢查依賴安裝...
if not exist "node_modules" (
    echo ⚠️  node_modules 不存在，正在安裝依賴...
    echo.
    npm install
    if %errorlevel% neq 0 (
        echo ❌ 依賴安裝失敗
        pause
        exit /b 1
    )
    echo ✅ 依賴安裝完成
    echo.
) else (
    echo ✅ 依賴已安裝
    echo.
)

:: 檢查端口
echo 🔍 檢查端口 3001 狀態...
netstat -ano | findstr ":3001" >nul 2>&1
if %errorlevel%==0 (
    echo ⚠️  端口 3001 已被使用
    echo.
    echo 🔄 嘗試關閉佔用的進程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3001"') do (
        echo    終止進程 ID: %%a
        taskkill /PID %%a /F >nul 2>&1
    )
    timeout /t 2 /nobreak >nul
    echo ✅ 端口清理完成
    echo.
) else (
    echo ✅ 端口 3001 可用
    echo.
)

:: 啟動伺服器
echo 🚀 啟動 AI 內容生產器伺服器...
echo.
echo 📝 正在啟動修復版伺服器...
echo    - 文件: simple-server-fixed.js
echo    - 端口: 3001
echo    - 日誌: 啟用
echo.

:: 在新視窗中啟動伺服器
start "AI內容生產器伺服器" /min cmd /c "node simple-server-fixed.js && pause"

:: 等待伺服器啟動
echo ⏰ 等待伺服器啟動 (10秒)...
timeout /t 10 /nobreak >nul

:: 測試伺服器連接
echo 🧪 測試伺服器連接...
powershell -Command "try { $response = Invoke-RestMethod http://localhost:3001/health -TimeoutSec 5; if($response.status -eq 'ok') { Write-Host '✅ 伺服器連接成功' -ForegroundColor Green; exit 0 } else { Write-Host '❌ 伺服器響應異常' -ForegroundColor Red; exit 1 } } catch { Write-Host '❌ 無法連接到伺服器' -ForegroundColor Red; exit 1 }" >nul 2>&1

if %errorlevel%==0 (
    echo ✅ 伺服器啟動成功！
    echo.
    echo 🌐 正在打開用戶界面...
    
    :: 打開主界面
    start "" "Jab.html"
    
    echo.
    echo 🎉 ===============================================
    echo    AI內容生產器已成功啟動！
    echo ===============================================
    echo.
    echo 📋 系統信息:
    echo    🌐 主界面: Jab.html (已自動打開)
    echo    🔗 伺服器: http://localhost:3001
    echo    📊 健康檢查: http://localhost:3001/health
    echo    📋 日誌查看: http://localhost:3001/api/logs
    echo.
    echo 💡 使用提示:
    echo    1. 確認右上角顯示 "已連接 (3001)"
    echo    2. 輸入主題開始生成內容
    echo    3. 建議首次使用選擇 1 篇內容測試
    echo    4. 如有問題，請查看日誌或重新啟動
    echo.
    echo 🔧 管理選項:
    echo    [1] 重新啟動伺服器
    echo    [2] 查看伺服器日誌
    echo    [3] 打開日誌查看器
    echo    [4] 關閉系統
    echo    [5] 保持運行並退出此視窗
    echo.
    
    choice /c 12345 /n /m "請選擇 [1-5]: "
    
    if !errorlevel!==1 (
        echo.
        echo 🔄 重新啟動伺服器...
        taskkill /f /im node.exe >nul 2>&1
        timeout /t 2 /nobreak >nul
        goto :restart_server
    )
    
    if !errorlevel!==2 (
        echo.
        echo 📋 顯示伺服器日誌...
        if exist "logs\server-system.log" (
            type "logs\server-system.log"
        ) else (
            echo 日誌文件不存在
        )
        pause
        goto :menu
    )
    
    if !errorlevel!==3 (
        echo.
        echo 🌐 打開日誌查看器...
        start "" "log-viewer.html"
        goto :menu
    )
    
    if !errorlevel!==4 (
        echo.
        echo 🔄 關閉系統...
        taskkill /f /im node.exe >nul 2>&1
        echo ✅ 系統已關閉
        pause
        exit
    )
    
    if !errorlevel!==5 (
        echo.
        echo ✅ 系統持續運行中，可安全關閉此視窗
        echo 💡 如需管理系統，請重新執行此程式
        pause
        exit
    )
    
) else (
    echo ❌ 伺服器啟動失敗
    echo.
    echo 🔍 故障排除建議:
    echo    1. 檢查是否有其他程式佔用端口 3001
    echo    2. 確認 Node.js 正確安裝
    echo    3. 檢查網路防火牆設定
    echo    4. 查看詳細錯誤日誌
    echo.
    echo 🛠️  調試選項:
    echo    [1] 重試啟動
    echo    [2] 使用調試模式
    echo    [3] 檢查系統狀態
    echo    [4] 退出
    echo.
    
    choice /c 1234 /n /m "請選擇 [1-4]: "
    
    if !errorlevel!==1 goto :restart_server
    if !errorlevel!==2 (
        echo 🐛 啟動調試模式...
        node debug-server.js
        pause
    )
    if !errorlevel!==3 (
        echo 🔍 系統診斷...
        node comprehensive-debug.js
        pause
    )
    if !errorlevel!==4 exit
)

:restart_server
start "AI內容生產器伺服器" /min cmd /c "node simple-server-fixed.js && pause"
timeout /t 5 /nobreak >nul
goto :test_connection

:test_connection
powershell -Command "try { Invoke-RestMethod http://localhost:3001/health -TimeoutSec 5 } catch { exit 1 }" >nul 2>&1
if %errorlevel%==0 (
    echo ✅ 重啟成功！
    goto :menu
) else (
    echo ❌ 重啟失敗
    pause
)

:menu
echo.
goto :choice_menu

:choice_menu
echo 🔧 選擇操作...
goto :restart_server 