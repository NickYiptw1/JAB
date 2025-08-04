# AI內容生產器 - PowerShell 啟動腳本
param(
    [switch]$Debug,
    [switch]$SkipDependencyCheck
)

# 設定控制台編碼
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 設定目錄
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host ""
Write-Host "🚀 ===============================================" -ForegroundColor Green
Write-Host "   AI內容生產器 - PowerShell 啟動系統" -ForegroundColor Green  
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📍 腳本目錄: $ScriptDir" -ForegroundColor Yellow
Write-Host "📂 工作目錄: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

# 檢查 Node.js
Write-Host "🔍 檢查 Node.js 安裝..." -ForegroundColor Cyan
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js 版本: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ 錯誤: Node.js 未安裝或未加入PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "📥 請先安裝 Node.js:" -ForegroundColor Yellow
    Write-Host "   1. 前往 https://nodejs.org/" -ForegroundColor White
    Write-Host "   2. 下載 LTS 版本" -ForegroundColor White
    Write-Host "   3. 安裝後重新啟動此程式" -ForegroundColor White
    Write-Host ""
    Read-Host "按 Enter 鍵結束"
    exit 1
}
Write-Host ""

# 檢查必要文件
Write-Host "🔍 檢查系統文件..." -ForegroundColor Cyan
$requiredFiles = @("simple-server-fixed.js", "Jab.html", "package.json")
$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $file" -ForegroundColor Red
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "❌ 缺少必要文件: $($missingFiles -join ', ')" -ForegroundColor Red
    Read-Host "按 Enter 鍵結束"
    exit 1
}
Write-Host ""

# 檢查依賴
if (-not $SkipDependencyCheck) {
    Write-Host "🔍 檢查依賴安裝..." -ForegroundColor Cyan
    if (-not (Test-Path "node_modules")) {
        Write-Host "⚠️  node_modules 不存在，正在安裝依賴..." -ForegroundColor Yellow
        Write-Host ""
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ 依賴安裝失敗" -ForegroundColor Red
            Read-Host "按 Enter 鍵結束"
            exit 1
        }
        Write-Host "✅ 依賴安裝完成" -ForegroundColor Green
    } else {
        Write-Host "✅ 依賴已安裝" -ForegroundColor Green
    }
    Write-Host ""
}

# 檢查端口
Write-Host "🔍 檢查端口 3001 狀態..." -ForegroundColor Cyan
$portUsed = Get-NetTCPConnection -LocalPort 3001 -ErrorAction SilentlyContinue
if ($portUsed) {
    Write-Host "⚠️  端口 3001 已被使用，正在清理..." -ForegroundColor Yellow
    
    # 終止佔用端口的進程
    $processes = Get-Process -Name "node" -ErrorAction SilentlyContinue
    foreach ($proc in $processes) {
        Write-Host "   終止進程: $($proc.Name) (PID: $($proc.Id))" -ForegroundColor Yellow
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
    
    Start-Sleep -Seconds 2
    Write-Host "✅ 端口清理完成" -ForegroundColor Green
} else {
    Write-Host "✅ 端口 3001 可用" -ForegroundColor Green
}
Write-Host ""

# 啟動伺服器
Write-Host "🚀 啟動 AI 內容生產器伺服器..." -ForegroundColor Green
Write-Host ""
Write-Host "📝 正在啟動修復版伺服器..." -ForegroundColor Cyan
Write-Host "   - 文件: simple-server-fixed.js" -ForegroundColor White
Write-Host "   - 端口: 3001" -ForegroundColor White
Write-Host "   - 日誌: 啟用" -ForegroundColor White
Write-Host ""

if ($Debug) {
    # 調試模式：在當前視窗中啟動
    Write-Host "🐛 調試模式：在當前視窗中啟動伺服器" -ForegroundColor Yellow
    node simple-server-fixed.js
} else {
    # 正常模式：在新視窗中啟動
    $serverProcess = Start-Process -FilePath "node" -ArgumentList "simple-server-fixed.js" -WindowStyle Minimized -PassThru
    
    # 等待伺服器啟動
    Write-Host "⏰ 等待伺服器啟動 (10秒)..." -ForegroundColor Cyan
    Start-Sleep -Seconds 10
    
    # 測試伺服器連接
    Write-Host "🧪 測試伺服器連接..." -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:3001/health" -TimeoutSec 5
        if ($response.status -eq "ok") {
            Write-Host "✅ 伺服器啟動成功！" -ForegroundColor Green
            Write-Host ""
            Write-Host "🌐 正在打開用戶界面..." -ForegroundColor Cyan
            
            # 打開主界面
            Start-Process "Jab.html"
            
            Write-Host ""
            Write-Host "🎉 ===============================================" -ForegroundColor Green
            Write-Host "   AI內容生產器已成功啟動！" -ForegroundColor Green
            Write-Host "===============================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 系統信息:" -ForegroundColor Cyan
            Write-Host "   🌐 主界面: Jab.html (已自動打開)" -ForegroundColor White
            Write-Host "   🔗 伺服器: http://localhost:3001" -ForegroundColor White
            Write-Host "   📊 健康檢查: http://localhost:3001/health" -ForegroundColor White
            Write-Host "   📋 日誌查看: http://localhost:3001/api/logs" -ForegroundColor White
            Write-Host ""
            Write-Host "💡 使用提示:" -ForegroundColor Yellow
            Write-Host "   1. 確認右上角顯示 '已連接 (3001)'" -ForegroundColor White
            Write-Host "   2. 輸入主題開始生成內容" -ForegroundColor White
            Write-Host "   3. 建議首次使用選擇 1 篇內容測試" -ForegroundColor White
            Write-Host "   4. 如有問題，請查看日誌或重新啟動" -ForegroundColor White
            Write-Host ""
            
            # 管理選項
            do {
                Write-Host "🔧 管理選項:" -ForegroundColor Cyan
                Write-Host "   [1] 重新啟動伺服器" -ForegroundColor White
                Write-Host "   [2] 查看伺服器日誌" -ForegroundColor White
                Write-Host "   [3] 打開日誌查看器" -ForegroundColor White
                Write-Host "   [4] 關閉系統" -ForegroundColor White
                Write-Host "   [5] 保持運行並退出" -ForegroundColor White
                Write-Host ""
                
                $choice = Read-Host "請選擇 [1-5]"
                
                switch ($choice) {
                    "1" {
                        Write-Host ""
                        Write-Host "🔄 重新啟動伺服器..." -ForegroundColor Yellow
                        Stop-Process -Name "node" -Force -ErrorAction SilentlyContinue
                        Start-Sleep -Seconds 2
                        $serverProcess = Start-Process -FilePath "node" -ArgumentList "simple-server-fixed.js" -WindowStyle Minimized -PassThru
                        Start-Sleep -Seconds 5
                        Write-Host "✅ 伺服器已重新啟動" -ForegroundColor Green
                    }
                    "2" {
                        Write-Host ""
                        Write-Host "📋 顯示伺服器日誌..." -ForegroundColor Cyan
                        if (Test-Path "logs\server-system.log") {
                            Get-Content "logs\server-system.log" | Select-Object -Last 20
                        } else {
                            Write-Host "日誌文件不存在" -ForegroundColor Yellow
                        }
                        Read-Host "按 Enter 繼續"
                    }
                    "3" {
                        Write-Host ""
                        Write-Host "🌐 打開日誌查看器..." -ForegroundColor Cyan
                        Start-Process "log-viewer.html"
                    }
                    "4" {
                        Write-Host ""
                        Write-Host "🔄 關閉系統..." -ForegroundColor Yellow
                        Stop-Process -Name "node" -Force -ErrorAction SilentlyContinue
                        Write-Host "✅ 系統已關閉" -ForegroundColor Green
                        Read-Host "按 Enter 鍵結束"
                        exit
                    }
                    "5" {
                        Write-Host ""
                        Write-Host "✅ 系統持續運行中，可安全關閉此視窗" -ForegroundColor Green
                        Write-Host "💡 如需管理系統，請重新執行此程式" -ForegroundColor Yellow
                        Read-Host "按 Enter 鍵結束"
                        exit
                    }
                    default {
                        Write-Host "無效選擇，請輸入 1-5" -ForegroundColor Red
                    }
                }
                Write-Host ""
            } while ($choice -notin @("4", "5"))
            
        } else {
            throw "伺服器響應異常"
        }
    } catch {
        Write-Host "❌ 伺服器啟動失敗: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "🔍 故障排除建議:" -ForegroundColor Yellow
        Write-Host "   1. 檢查是否有其他程式佔用端口 3001" -ForegroundColor White
        Write-Host "   2. 確認 Node.js 正確安裝" -ForegroundColor White
        Write-Host "   3. 檢查網路防火牆設定" -ForegroundColor White
        Write-Host "   4. 使用調試模式：-Debug 參數" -ForegroundColor White
        Write-Host ""
        
        $debugChoice = Read-Host "是否使用調試模式重試？ (y/n)"
        if ($debugChoice -eq "y" -or $debugChoice -eq "Y") {
            Write-Host "🐛 啟動調試模式..." -ForegroundColor Yellow
            node debug-server.js
        }
    }
}

Write-Host ""
Read-Host "按 Enter 鍵結束" 