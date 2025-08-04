@echo off
chcp 65001 >nul
title Enhanced AI內容生產器 - 超級啟動

:: 設定目錄和顏色
cd /d "%~dp0"
color 0A

echo.
echo 🚀 ================================================
echo    Enhanced AI內容生產器 - 超級啟動系統
echo    多模型配置 + 智能品質檢查 + 深度優化
echo ================================================
echo.

:: 檢查 Node.js
echo ✅ 檢查 Node.js 環境...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js 未安裝！請先安裝 Node.js
    echo 📥 下載地址: https://nodejs.org/
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('node --version 2^>nul') do set NODE_VERSION=%%v
echo    ✅ Node.js 版本: %NODE_VERSION%

:: 檢查關鍵文件
echo ✅ 檢查系統文件...
if not exist "enhanced-server.js" (
    echo ❌ 缺少 enhanced-server.js
    echo 💡 請確認增強版伺服器文件存在
    pause
    exit /b 1
)

if not exist "enhanced-frontend.html" (
    echo ❌ 缺少 enhanced-frontend.html  
    echo 💡 請確認增強版前端文件存在
    pause
    exit /b 1
)

echo    ✅ enhanced-server.js 存在
echo    ✅ enhanced-frontend.html 存在

:: 檢查和安裝依賴
echo ✅ 檢查依賴套件...
if not exist "node_modules" (
    echo 📦 安裝依賴中（這可能需要幾分鐘）...
    npm install --silent
    if %errorlevel% neq 0 (
        echo ❌ 依賴安裝失敗
        pause
        exit /b 1
    )
    echo    ✅ 依賴安裝完成
) else (
    echo    ✅ 依賴已安裝
)

:: 清理端口和進程
echo ✅ 清理系統環境...
echo    🔄 終止舊的 Node 進程...
taskkill /f /im node.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo    🔄 檢查端口 3001...
netstat -ano | findstr ":3001" >nul 2>&1
if %errorlevel%==0 (
    echo    ⚠️  端口被佔用，正在清理...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3001"') do (
        taskkill /PID %%a /F >nul 2>&1
    )
    timeout /t 2 /nobreak >nul
)
echo    ✅ 端口清理完成

:: 創建日誌目錄
if not exist "logs" mkdir logs

:: 啟動增強版伺服器
echo 🚀 啟動增強版AI內容生產器...
echo.
echo 📊 系統特色:
echo    ✨ 多AI模型自動切換
echo    🎯 智能品質評估系統
echo    📈 即時性能監控
echo    💬 專業行銷顧問助手
echo    🔄 自動錯誤恢復機制
echo.

echo 🔄 正在啟動增強版伺服器...
start "Enhanced AI Content Server" cmd /c "echo 🚀 Enhanced AI內容生產器伺服器啟動中... && echo 📍 服務地址: http://localhost:3001 && echo 💡 保持此視窗開啟以維持服務運行 && echo. && node enhanced-server.js"

:: 等待伺服器啟動
echo ⏰ 等待伺服器完全啟動 (15秒)...
timeout /t 15 /nobreak >nul

:: 測試連接
echo 🧪 測試增強版伺服器連接...
powershell -Command "try { $response = Invoke-RestMethod http://localhost:3001/health -TimeoutSec 10; if($response.status -eq 'ok') { Write-Host '✅ 增強版伺服器啟動成功！' -ForegroundColor Green; Write-Host ('📊 可用AI配置: ' + $response.api_configs) -ForegroundColor Cyan; Write-Host ('🤖 當前模型: ' + $response.current_config) -ForegroundColor Yellow; exit 0 } else { exit 1 } } catch { Write-Host '❌ 連接失敗' -ForegroundColor Red; exit 1 }" >nul 2>&1

if %errorlevel%==0 (
    echo ✅ 系統啟動成功！
    echo.
    echo 🌐 正在打開增強版用戶界面...
    start "" "enhanced-frontend.html"
    
    echo.
    echo 🎉 ================================================
    echo    Enhanced AI內容生產器已成功啟動！
    echo ================================================
    echo.
    echo 📋 系統信息:
    echo    🌐 增強版界面: enhanced-frontend.html (已開啟)
    echo    🔗 API伺服器: http://localhost:3001
    echo    📊 健康檢查: http://localhost:3001/health
    echo    🔧 系統診斷: http://localhost:3001/api/diagnosis
    echo    📋 多模型配置: 自動切換最佳AI模型
    echo.
    echo 💡 使用指南:
    echo    1. 確認界面右上角顯示 "已連接 (Enhanced)"
    echo    2. 在AI模型配置區域查看可用模型
    echo    3. 啟用品質檢查以獲得最佳結果
    echo    4. 使用AI行銷顧問獲取專業建議
    echo    5. 首次使用建議選擇1-2篇內容測試
    echo.
    echo 🔥 增強功能:
    echo    ⚡ 多AI模型智能備援
    echo    🎯 內容品質自動評估
    echo    📈 即時統計和性能監控
    echo    💬 專業行銷策略諮詢
    echo    🔄 自動錯誤恢復和重試
    echo    📊 詳細的生成過程日誌
    echo.
    echo 🎯 管理選項:
    echo    [1] 查看系統診斷
    echo    [2] 切換AI模型
    echo    [3] 查看詳細日誌
    echo    [4] 重啟系統
    echo    [5] 關閉系統
    echo    [6] 保持運行
    echo.
    
    choice /c 123456 /n /m "請選擇 [1-6]: "
    
    if !errorlevel!==1 (
        echo.
        echo 🔍 開啟系統診斷...
        start "" "http://localhost:3001/api/diagnosis"
        pause
    )
    
    if !errorlevel!==2 (
        echo.
        echo 🔄 開啟API配置管理...
        start "" "http://localhost:3001/api/configs"
        pause
    )
    
    if !errorlevel!==3 (
        echo.
        echo 📋 查看系統日誌...
        if exist "logs\enhanced-success.log" (
            echo === 成功日誌 ===
            type "logs\enhanced-success.log" | more
        )
        if exist "logs\enhanced-error.log" (
            echo === 錯誤日誌 ===  
            type "logs\enhanced-error.log" | more
        )
        pause
    )
    
    if !errorlevel!==4 (
        echo.
        echo 🔄 重啟增強版系統...
        taskkill /f /im node.exe >nul 2>&1
        timeout /t 3 /nobreak >nul
        start "Enhanced AI Content Server" cmd /c "node enhanced-server.js"
        echo ✅ 系統重啟完成
        pause
    )
    
    if !errorlevel!==5 (
        echo.
        echo 🔄 關閉增強版系統...
        taskkill /f /im node.exe >nul 2>&1
        echo ✅ 系統已完全關閉
        pause
        exit
    )
    
    if !errorlevel!==6 (
        echo.
        echo ✅ 增強版系統持續運行中
        echo 💡 可安全關閉此視窗，系統將在背景運行
        echo 🔄 如需管理，請重新執行此啟動檔
        pause
        exit
    )

) else (
    echo ❌ 增強版伺服器啟動失敗
    echo.
    echo 🔍 故障診斷:
    echo    1. 檢查 enhanced-server.js 是否存在
    echo    2. 確認 Node.js 版本是否支援 (建議 16+)
    echo    3. 檢查網路連接和防火牆設定
    echo    4. 查看錯誤日誌: logs\enhanced-error.log
    echo.
    echo 🛠️  故障排除選項:
    echo    [1] 使用標準模式重試
    echo    [2] 檢查系統需求
    echo    [3] 查看錯誤日誌
    echo    [4] 重新安裝依賴
    echo    [5] 退出
    echo.
    
    choice /c 12345 /n /m "請選擇 [1-5]: "
    
    if !errorlevel!==1 (
        echo 🔄 嘗試標準模式...
        if exist "simple-server-fixed.js" (
            node simple-server-fixed.js
        ) else (
            echo ❌ 標準伺服器文件不存在
        )
        pause
    )
    
    if !errorlevel!==2 (
        echo 📊 系統需求檢查:
        echo    ✅ Node.js 16+ : %NODE_VERSION%
        echo    ✅ NPM 包管理器: 
        npm --version 2>nul || echo ❌ NPM 不可用
        echo    📁 工作目錄: %CD%
        echo    💾 可用空間: 至少 100MB
        pause
    )
    
    if !errorlevel!==3 (
        echo 📋 錯誤日誌:
        if exist "logs\enhanced-error.log" (
            type "logs\enhanced-error.log"
        ) else (
            echo 暫無錯誤日誌
        )
        pause
    )
    
    if !errorlevel!==4 (
        echo 🔄 重新安裝依賴...
        rmdir /s /q node_modules 2>nul
        del package-lock.json 2>nul
        npm install
        echo ✅ 依賴重新安裝完成，請重新啟動
        pause
    )
    
    if !errorlevel!==5 exit
)

goto :eof 