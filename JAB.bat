@echo off
chcp 65001 >nul
title JAB 內容生產器 - 深度精讀模式 [超級修復版]
color 0B
setlocal EnableDelayedExpansion

:: ==================== 調試和日誌系統 ====================
set "DEBUG_LOG=%~dp0logs\jab-debug.log"
set "ERROR_LOG=%~dp0logs\jab-error.log"
set "LAUNCH_LOG=%~dp0logs\jab-launch.log"
set "SUCCESS_LOG=%~dp0logs\jab-success.log"

:: 創建日誌目錄
if not exist "%~dp0logs" mkdir "%~dp0logs" >nul 2>&1

:: 初始化日誌
echo ========================================== > "%DEBUG_LOG%"
echo JAB.bat 調試日誌 - %DATE% %TIME% >> "%DEBUG_LOG%"
echo ========================================== >> "%DEBUG_LOG%"

echo ========================================== > "%ERROR_LOG%"
echo JAB.bat 錯誤日誌 - %DATE% %TIME% >> "%ERROR_LOG%"
echo ========================================== >> "%ERROR_LOG%"

echo ========================================== > "%LAUNCH_LOG%"
echo JAB.bat 啟動日誌 - %DATE% %TIME% >> "%LAUNCH_LOG%"
echo ========================================== >> "%LAUNCH_LOG%"

:: 日誌函數
call :LOG_DEBUG "JAB.bat 啟動開始"
call :LOG_DEBUG "工作目錄: %CD%"
call :LOG_DEBUG "批次檔路徑: %~dp0"

echo.
echo 📚 =========================================================
echo          JAB 內容生產器 - 深度精讀模式啟動中...
echo    基於《Jab, Jab, Jab, Right Hook》深度精讀原則
echo =========================================================
echo.

:: 設定工作目錄
cd /d "%~dp0"

:: 檢查必要檔案
echo 📝 [1/5] 檢查核心檔案...
call :LOG_DEBUG "開始檢查核心檔案"

if not exist "Jab.html" (
    call :LOG_ERROR "找不到 Jab.html 檔案"
    echo ❌ 錯誤：找不到 Jab.html
    echo 📂 當前目錄: %CD%
    echo 📍 預期位置: %CD%\Jab.html
    echo 📋 目錄內容:
    dir "*.html" 2>nul
    call :LOG_ERROR "程式終止 - 缺少核心檔案"
    pause
    exit /b 1
)

call :LOG_SUCCESS "找到 Jab.html 檔案"
echo    ✅ Jab.html - 主界面
echo    ✅ 深度精讀模式配置

:: 檢查 Node.js 環境
echo 📝 [2/5] 檢查 Node.js 環境...
call :LOG_DEBUG "檢查 Node.js 安裝狀態"

node --version >nul 2>&1
if %errorlevel% neq 0 (
    call :LOG_ERROR "Node.js 未安裝或未加入 PATH"
    echo ❌ 錯誤：Node.js 未安裝
    echo 📥 請前往 https://nodejs.org/ 下載安裝
    call :LOG_ERROR "程式終止 - Node.js 環境問題"
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('node --version 2^>nul') do set NODE_VERSION=%%v
call :LOG_SUCCESS "Node.js 環境正常: %NODE_VERSION%"
echo    ✅ Node.js 版本: %NODE_VERSION%

:: 清理舊進程
echo 📝 [3/5] 清理系統環境...
call :LOG_DEBUG "開始清理舊進程"

:: 檢查是否有舊的 node.exe 進程
tasklist | findstr "node.exe" >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_DEBUG "發現舊的 node.exe 進程，開始清理"
    echo    🧹 發現舊進程，正在清理...
    taskkill /f /im node.exe >nul 2>&1
    if !errorlevel! equ 0 (
        call :LOG_SUCCESS "舊進程清理成功"
        echo    ✅ 舊進程清理完成
    ) else (
        call :LOG_ERROR "舊進程清理失敗，但繼續執行"
        echo    ⚠️ 舊進程清理失敗，但繼續執行
    )
) else (
    call :LOG_DEBUG "未發現舊的 node.exe 進程"
    echo    🧹 未發現舊進程
)

:: 檢查端口 3001 是否被占用
call :LOG_DEBUG "檢查端口 3001 占用情況"
netstat -ano | findstr :3001 >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_DEBUG "端口 3001 被占用，嘗試釋放"
    echo    🔍 端口 3001 被占用，嘗試釋放...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001') do (
        call :LOG_DEBUG "嘗試終止進程 PID: %%a"
        taskkill /f /pid %%a >nul 2>&1
    )
) else (
    call :LOG_DEBUG "端口 3001 未被占用"
    echo    ✅ 端口 3001 可用
)

call :LOG_DEBUG "系統環境清理完成，等待2秒"
timeout /t 2 /nobreak >nul

:: 檢查並創建必要目錄
if not exist "logs" mkdir logs >nul
if not exist "cache" mkdir cache >nul

:: 智能選擇伺服器（優先 enhanced-server.js，因為已針對深度精讀優化）
echo 📝 [4/5] 啟動深度精讀模式伺服器...
call :LOG_DEBUG "開始智能選擇伺服器"

:: 檢查所有可用的伺服器檔案
call :LOG_DEBUG "檢查可用伺服器檔案"
echo    🔍 檢查可用伺服器檔案...

if exist "enhanced-server.js" (
    call :LOG_SUCCESS "發現 enhanced-server.js - 推薦選項"
    echo    ✅ enhanced-server.js（推薦）
)
if exist "simple-server.js" (
    call :LOG_SUCCESS "發現 simple-server.js - 基礎選項"
    echo    ✅ simple-server.js（基礎）
)
if exist "ultimate-server.js" (
    call :LOG_SUCCESS "發現 ultimate-server.js - 終極選項"
    echo    ✅ ultimate-server.js（終極）
)

:: 按優先順序選擇伺服器，並設定端口（3001 優先，40825 備用）
set "PRIMARY_PORT=3001"
set "BACKUP_PORT=40825"
set "SELECTED_PORT=%PRIMARY_PORT%"

if exist "enhanced-server.js" (
    call :LOG_DEBUG "選擇 enhanced-server.js - 最適合深度精讀模式"
    echo    🚀 選擇：增強版伺服器（深度精讀優化）
    echo    📊 API端點：/api/generate-content（與 Jab.html 完全兼容）
    echo    🎯 特色：深度精讀原則、質量評估、豐富提示
    call :START_SERVER_WITH_FALLBACK "enhanced-server.js"
    set SERVER_TYPE=enhanced
) else if exist "simple-server.js" (
    call :LOG_DEBUG "選擇 simple-server.js - 基礎穩定選項"
    echo    🚀 選擇：基礎版伺服器（穩定運行）
    echo    📊 API端點：/api/generate-content（與 Jab.html 兼容）
    call :START_SERVER_WITH_FALLBACK "simple-server.js"
    set SERVER_TYPE=simple
) else if exist "ultimate-server.js" (
    call :LOG_DEBUG "選擇 ultimate-server.js - 功能最全但API可能不同"
    echo    🚀 選擇：終極版伺服器（功能最全）
    echo    ⚠️ 注意：API端點可能為 /api/ultimate-generate
    echo    🔧 可能需要修改 Jab.html 的 API 調用
    call :START_SERVER_WITH_FALLBACK "ultimate-server.js"
    set SERVER_TYPE=ultimate
) else (
    call :LOG_ERROR "找不到任何伺服器檔案"
    echo ❌ 錯誤：找不到任何伺服器檔案
    echo 📋 請確認以下檔案之一存在：
    echo    - enhanced-server.js（推薦，已優化深度精讀）
    echo    - simple-server.js（基礎穩定）
    echo    - ultimate-server.js（功能完整）
    echo 📂 當前目錄: %CD%
    echo 📁 目錄內容:
    dir "*server*.js" 2>nul
    call :LOG_ERROR "程式終止 - 缺少伺服器檔案"
    pause
    exit /b 1
)

:: 等待伺服器啟動
echo 📝 [5/5] 等待伺服器就緒...
call :LOG_DEBUG "等待伺服器啟動 - 8秒延遲"
echo    ⏳ 正在啟動端口 !SELECTED_PORT!...
timeout /t 8 /nobreak >nul

:: 檢查選定端口狀態
call :LOG_DEBUG "檢查端口 !SELECTED_PORT! 監聽狀態"
netstat -an | find "!SELECTED_PORT!" | find "LISTENING" >nul 2>&1
call :LOG_DEBUG "端口檢查結果: errorlevel=!errorlevel!"
if !errorlevel!==0 (
    call :LOG_SUCCESS "端口 !SELECTED_PORT! 已就緒 - 伺服器啟動成功"
    echo    ✅ 端口 !SELECTED_PORT! 已就緒
    echo.
    echo 🎯 ========== JAB 系統啟動成功 ==========
    echo.
    echo 📋 系統資訊：
    echo    🌐 伺服器地址：http://localhost:!SELECTED_PORT!
    echo    📊 健康檢查：http://localhost:!SELECTED_PORT!/health
    echo    🎨 用戶界面：Jab.html
    echo    🔧 伺服器類型：!SERVER_TYPE!
    echo    📚 內容模式：深度精讀原則
    echo.
    echo 💡 深度精讀特色：
    echo    ✨ 每篇內容 200+ 字，充實有料
    echo    ✨ 基於《Jab, Jab, Jab, Right Hook》原則
    echo    ✨ 提供具體案例和實用建議
    echo    ✨ 避免空洞理論，注重實際價值
    echo    ✨ 結構清晰，邏輯連貫
    echo.
    
    echo ⏳ 等待伺服器完全就緒...
    call :LOG_DEBUG "等待額外3秒確保伺服器完全就緒"
    timeout /t 3 /nobreak >nul
    
    call :LOG_DEBUG "準備啟動 JAB 界面 - 主要啟動點"
    call :LAUNCH_HTML_ADVANCED
    
    echo.
    echo 🔧 =============== 管理選項 ===============
    echo    [1] 重新啟動系統
    echo    [2] 查看伺服器日誌
    echo    [3] 重新打開界面
    echo    [4] 檢查系統狀態
    echo    [5] 手動打開界面（強制）
    echo    [6] 查看調試日誌
    echo    [7] 關閉系統
    echo ==========================================
    echo.
    
    :menu
    choice /c 1234567 /n /m "請選擇操作 [1-7]: "
    set menu_choice=!errorlevel!
    
    if !menu_choice!==1 (
        echo.
        echo 🔄 重新啟動 JAB 系統...
        taskkill /f /im node.exe >nul 2>&1
        timeout /t 3 /nobreak >nul
        start "" "%~f0"
        exit
    )
    
    if !menu_choice!==2 (
        echo.
        echo 📋 伺服器日誌：
        echo ==========================================
        if exist "logs\enhanced-success.log" (
            echo 📊 成功日誌：
            type "logs\enhanced-success.log" | more
        ) else if exist "logs\system.log" (
            echo 📊 系統日誌：
            type "logs\system.log" | more
        ) else if exist "logs\api.log" (
            echo 📊 API 日誌：
            type "logs\api.log" | more
        ) else (
            echo 📝 暫無日誌檔案
        )
        echo ==========================================
        pause
        goto :menu
    )
    
    if !menu_choice!==3 (
        echo.
        echo 🌐 重新打開 JAB 界面...
        call :LOG_DEBUG "用戶選擇重新打開界面"
        call :LAUNCH_HTML_ADVANCED
        pause
        goto :menu
    )
    
    if !menu_choice!==4 (
        echo.
        echo 🔍 系統狀態檢查：
        echo ==========================================
        echo 📊 端口狀態：
        netstat -an | find "3001"
        echo.
        echo 📊 Node.js 進程：
        tasklist | find "node.exe"
        echo ==========================================
        pause
        goto :menu
    )
    
    if !menu_choice!==5 (
        echo.
        echo 💪 手動強制打開 JAB 界面...
        call :LOG_DEBUG "用戶選擇手動強制打開界面"
        call :LAUNCH_HTML_ADVANCED
        echo.
        echo 📋 如果界面仍未打開，請查看日誌：
        echo    🔍 調試日誌: %DEBUG_LOG%
        echo    ❌ 錯誤日誌: %ERROR_LOG%
        echo    🚀 啟動日誌: %LAUNCH_LOG%
        pause
        goto :menu
    )
    
    if !menu_choice!==6 (
        echo.
        echo 📋 查看調試日誌...
        echo ==========================================
        echo 🔍 調試日誌內容：
        if exist "%DEBUG_LOG%" (
            type "%DEBUG_LOG%" | more
        ) else (
            echo 調試日誌文件不存在
        )
        echo.
        echo ❌ 錯誤日誌內容：
        if exist "%ERROR_LOG%" (
            type "%ERROR_LOG%" | more
        ) else (
            echo 錯誤日誌文件不存在
        )
        echo.
        echo 🚀 啟動日誌內容：
        if exist "%LAUNCH_LOG%" (
            type "%LAUNCH_LOG%" | more
        ) else (
            echo 啟動日誌文件不存在
        )
        echo ==========================================
        pause
        goto :menu
    )
    
    if !menu_choice!==7 (
        echo.
        echo 🔄 正在關閉 JAB 系統...
        call :LOG_DEBUG "用戶選擇關閉系統"
        taskkill /f /im node.exe >nul 2>&1
        call :LOG_SUCCESS "系統已安全關閉"
        echo ✅ 系統已安全關閉
        timeout /t 2 /nobreak >nul
        exit
    )
    
) else (
    call :LOG_ERROR "伺服器啟動失敗 - 端口 !SELECTED_PORT! 未監聽"
    echo ❌ 伺服器啟動失敗（端口 !SELECTED_PORT! 未監聽）
    echo.
    echo 🔍 故障排除建議：
    echo    1. 檢查端口 !SELECTED_PORT! 是否被其他程式佔用
    echo    2. 確認防火牆設定允許 Node.js
    echo    3. 檢查 Node.js 是否正確安裝
    echo    4. 查看伺服器錯誤日誌
    echo    5. 嘗試以管理員身分執行
    echo    6. 如果端口 !SELECTED_PORT! 失敗，已自動嘗試端口 !BACKUP_PORT!
    echo.
    echo 🛠️  調試選項：
    echo    [1] 重試啟動
    echo    [2] 檢查端口佔用
    echo    [3] 查看錯誤日誌
    echo    [4] 退出
    echo.
    
    choice /c 1234 /n /m "請選擇 [1-4]: "
    set debug_choice=!errorlevel!
    
    if !debug_choice!==1 goto :restart_attempt
    if !debug_choice!==2 (
        echo.
        echo 📊 端口 !SELECTED_PORT! 使用情況：
        netstat -ano | findstr :!SELECTED_PORT!
        echo.
        echo 📊 備用端口 !BACKUP_PORT! 使用情況：
        netstat -ano | findstr :!BACKUP_PORT!
        pause
        goto :debug_menu
    )
    if !debug_choice!==3 (
        echo.
        echo 📋 錯誤日誌：
        if exist "logs\error.log" (
            type "logs\error.log"
        ) else (
            echo 未找到錯誤日誌
        )
        pause
        goto :debug_menu
    )
    if !debug_choice!==4 exit

:debug_menu
echo.
echo 🛠️  調試選項：
echo    [1] 重試啟動
echo    [2] 檢查端口佔用
echo    [3] 查看錯誤日誌
echo    [4] 退出
echo.

choice /c 1234 /n /m "請選擇 [1-4]: "
set debug_choice=!errorlevel!

if !debug_choice!==1 goto :restart_attempt
if !debug_choice!==2 (
    echo.
    echo 📊 端口 !SELECTED_PORT! 使用情況：
    netstat -ano | findstr :!SELECTED_PORT!
    echo.
    echo 📊 備用端口 !BACKUP_PORT! 使用情況：
    netstat -ano | findstr :!BACKUP_PORT!
    pause
    goto :debug_menu
)
if !debug_choice!==3 (
    echo.
    echo 📋 錯誤日誌：
    if exist "logs\error.log" (
        type "logs\error.log"
    ) else (
        echo 未找到錯誤日誌
    )
    pause
    goto :debug_menu
)
if !debug_choice!==4 exit

:restart_attempt
echo 🔄 重新嘗試啟動...
call :LOG_DEBUG "開始重新啟動流程"

:: 清理所有 node 進程
taskkill /f /im node.exe >nul 2>&1
timeout /t 3 /nobreak >nul

echo 📝 [4/5] 重新啟動深度精讀模式伺服器...

:: 重新設定端口變數
set "PRIMARY_PORT=3001"
set "BACKUP_PORT=40825"
set "SELECTED_PORT=%PRIMARY_PORT%"

if exist "enhanced-server.js" (
    echo    🚀 重新啟動增強版伺服器
    call :START_SERVER_WITH_FALLBACK "enhanced-server.js"
    set SERVER_TYPE=enhanced
) else if exist "simple-server.js" (
    echo    🚀 重新啟動基礎版伺服器
    call :START_SERVER_WITH_FALLBACK "simple-server.js"
    set SERVER_TYPE=simple
) else (
    call :LOG_ERROR "找不到伺服器檔案"
    echo ❌ 錯誤：找不到伺服器檔案
    pause
    exit /b 1
)

echo 📝 [5/5] 檢查伺服器狀態...
timeout /t 3 /nobreak >nul

netstat -an | find "!SELECTED_PORT!" | find "LISTENING" >nul 2>&1
if !errorlevel!==0 (
    echo ✅ 重新啟動成功！端口 !SELECTED_PORT!
    call :LOG_SUCCESS "伺服器重新啟動成功 - 端口 !SELECTED_PORT!"
    call :LOG_DEBUG "準備啟動 JAB 界面 - 重新啟動後"
    call :LAUNCH_HTML_ADVANCED
    pause
    goto :menu
) else (
    echo ❌ 重新啟動失敗
    call :LOG_ERROR "重新啟動失敗 - 端口 !SELECTED_PORT! 未監聽"
    pause
    goto :menu
)

:: ==================== 日誌函數區域 ====================
:LOG_DEBUG
echo [%DATE% %TIME%] DEBUG: %~1 >> "%DEBUG_LOG%"
echo 🔍 DEBUG: %~1
goto :eof

:LOG_ERROR
echo [%DATE% %TIME%] ERROR: %~1 >> "%ERROR_LOG%"
echo ❌ ERROR: %~1
goto :eof

:LOG_SUCCESS
echo [%DATE% %TIME%] SUCCESS: %~1 >> "%SUCCESS_LOG%"
echo ✅ SUCCESS: %~1
goto :eof

:LOG_LAUNCH
echo [%DATE% %TIME%] LAUNCH: %~1 >> "%LAUNCH_LOG%"
echo 🚀 LAUNCH: %~1
goto :eof

:LAUNCH_HTML_ADVANCED
call :LOG_LAUNCH "開始超級強化 HTML 啟動流程"

:: === 第一階段：環境檢查和準備 ===
echo.
echo 🌐 ========== 超級強化 JAB 界面啟動系統 ==========
call :LOG_DEBUG "階段1: 環境檢查和準備"

:: 設定檔案路徑（多種格式）
set "HTML_FILE=%~dp0Jab.html"
set "HTML_FILE_ABS=%CD%\Jab.html"
set "HTML_FILE_SHORT=%~s0\..\Jab.html"
set "HTML_LAUNCHED=false"
set "BROWSER_LAUNCHED=false"

call :LOG_DEBUG "HTML檔案路徑設定："
call :LOG_DEBUG "  - 相對路徑: %HTML_FILE%"
call :LOG_DEBUG "  - 絕對路徑: %HTML_FILE_ABS%"
call :LOG_DEBUG "  - 短路徑: %HTML_FILE_SHORT%"
call :LOG_DEBUG "  - 當前目錄: %CD%"

:: 檢查檔案存在
echo 📂 檢查檔案存在性...
if not exist "%HTML_FILE%" (
    call :LOG_ERROR "找不到檔案: %HTML_FILE%"
    echo ❌ 致命錯誤：找不到 Jab.html 檔案
    echo 📍 預期位置: %HTML_FILE%
    echo 📂 當前目錄: %CD%
    echo 📋 目錄內容:
    dir "*.html" 2>nul
    pause
    goto :eof
)

:: 檔案詳細資訊
call :LOG_SUCCESS "找到 HTML 檔案: %HTML_FILE%"
echo    ✅ 檔案存在: Jab.html
for %%F in ("%HTML_FILE%") do (
    echo    📏 檔案大小: %%~zF bytes
    echo    📅 修改時間: %%~tF
    call :LOG_DEBUG "檔案詳情: 大小=%%~zF bytes, 時間=%%~tF"
)

:: === 第二階段：瀏覽器偵測 ===
call :LOG_DEBUG "階段2: 瀏覽器偵測"
echo 🔍 偵測可用瀏覽器...

set "CHROME_FOUND=false"
set "EDGE_FOUND=false"
set "FIREFOX_FOUND=false"

:: 檢查 Chrome
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
    set "CHROME_FOUND=true"
    call :LOG_SUCCESS "找到 Chrome: %CHROME_PATH%"
    echo    ✅ Google Chrome
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set "CHROME_PATH=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    set "CHROME_FOUND=true"
    call :LOG_SUCCESS "找到 Chrome (x86): %CHROME_PATH%"
    echo    ✅ Google Chrome (x86)
)

:: 檢查 Edge
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    set "EDGE_PATH=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    set "EDGE_FOUND=true"
    call :LOG_SUCCESS "找到 Edge: %EDGE_PATH%"
    echo    ✅ Microsoft Edge
)

:: 檢查 Firefox
if exist "C:\Program Files\Mozilla Firefox\firefox.exe" (
    set "FIREFOX_PATH=C:\Program Files\Mozilla Firefox\firefox.exe"
    set "FIREFOX_FOUND=true"
    call :LOG_SUCCESS "找到 Firefox: %FIREFOX_PATH%"
    echo    ✅ Mozilla Firefox
)

:: === 第三階段：系統啟動方法 ===
call :LOG_DEBUG "階段3: 系統啟動方法"
echo.
echo 🚀 使用系統啟動方法...

echo 📌 方法1: 標準 start 命令
call :LOG_LAUNCH "方法1: start 命令"
start "" "%HTML_FILE%" >nul 2>&1
call :LOG_SUCCESS "方法1 start 完成 - 立即跳過其他方法避免多重啟動"
set "HTML_LAUNCHED=true"
echo    ✅ 已執行 - 跳過其他方法避免多重啟動
goto :LAUNCH_SUCCESS
timeout /t 1 /nobreak >nul

echo 📌 方法2: rundll32 啟動
call :LOG_LAUNCH "方法2: rundll32"
rundll32 url.dll,FileProtocolHandler "%HTML_FILE%" >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_SUCCESS "方法2 rundll32 成功 - 跳過其他方法"
    set "HTML_LAUNCHED=true"
    echo    ✅ 成功 - 已啟動，跳過其他方法
    goto :LAUNCH_SUCCESS
) else (
    call :LOG_ERROR "方法2 rundll32 失敗: errorlevel=!errorlevel!"
    echo    ❌ 失敗
)
timeout /t 1 /nobreak >nul

echo 📌 方法3: explorer 啟動
call :LOG_LAUNCH "方法3: explorer"
explorer "%HTML_FILE%" >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_SUCCESS "方法3 explorer 成功 - 跳過其他方法"
    set "HTML_LAUNCHED=true"
    echo    ✅ 成功 - 已啟動，跳過其他方法
    goto :LAUNCH_SUCCESS
) else (
    call :LOG_ERROR "方法3 explorer 失敗: errorlevel=!errorlevel!"
    echo    ❌ 失敗
)
timeout /t 1 /nobreak >nul

:: === 第四階段：瀏覽器直接啟動 ===
call :LOG_DEBUG "階段4: 瀏覽器直接啟動"
echo.
echo 🌐 使用瀏覽器直接啟動...

if "%CHROME_FOUND%"=="true" (
    echo 📌 方法4: Chrome 直接啟動
    call :LOG_LAUNCH "方法4: Chrome 直接啟動"
    "%CHROME_PATH%" "file:///%HTML_FILE%" >nul 2>&1
    if !errorlevel! equ 0 (
        call :LOG_SUCCESS "方法4 Chrome 成功 - 跳過其他方法"
        set "BROWSER_LAUNCHED=true"
        echo    ✅ Chrome 啟動成功 - 已啟動，跳過其他方法
        goto :LAUNCH_SUCCESS
    ) else (
        call :LOG_ERROR "方法4 Chrome 失敗: errorlevel=!errorlevel!"
        echo    ❌ Chrome 啟動失敗
    )
    timeout /t 1 /nobreak >nul
)

if "%EDGE_FOUND%"=="true" (
    echo 📌 方法5: Edge 直接啟動
    call :LOG_LAUNCH "方法5: Edge 直接啟動"
    "%EDGE_PATH%" "file:///%HTML_FILE%" >nul 2>&1
    if !errorlevel! equ 0 (
        call :LOG_SUCCESS "方法5 Edge 成功 - 跳過其他方法"
        set "BROWSER_LAUNCHED=true"
        echo    ✅ Edge 啟動成功 - 已啟動，跳過其他方法
        goto :LAUNCH_SUCCESS
    ) else (
        call :LOG_ERROR "方法5 Edge 失敗: errorlevel=!errorlevel!"
        echo    ❌ Edge 啟動失敗
    )
    timeout /t 1 /nobreak >nul
)

:: === 第五階段：PowerShell 強制啟動 ===
call :LOG_DEBUG "階段5: PowerShell 強制啟動"
echo.
echo ⚡ 使用 PowerShell 強制啟動...

echo 📌 方法6: PowerShell Start-Process
call :LOG_LAUNCH "方法6: PowerShell Start-Process"
powershell -WindowStyle Hidden -Command "try { Start-Process -FilePath '%HTML_FILE%' -ErrorAction Stop; Write-Host 'SUCCESS' } catch { Write-Host 'FAILED'; exit 1 }" >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_SUCCESS "方法6 PowerShell 成功 - 跳過其他方法"
    set "HTML_LAUNCHED=true"
    echo    ✅ PowerShell 啟動成功 - 已啟動，跳過其他方法
    goto :LAUNCH_SUCCESS
) else (
    call :LOG_ERROR "方法6 PowerShell 失敗: errorlevel=!errorlevel!"
    echo    ❌ PowerShell 啟動失敗
)
timeout /t 1 /nobreak >nul

echo 📌 方法7: PowerShell Invoke-Item
call :LOG_LAUNCH "方法7: PowerShell Invoke-Item"
powershell -WindowStyle Hidden -Command "try { Invoke-Item '%HTML_FILE%' -ErrorAction Stop; Write-Host 'SUCCESS' } catch { Write-Host 'FAILED'; exit 1 }" >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_SUCCESS "方法7 PowerShell Invoke-Item 成功 - 跳過其他方法"
    set "HTML_LAUNCHED=true"
    echo    ✅ PowerShell Invoke-Item 成功 - 已啟動，跳過其他方法
    goto :LAUNCH_SUCCESS
) else (
    call :LOG_ERROR "方法7 PowerShell Invoke-Item 失敗: errorlevel=!errorlevel!"
    echo    ❌ PowerShell Invoke-Item 失敗
)
timeout /t 1 /nobreak >nul

:: === 第六階段：關聯程式啟動 ===
call :LOG_DEBUG "階段6: 關聯程式啟動"
echo.
echo 🔗 使用關聯程式啟動...

echo 📌 方法8: 直接執行檔案
call :LOG_LAUNCH "方法8: 直接執行檔案"
call "%HTML_FILE%" >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_SUCCESS "方法8 直接執行成功 - 跳過其他方法"
    set "HTML_LAUNCHED=true"
    echo    ✅ 直接執行成功 - 已啟動，跳過其他方法
    goto :LAUNCH_SUCCESS
) else (
    call :LOG_ERROR "方法8 直接執行失敗: errorlevel=!errorlevel!"
    echo    ❌ 直接執行失敗
)
timeout /t 1 /nobreak >nul

echo 📌 方法9: CMD 子進程啟動
call :LOG_LAUNCH "方法9: CMD 子進程啟動"
cmd /c start "" "%HTML_FILE%" >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_SUCCESS "方法9 CMD 子進程成功 - 跳過其他方法"
    set "HTML_LAUNCHED=true"
    echo    ✅ CMD 子進程成功 - 已啟動，跳過其他方法
    goto :LAUNCH_SUCCESS
) else (
    call :LOG_ERROR "方法9 CMD 子進程失敗: errorlevel=!errorlevel!"
    echo    ❌ CMD 子進程失敗
)
timeout /t 1 /nobreak >nul

:: === 第七階段：URL 啟動方法 ===
call :LOG_DEBUG "階段7: URL 啟動方法"
echo.
echo 🌐 使用 URL 啟動方法...

:: 轉換為 file:// URL
for /f "delims=" %%i in ("%HTML_FILE%") do set "FILE_URL=file:///%%~fi"
set "FILE_URL=!FILE_URL:\=/!"
call :LOG_DEBUG "File URL: !FILE_URL!"

echo 📌 方法10: URL 協議啟動
call :LOG_LAUNCH "方法10: URL 協議啟動"
start "" "!FILE_URL!" >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_SUCCESS "方法10 URL 協議成功 - 跳過其他方法"
    set "HTML_LAUNCHED=true"
    echo    ✅ URL 協議成功 - 已啟動，跳過其他方法
    goto :LAUNCH_SUCCESS
) else (
    call :LOG_ERROR "方法10 URL 協議失敗: errorlevel=!errorlevel!"
    echo    ❌ URL 協議失敗
)
timeout /t 2 /nobreak >nul

:: === 結果總結 ===
echo.
echo 📊 ========== 啟動結果總結 ==========

if "%HTML_LAUNCHED%"=="true" (
    call :LOG_SUCCESS "HTML 啟動流程完成 - 至少一種方法成功"
    echo ✅ JAB 界面成功啟動！
    echo 🎯 瀏覽器應該已經打開 Jab.html
    echo 🌐 如果頁面未載入，請等待幾秒鐘
) else (
    call :LOG_ERROR "所有HTML啟動方法都失敗"
    echo ❌ 所有啟動方法都失敗！
    echo.
    echo 🔧 手動啟動方案：
    echo    1. 雙擊檔案: %HTML_FILE%
    echo    2. 瀏覽器開啟: file:///%HTML_FILE%
    echo    3. 直接訪問: http://localhost:3001
    echo.
    echo 📋 調試資訊：
    echo    🔍 調試日誌: %DEBUG_LOG%
    echo    ❌ 錯誤日誌: %ERROR_LOG%
    echo    🚀 啟動日誌: %LAUNCH_LOG%
)

echo ======================================================
goto :eof

:LAUNCH_SUCCESS
call :LOG_SUCCESS "HTML 啟動成功 - 僅使用一種方法"
echo.
echo ✅ JAB 界面啟動成功！只使用了一種啟動方法
echo 🌐 如果頁面未載入，請等待幾秒鐘
goto :eof

:START_SERVER_WITH_FALLBACK
:: 參數: %1 = 伺服器檔案名稱
set "SERVER_FILE=%~1"
call :LOG_DEBUG "開始啟動伺服器: %SERVER_FILE%"

:: 嘗試主要端口 (3001)
echo    📡 嘗試啟動端口 %PRIMARY_PORT%...
call :LOG_LAUNCH "嘗試端口 %PRIMARY_PORT% - %SERVER_FILE%"

:: 設定環境變數並啟動伺服器
set PORT=%PRIMARY_PORT%
start "JAB Content Server - Port %PRIMARY_PORT%" cmd /c "set PORT=%PRIMARY_PORT% && node %SERVER_FILE% && echo 伺服器已停止 && pause"

:: 等待伺服器啟動
timeout /t 5 /nobreak >nul

:: 檢查主要端口是否成功
netstat -an | find "%PRIMARY_PORT%" | find "LISTENING" >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_SUCCESS "端口 %PRIMARY_PORT% 啟動成功"
    set "SELECTED_PORT=%PRIMARY_PORT%"
    echo    ✅ 端口 %PRIMARY_PORT% 啟動成功
    goto :eof
)

:: 主要端口失敗，嘗試備用端口
call :LOG_DEBUG "端口 %PRIMARY_PORT% 失敗，嘗試備用端口 %BACKUP_PORT%"
echo    ⚠️ 端口 %PRIMARY_PORT% 失敗，嘗試備用端口 %BACKUP_PORT%...

:: 終止可能的殘留進程
taskkill /f /im node.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: 啟動備用端口
call :LOG_LAUNCH "嘗試端口 %BACKUP_PORT% - %SERVER_FILE%"
set PORT=%BACKUP_PORT%
start "JAB Content Server - Port %BACKUP_PORT%" cmd /c "set PORT=%BACKUP_PORT% && node %SERVER_FILE% && echo 伺服器已停止 && pause"

:: 等待備用伺服器啟動
timeout /t 5 /nobreak >nul

:: 檢查備用端口
netstat -an | find "%BACKUP_PORT%" | find "LISTENING" >nul 2>&1
if !errorlevel! equ 0 (
    call :LOG_SUCCESS "備用端口 %BACKUP_PORT% 啟動成功"
    set "SELECTED_PORT=%BACKUP_PORT%"
    echo    ✅ 備用端口 %BACKUP_PORT% 啟動成功
) else (
    call :LOG_ERROR "所有端口都失敗: %PRIMARY_PORT%, %BACKUP_PORT%"
    set "SELECTED_PORT=%PRIMARY_PORT%"
    echo    ❌ 所有端口都失敗
)

goto :eof