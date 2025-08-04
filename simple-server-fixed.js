const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3001;

// 創建日誌目錄
const logDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir);
}

// 錯誤日誌
function logError(error, context = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] ERROR: ${error.message}\nContext: ${JSON.stringify(context)}\nStack: ${error.stack}\n\n`;
    fs.appendFileSync(path.join(logDir, 'error.log'), logEntry);
}

// 系統日誌
function logSystem(event, details = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] ${event}\nDetails: ${JSON.stringify(details)}\n\n`;
    fs.appendFileSync(path.join(logDir, 'system.log'), logEntry);
}

// API日誌
function logAPI(req, context = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] ${req.method} ${req.path}\nBody: ${JSON.stringify(req.body)}\nContext: ${JSON.stringify(context)}\n\n`;
    fs.appendFileSync(path.join(logDir, 'api.log'), logEntry);
}

app.use(cors());
app.use(express.json());

// 請求日誌中間件
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
    next();
});

// 健康檢查
app.get('/health', (req, res) => {
    logSystem('Health check requested');
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        version: 'fixed-1.0'
    });
});

// 啟動伺服器
function startServer(port) {
    try {
        app.listen(port, () => {
            console.log(`Server is running on port ${port}`);
            logSystem('Server started', { port });
        });
    } catch (error) {
        logError(error, { phase: 'startup' });
        console.error('Server failed to start:', error);
    }
}

startServer(port);