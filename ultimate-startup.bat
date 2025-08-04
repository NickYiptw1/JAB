@echo off
chcp 65001 >nul
title 終極版AI內容生產器 v2.0 - 深思模式啟動

:: 設定環境
cd /d "%~dp0"
color 0A

echo.
echo 🌟 ========================================================
echo    終極版AI內容生產器 v2.0 正在啟動...
echo    🔍 網路搜尋 + 🧠 深思模式 + 📊 真實數據 + 📖 案例庫
echo ========================================================
echo.

:: 系統檢查
echo 🔍 [1/6] 系統環境檢查...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js 未安裝或未加入PATH
    echo 📥 請前往 https://nodejs.org/ 下載並安裝 Node.js LTS版本
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('node --version 2^>nul') do set NODE_VERSION=%%v
echo    ✅ Node.js: %NODE_VERSION%

:: 檢查核心文件
echo 🔍 [2/6] 檢查終極版核心文件...
if not exist "ultimate-server.js" (
    echo ❌ 缺少核心文件: ultimate-server.js
    echo 💡 請確認終極版伺服器文件存在
    pause
    exit /b 1
)

if not exist "ultimate-frontend.html" (
    echo ❌ 缺少前端文件: ultimate-frontend.html
    echo 💡 請確認終極版前端文件存在
    pause
    exit /b 1
)

echo    ✅ ultimate-server.js - 核心伺服器
echo    ✅ ultimate-frontend.html - 終極前端

:: 檢查依賴
echo 🔍 [3/6] 檢查項目依賴...
if not exist "node_modules" (
    echo 📦 首次啟動，正在安裝依賴...
    echo 📍 安裝項目: express, cors, axios, fs, path
    npm install --silent
    if %errorlevel% neq 0 (
        echo ❌ 依賴安裝失敗
        echo 💡 請檢查網路連接或手動執行: npm install
        pause
        exit /b 1
    )
    echo    ✅ 依賴安裝完成
) else (
    echo    ✅ 依賴已就緒
)

:: 清理環境
echo 🔍 [4/6] 清理系統環境...
taskkill /f /im node.exe >nul 2>&1
echo    🧹 清理舊進程
timeout /t 3 /nobreak >nul

:: 準備日誌和緩存目錄
echo 🔍 [5/6] 準備系統目錄...
if not exist "logs" mkdir logs
if not exist "cache" mkdir cache
if not exist "examples" mkdir examples
echo    📁 系統目錄已就緒

:: 網路連接測試
echo 🔍 [6/6] 測試網路連接...
ping -n 1 api.duckduckgo.com >nul 2>&1
if %errorlevel%==0 (
    echo    ✅ 網路搜尋功能可用
) else (
    echo    ⚠️  網路搜尋可能受限，將使用本地知識庫
)

echo.
echo 🚀 ========================================================
echo    啟動終極版AI內容生產器 v2.0
echo ========================================================
echo.
echo 🎯 核心特色:
echo    🔍 即時網路搜尋 - 獲取最新資料和趨勢
echo    🧠 深思模式分析 - 4階段深度思考框架
echo    📊 真實數據整合 - 包含具體案例和統計
echo    📖 智能案例庫 - Google、Microsoft等成功案例
echo    🎨 多維風格差異化 - 真正的平台和風格差異
echo    ⏰ 延長處理時間 - 2分30秒深度生成
echo    🚫 零書名提及 - 完全移除書籍相關內容
echo.
echo 🔧 技術架構:
echo    🌐 網路搜尋: DuckDuckGo API + 本地知識庫備援
echo    🧠 分析框架: 問題分析 → 解決方案 → 內容策略
echo    📝 提示優化: 平台專屬 + 風格差異 + 真實數據
echo    🤖 AI模型: 3個備用配置自動切換
echo.

start "終極版AI內容伺服器" cmd /c "echo 🎯 終極版AI內容生產器 v2.0 啟動中... && echo. && echo 🔍 整合網路搜尋功能... && echo 🧠 載入深思模式框架... && echo 📚 準備真實案例庫... && echo 🎨 配置多維風格系統... && echo. && echo 🌐 服務地址: http://localhost:3001 && echo ⏰ 最長處理時間: 2分30秒 && echo 💡 每次生成都包含真實資料和深度分析 && echo. && node ultimate-server.js"

echo ⏰ 等待終極版系統初始化... (15秒)
timeout /t 15 /nobreak >nul

echo 🧪 測試終極版服務連接...
powershell -Command "try { $response = Invoke-RestMethod http://localhost:3001/health -TimeoutSec 10; if($response.status -eq 'ok') { Write-Host '✅ 終極版系統啟動成功！' -ForegroundColor Green; Write-Host ('🎯 服務: ' + $response.service + ' ' + $response.version) -ForegroundColor Cyan; Write-Host ('🔧 功能數: ' + $response.features.Count) -ForegroundColor Yellow; exit 0 } else { exit 1 } } catch { Write-Host '❌ 連接失敗，正在重試...' -ForegroundColor Red; exit 1 }" >nul 2>&1

if %errorlevel%==0 (
    echo ✅ 終極版系統啟動成功！
    echo.
    
    echo 🌐 正在開啟終極版界面...
    start "" "ultimate-frontend.html"
    timeout /t 3 /nobreak >nul
    
    echo.
    echo 🎉 ========================================================
    echo    終極版AI內容生產器 v2.0 已成功啟動！
    echo ========================================================
    echo.
    echo 📋 使用指南:
    echo.
    echo 🎯 **基本操作**:
    echo    1. 在前端界面輸入具體主題
    echo    2. 選擇平台、風格、內容類型
    echo    3. 勾選「深思模式」（推薦）
    echo    4. 點擊「開始深度生成」
    echo    5. 等待2-3分鐘獲得高質量內容
    echo.
    echo 🔍 **深思模式流程**:
    echo    階段1 (30秒): 🔍 網路搜尋相關資料
    echo    階段2 (60秒): 🧠 深度分析思考框架
    echo    階段3 (15秒): 📝 智能提示詞構建
    echo    階段4 (45秒): 🤖 AI深度內容生成
    echo.
    echo 📊 **內容品質保證**:
    echo    ✅ 包含真實數據和最新趨勢
    echo    ✅ 整合成功企業案例
    echo    ✅ 平台差異化明顯（Facebook ≠ LinkedIn）
    echo    ✅ 風格差異化顯著（專業 ≠ 激勵）
    echo    ✅ 每次生成都獨一無二
    echo    ✅ 完全無書名提及
    echo    ✅ 具體可執行的建議
    echo    ✅ 情感共鳴和貼地內容
    echo.
    echo 💡 **測試建議**:
    echo    🧪 先測試相同主題，不同平台的差異
    echo    🎨 再測試相同平台，不同風格的差異
    echo    🔄 然後測試相同設定的內容多樣性
    echo    📊 觀察每篇內容的真實數據整合
    echo.
    echo 🎯 **系統管理選項**:
    echo    [1] 查看即時系統狀態
    echo    [2] 測試網路搜尋功能
    echo    [3] 查看生成日誌
    echo    [4] 重啟服務
    echo    [5] 開啟備用前端
    echo    [6] 系統診斷
    echo    [7] 保持運行
    echo.
    
    choice /c 1234567 /n /m "選擇操作 [1-7]: "
    
    if !errorlevel!==1 (
        echo.
        echo 📊 查看即時系統狀態...
        powershell -Command "try { $response = Invoke-RestMethod http://localhost:3001/health; Write-Host '🎯 系統服務:' $response.service $response.version -ForegroundColor Green; Write-Host '⚙️  當前配置:' $response.current_config -ForegroundColor Cyan; Write-Host '🔧 功能特色:' -ForegroundColor Yellow; $response.features | ForEach-Object { Write-Host '   ✅' $_ -ForegroundColor White }; Write-Host '⏰ 最長處理時間:' $response.processing_time -ForegroundColor Magenta } catch { Write-Host '❌ 無法獲取狀態' -ForegroundColor Red }"
        pause
    )
    
    if !errorlevel!==2 (
        echo.
        echo 🧪 測試網路搜尋功能...
        powershell -Command "try { $body = @{ query = '人工智能趨勢 2024'; maxResults = 3 } | ConvertTo-Json; $response = Invoke-RestMethod -Uri 'http://localhost:3001/api/web-search' -Method Post -Body $body -ContentType 'application/json'; Write-Host '✅ 搜尋測試成功！' -ForegroundColor Green; Write-Host ('搜尋結果: ' + $response.count + ' 條') -ForegroundColor Cyan } catch { Write-Host '❌ 搜尋測試失敗' -ForegroundColor Red }"
        pause
    )
    
    if !errorlevel!==3 (
        echo.
        echo 📋 查看系統日誌...
        if exist "logs\ultimate-success.log" (
            echo === 成功日誌 (最近10條) ===
            powershell -Command "Get-Content 'logs\ultimate-success.log' | Select-Object -Last 10"
        ) else (
            echo 暫無成功日誌
        )
        if exist "logs\ultimate-error.log" (
            echo.
            echo === 錯誤日誌 (最近5條) ===
            powershell -Command "Get-Content 'logs\ultimate-error.log' | Select-Object -Last 5"
        ) else (
            echo 暫無錯誤日誌
        )
        pause
    )
    
    if !errorlevel!==4 (
        echo.
        echo 🔄 重啟終極版服務...
        taskkill /f /im node.exe >nul 2>&1
        echo 等待3秒後重新啟動...
        timeout /t 3 /nobreak >nul
        start "" "%~f0"
        exit
    )
    
    if !errorlevel!==5 (
        echo.
        echo 🌐 開啟備用前端界面...
        if exist "enhanced-frontend.html" (
            start "" "enhanced-frontend.html"
            echo ✅ 已開啟增強版前端
        ) else if exist "Jab.html" (
            start "" "Jab.html"
            echo ✅ 已開啟標準前端
        ) else (
            echo ❌ 找不到備用前端文件
        )
        pause
    )
    
    if !errorlevel!==6 (
        echo.
        echo 🔍 系統診斷中...
        echo.
        echo 📁 文件檢查:
        dir ultimate-server.js >nul 2>&1 && echo ✅ ultimate-server.js || echo ❌ ultimate-server.js
        dir ultimate-frontend.html >nul 2>&1 && echo ✅ ultimate-frontend.html || echo ❌ ultimate-frontend.html
        dir node_modules >nul 2>&1 && echo ✅ node_modules || echo ❌ node_modules
        dir logs >nul 2>&1 && echo ✅ logs 目錄 || echo ❌ logs 目錄
        dir cache >nul 2>&1 && echo ✅ cache 目錄 || echo ❌ cache 目錄
        echo.
        echo 🌐 網路測試:
        ping -n 1 8.8.8.8 >nul 2>&1 && echo ✅ 網路連接正常 || echo ❌ 網路連接問題
        ping -n 1 api.duckduckgo.com >nul 2>&1 && echo ✅ 搜尋API可達 || echo ⚠️  搜尋API受限
        echo.
        echo 🔧 端口檢查:
        netstat -an | findstr ":3001" >nul 2>&1 && echo ✅ 端口3001已使用 || echo ⚠️  端口3001空閒
        pause
    )
    
    if !errorlevel!==7 (
        echo.
        echo ✅ 終極版系統持續運行中...
        echo 💡 您可以安全關閉此視窗
        echo 🎯 前端界面: ultimate-frontend.html
        echo 🌐 服務地址: http://localhost:3001
        echo ⏰ 建議每次生成1-2篇內容獲得最佳品質
        echo 🔍 每次生成都會搜尋最新資料和案例
        echo.
        echo 特色提醒:
        echo 📊 真實數據整合: 每篇內容都包含具體統計和案例
        echo 🧠 深思模式: 4階段分析確保內容深度和價值
        echo 🎨 風格差異: 不同平台和風格產出完全不同內容
        echo 🚫 品質保證: 絕無書名提及，內容純淨專業
        echo.
        pause
        exit
    )

) else (
    echo ❌ 終極版系統啟動失敗
    echo.
    echo 🔍 故障排除指南:
    echo.
    echo [1] 檢查終極版文件完整性
    echo [2] 重新安裝依賴包
    echo [3] 清理端口並重試
    echo [4] 查看詳細錯誤日誌
    echo [5] 使用標準版本
    echo [6] 強制重新初始化
    echo [7] 退出程式
    echo.
    
    choice /c 1234567 /n /m "選擇故障排除方案 [1-7]: "
    
    if !errorlevel!==1 (
        echo.
        echo 📁 檢查終極版文件...
        echo.
        dir ultimate-server.js 2>nul && (
            for %%i in (ultimate-server.js) do echo ✅ ultimate-server.js - %%~zi bytes
        ) || echo ❌ ultimate-server.js 不存在
        
        dir ultimate-frontend.html 2>nul && (
            for %%i in (ultimate-frontend.html) do echo ✅ ultimate-frontend.html - %%~zi bytes
        ) || echo ❌ ultimate-frontend.html 不存在
        
        dir package.json 2>nul && echo ✅ package.json || echo ❌ package.json 不存在
        pause
    )
    
    if !errorlevel!==2 (
        echo.
        echo 🔄 重新安裝依賴包...
        if exist node_modules rmdir /s /q node_modules
        if exist package-lock.json del package-lock.json
        echo 開始重新安裝...
        npm install
        echo.
        echo ✅ 依賴重新安裝完成，請重新啟動系統
        pause
    )
    
    if !errorlevel!==3 (
        echo.
        echo 🧹 清理端口並重試...
        echo 終止所有Node進程...
        taskkill /f /im node.exe >nul 2>&1
        echo 等待5秒...
        timeout /t 5 /nobreak >nul
        echo 重新啟動...
        start "" "%~f0"
        exit
    )
    
    if !errorlevel!==4 (
        echo.
        echo 📋 查看錯誤日誌...
        if exist "logs\ultimate-error.log" (
            echo === 最新錯誤記錄 ===
            type "logs\ultimate-error.log" | more
        ) else (
            echo 暫無錯誤日誌文件
            echo 可能是首次啟動或文件系統權限問題
        )
        pause
    )
    
    if !errorlevel!==5 (
        echo.
        echo 🔄 嘗試啟動標準版本...
        if exist "enhanced-server.js" (
            echo 使用增強版伺服器...
            start "" cmd /c "node enhanced-server.js && pause"
            timeout /t 5 /nobreak >nul
            if exist "enhanced-frontend.html" (
                start "" "enhanced-frontend.html"
            ) else if exist "Jab.html" (
                start "" "Jab.html"
            )
            echo ✅ 標準版本已啟動
        ) else if exist "simple-server-fixed.js" (
            echo 使用修復版伺服器...
            start "" cmd /c "node simple-server-fixed.js && pause"
            timeout /t 5 /nobreak >nul
            if exist "Jab.html" start "" "Jab.html"
            echo ✅ 修復版本已啟動
        ) else (
            echo ❌ 找不到任何可用的伺服器版本
        )
        pause
    )
    
    if !errorlevel!==6 (
        echo.
        echo 🔧 強制重新初始化系統...
        echo 清理所有緩存和日誌...
        if exist logs rmdir /s /q logs 2>nul
        if exist cache rmdir /s /q cache 2>nul
        if exist node_modules rmdir /s /q node_modules 2>nul
        if exist package-lock.json del package-lock.json 2>nul
        echo 重新創建目錄...
        mkdir logs 2>nul
        mkdir cache 2>nul
        mkdir examples 2>nul
        echo 重新安裝依賴...
        npm install
        echo ✅ 系統重新初始化完成
        echo 請重新運行啟動腳本
        pause
    )
    
    if !errorlevel!==7 (
        echo.
        echo 👋 退出終極版啟動程式
        echo 💡 如需技術支援，請檢查:
        echo    - Node.js 是否正確安裝
        echo    - 網路連接是否正常
        echo    - 系統權限是否足夠
        echo    - 端口3001是否被其他程式占用
        exit
    )
)

echo.
echo 🎯 終極版AI內容生產器 v2.0
echo 💡 深思模式 + 網路搜尋 + 真實案例 + 多維風格
echo 🚀 每次使用都能產出獨特且有價值的內容！
pause
goto :eof 