const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

console.log('🔍 開始調試伺服器...');

// 創建日誌目錄
const logDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir);
    console.log('✅ 創建日誌目錄:', logDir);
}

// 簡單的日誌函數
function logError(error, context = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = `\n[${timestamp}] 🚨 錯誤調試\n` +
        `類型: ${error.constructor.name}\n` +
        `訊息: ${error.message}\n` +
        `堆疊: ${error.stack}\n` +
        `上下文: ${JSON.stringify(context, null, 2)}\n` +
        '-'.repeat(80) + '\n';
    
    const errorLogPath = path.join(logDir, 'debug-error.log');
    fs.appendFileSync(errorLogPath, logEntry, 'utf8');
    console.error('❌ 錯誤已記錄到:', errorLogPath);
    console.error('錯誤詳情:', error.message);
}

function logSystem(event, details = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = `\n[${timestamp}] 🔧 系統調試\n` +
        `事件: ${event}\n` +
        `詳情: ${JSON.stringify(details, null, 2)}\n` +
        '-'.repeat(80) + '\n';
    
    const systemLogPath = path.join(logDir, 'debug-system.log');
    fs.appendFileSync(systemLogPath, logEntry, 'utf8');
    console.log('📝 系統事件已記錄:', event);
}

const app = express();
const PORT = 3001;

// 記錄啟動嘗試
logSystem('調試伺服器啟動嘗試', {
    nodeVersion: process.version,
    platform: process.platform,
    cwd: process.cwd()
});

try {
    app.use(cors());
    app.use(express.json());
    
    // 簡單的中間件
    app.use((req, res, next) => {
        console.log(`📥 ${new Date().toISOString()} ${req.method} ${req.url}`);
        next();
    });
    
    // 健康檢查
    app.get('/health', (req, res) => {
        logSystem('健康檢查請求');
        res.json({
            status: 'ok',
            timestamp: new Date().toISOString(),
            service: 'Debug Server',
            logs_directory: logDir
        });
    });
    
    // 錯誤測試端點
    app.get('/test-error', (req, res) => {
        try {
            throw new Error('這是一個測試錯誤');
        } catch (error) {
            logError(error, { endpoint: '/test-error' });
            res.status(500).json({
                error: '測試錯誤',
                message: error.message,
                logged: true
            });
        }
    });
    
    // 日誌查看端點
    app.get('/debug-logs', (req, res) => {
        try {
            const errorLogPath = path.join(logDir, 'debug-error.log');
            const systemLogPath = path.join(logDir, 'debug-system.log');
            
            let errorLog = '沒有錯誤日誌';
            let systemLog = '沒有系統日誌';
            
            if (fs.existsSync(errorLogPath)) {
                errorLog = fs.readFileSync(errorLogPath, 'utf8');
            }
            
            if (fs.existsSync(systemLogPath)) {
                systemLog = fs.readFileSync(systemLogPath, 'utf8');
            }
            
            res.json({
                success: true,
                logs: {
                    errors: errorLog,
                    system: systemLog
                },
                logDirectory: logDir
            });
        } catch (error) {
            logError(error, { endpoint: '/debug-logs' });
            res.status(500).json({
                error: '無法讀取日誌',
                message: error.message
            });
        }
    });
    
    // 啟動伺服器
    const server = app.listen(PORT, () => {
        console.log('\n🎯 === 調試伺服器啟動成功 ===');
        console.log(`🚀 URL: http://localhost:${PORT}`);
        console.log(`📊 健康檢查: http://localhost:${PORT}/health`);
        console.log(`🧪 錯誤測試: http://localhost:${PORT}/test-error`);
        console.log(`📋 日誌查看: http://localhost:${PORT}/debug-logs`);
        console.log('=======================================\n');
        
        logSystem('調試伺服器啟動成功', {
            port: PORT,
            pid: process.pid
        });
    });
    
    server.on('error', (err) => {
        logError(err, { phase: 'server_startup' });
        if (err.code === 'EADDRINUSE') {
            console.error(`❌ 端口 ${PORT} 已被使用`);
        } else {
            console.error('❌ 伺服器錯誤:', err.message);
        }
    });
    
} catch (error) {
    logError(error, { phase: 'initialization' });
    console.error('❌ 伺服器初始化失敗:', error.message);
    process.exit(1);
}

// 全局錯誤處理
process.on('uncaughtException', (err) => {
    logError(err, { type: 'uncaughtException' });
    console.error('🚨 未捕獲的異常:', err.message);
});

process.on('unhandledRejection', (reason, promise) => {
    const error = new Error(reason?.message || 'Unknown Promise Rejection');
    logError(error, { type: 'unhandledRejection', promise: promise.toString() });
    console.error('🚨 未處理的Promise拒絕:', reason);
}); 