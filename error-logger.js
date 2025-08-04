const fs = require('fs');
const path = require('path');
const util = require('util');

class ErrorLogger {
    constructor() {
        this.logDir = path.join(__dirname, 'logs');
        this.errorLogPath = path.join(this.logDir, 'error.log');
        this.apiLogPath = path.join(this.logDir, 'api.log');
        this.systemLogPath = path.join(this.logDir, 'system.log');
        this.initLogDir();
    }

    initLogDir() {
        if (!fs.existsSync(this.logDir)) {
            fs.mkdirSync(this.logDir);
        }
    }

    getCurrentTimestamp() {
        return new Date().toISOString();
    }

    formatError(error, context = {}) {
        return {
            timestamp: this.getCurrentTimestamp(),
            type: error.constructor.name,
            message: error.message,
            stack: error.stack,
            code: error.code,
            context: context,
            response: error.response ? {
                status: error.response.status,
                data: error.response.data
            } : null
        };
    }

    async logError(error, context = {}) {
        const errorData = this.formatError(error, context);
        const logEntry = `\n[${errorData.timestamp}] 🚨 錯誤\n` +
            `類型: ${errorData.type}\n` +
            `訊息: ${errorData.message}\n` +
            `上下文: ${JSON.stringify(context, null, 2)}\n` +
            `堆疊: ${errorData.stack}\n` +
            '-'.repeat(80) + '\n';

        await fs.promises.appendFile(this.errorLogPath, logEntry, 'utf8');
        console.error('❌ 錯誤已記錄到:', this.errorLogPath);
        return errorData;
    }

    async logAPIRequest(req, context = {}) {
        const logEntry = `\n[${this.getCurrentTimestamp()}] 📡 API請求\n` +
            `方法: ${req.method}\n` +
            `路徑: ${req.url}\n` +
            `內容: ${JSON.stringify(req.body, null, 2)}\n` +
            `上下文: ${JSON.stringify(context, null, 2)}\n` +
            '-'.repeat(80) + '\n';

        await fs.promises.appendFile(this.apiLogPath, logEntry, 'utf8');
    }

    async logSystemEvent(event, details = {}) {
        const logEntry = `\n[${this.getCurrentTimestamp()}] 🔧 系統事件\n` +
            `事件: ${event}\n` +
            `詳情: ${JSON.stringify(details, null, 2)}\n` +
            '-'.repeat(80) + '\n';

        await fs.promises.appendFile(this.systemLogPath, logEntry, 'utf8');
    }

    async getErrorStats() {
        try {
            const errorLog = await fs.promises.readFile(this.errorLogPath, 'utf8');
            const errors = errorLog.split('\n[').length - 1;
            return {
                totalErrors: errors,
                lastError: errorLog.split('\n[').pop()
            };
        } catch (error) {
            return { totalErrors: 0, lastError: null };
        }
    }

    async clearLogs() {
        const timestamp = this.getCurrentTimestamp().replace(/[:.]/g, '-');
        const backupDir = path.join(this.logDir, 'backup');
        
        if (!fs.existsSync(backupDir)) {
            fs.mkdirSync(backupDir);
        }

        // 備份現有日誌
        const files = [
            { path: this.errorLogPath, name: 'error.log' },
            { path: this.apiLogPath, name: 'api.log' },
            { path: this.systemLogPath, name: 'system.log' }
        ];

        for (const file of files) {
            if (fs.existsSync(file.path)) {
                const backupPath = path.join(backupDir, `${timestamp}_${file.name}`);
                await fs.promises.rename(file.path, backupPath);
            }
        }

        console.log('✅ 日誌已清理並備份到:', backupDir);
    }
}

module.exports = new ErrorLogger(); 