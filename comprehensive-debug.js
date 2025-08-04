#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('🔍 === 全面系統調試工具 ===\n');

// 日誌函數
function log(message, level = 'INFO') {
    const timestamp = new Date().toISOString();
    const prefix = {
        'INFO': '✅',
        'WARN': '⚠️ ',
        'ERROR': '❌',
        'DEBUG': '🔍'
    }[level] || '📝';
    
    console.log(`${prefix} [${timestamp}] ${message}`);
}

function debugLog(title, data) {
    console.log(`\n📊 ${title}:`);
    console.log(JSON.stringify(data, null, 2));
}

async function runDiagnostics() {
    const results = {
        system: {},
        nodejs: {},
        dependencies: {},
        files: {},
        network: {},
        errors: []
    };

    try {
        // 1. 系統資訊
        log('檢查系統資訊...', 'DEBUG');
        results.system = {
            platform: process.platform,
            arch: process.arch,
            nodeVersion: process.version,
            cwd: process.cwd(),
            pid: process.pid,
            uptime: process.uptime()
        };

        // 2. Node.js 依賴檢查
        log('檢查 Node.js 依賴...', 'DEBUG');
        const packagePath = path.join(__dirname, 'package.json');
        if (fs.existsSync(packagePath)) {
            const pkg = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
            results.dependencies.package = pkg;
            
            // 檢查 node_modules
            const nodeModulesPath = path.join(__dirname, 'node_modules');
            results.dependencies.nodeModulesExists = fs.existsSync(nodeModulesPath);
            
            if (results.dependencies.nodeModulesExists) {
                const modules = fs.readdirSync(nodeModulesPath);
                results.dependencies.installedModules = modules.filter(m => !m.startsWith('.'));
            }
        } else {
            results.errors.push('package.json 不存在');
        }

        // 3. 重要文件檢查
        log('檢查重要文件...', 'DEBUG');
        const importantFiles = [
            'simple-server.js',
            'error-logger.js',
            'Jab.html',
            'debug-server.js'
        ];
        
        results.files = {};
        importantFiles.forEach(file => {
            const filePath = path.join(__dirname, file);
            results.files[file] = {
                exists: fs.existsSync(filePath),
                size: fs.existsSync(filePath) ? fs.statSync(filePath).size : 0
            };
        });

        // 4. 網路端口檢查
        log('檢查網路端口...', 'DEBUG');
        try {
            const netstat = execSync('netstat -ano | findstr :3001', { encoding: 'utf8' });
            results.network.port3001 = netstat.trim();
        } catch (e) {
            results.network.port3001 = '端口 3001 未被使用';
        }

        // 5. 嘗試載入模組
        log('測試模組載入...', 'DEBUG');
        const moduleTests = {
            express: false,
            cors: false,
            axios: false,
            fs: false,
            path: false
        };

        Object.keys(moduleTests).forEach(moduleName => {
            try {
                require(moduleName);
                moduleTests[moduleName] = true;
                log(`模組 ${moduleName} 載入成功`, 'INFO');
            } catch (error) {
                moduleTests[moduleName] = false;
                results.errors.push(`模組 ${moduleName} 載入失敗: ${error.message}`);
                log(`模組 ${moduleName} 載入失敗: ${error.message}`, 'ERROR');
            }
        });
        results.dependencies.moduleTests = moduleTests;

        // 6. 嘗試載入自定義模組
        log('測試自定義模組載入...', 'DEBUG');
        try {
            const errorLoggerPath = path.join(__dirname, 'error-logger.js');
            if (fs.existsSync(errorLoggerPath)) {
                require('./error-logger');
                log('error-logger.js 載入成功', 'INFO');
            } else {
                results.errors.push('error-logger.js 文件不存在');
            }
        } catch (error) {
            results.errors.push(`error-logger.js 載入失敗: ${error.message}`);
            log(`error-logger.js 載入失敗: ${error.message}`, 'ERROR');
        }

        // 7. 創建測試日誌目錄
        log('測試日誌目錄創建...', 'DEBUG');
        const logDir = path.join(__dirname, 'logs');
        try {
            if (!fs.existsSync(logDir)) {
                fs.mkdirSync(logDir);
                log('日誌目錄創建成功', 'INFO');
            } else {
                log('日誌目錄已存在', 'INFO');
            }
            results.files.logsDirectory = {
                exists: true,
                path: logDir,
                permissions: 'readable/writable'
            };
        } catch (error) {
            results.errors.push(`日誌目錄創建失敗: ${error.message}`);
            log(`日誌目錄創建失敗: ${error.message}`, 'ERROR');
        }

    } catch (error) {
        results.errors.push(`診斷過程錯誤: ${error.message}`);
        log(`診斷過程錯誤: ${error.message}`, 'ERROR');
    }

    return results;
}

async function writeDebugReport(results) {
    const reportPath = path.join(__dirname, 'logs', 'debug-report.json');
    const reportTextPath = path.join(__dirname, 'logs', 'debug-report.txt');
    
    try {
        // JSON 格式報告
        fs.writeFileSync(reportPath, JSON.stringify(results, null, 2), 'utf8');
        
        // 文字格式報告
        let textReport = '🔍 全面調試報告\n';
        textReport += `生成時間: ${new Date().toISOString()}\n`;
        textReport += '='.repeat(50) + '\n\n';
        
        textReport += '📊 系統資訊:\n';
        Object.entries(results.system).forEach(([key, value]) => {
            textReport += `  ${key}: ${value}\n`;
        });
        
        textReport += '\n📦 依賴狀態:\n';
        if (results.dependencies.moduleTests) {
            Object.entries(results.dependencies.moduleTests).forEach(([module, status]) => {
                textReport += `  ${module}: ${status ? '✅ 成功' : '❌ 失敗'}\n`;
            });
        }
        
        textReport += '\n📁 文件檢查:\n';
        Object.entries(results.files).forEach(([file, info]) => {
            if (typeof info === 'object' && info.exists !== undefined) {
                textReport += `  ${file}: ${info.exists ? '✅ 存在' : '❌ 不存在'} (${info.size} bytes)\n`;
            }
        });
        
        if (results.errors.length > 0) {
            textReport += '\n🚨 發現的錯誤:\n';
            results.errors.forEach((error, index) => {
                textReport += `  ${index + 1}. ${error}\n`;
            });
        } else {
            textReport += '\n✅ 沒有發現錯誤\n';
        }
        
        fs.writeFileSync(reportTextPath, textReport, 'utf8');
        
        log(`調試報告已保存到: ${reportPath}`, 'INFO');
        log(`調試報告已保存到: ${reportTextPath}`, 'INFO');
        
    } catch (error) {
        log(`保存調試報告失敗: ${error.message}`, 'ERROR');
    }
}

// 主執行函數
async function main() {
    try {
        const results = await runDiagnostics();
        
        console.log('\n📊 調試結果摘要:');
        debugLog('系統資訊', results.system);
        debugLog('依賴測試', results.dependencies.moduleTests);
        debugLog('文件檢查', results.files);
        
        if (results.errors.length > 0) {
            console.log('\n🚨 發現的問題:');
            results.errors.forEach((error, index) => {
                log(`${index + 1}. ${error}`, 'ERROR');
            });
        } else {
            log('沒有發現明顯問題', 'INFO');
        }
        
        await writeDebugReport(results);
        
        console.log('\n🎯 建議解決方案:');
        if (results.errors.some(e => e.includes('模組') && e.includes('載入失敗'))) {
            log('執行 npm install 安裝缺失的依賴', 'WARN');
        }
        
        if (!results.files['simple-server.js']?.exists) {
            log('simple-server.js 文件有問題，請檢查文件完整性', 'WARN');
        }
        
        if (results.network.port3001 && !results.network.port3001.includes('未被使用')) {
            log('端口 3001 被佔用，請關閉其他使用該端口的程序', 'WARN');
        }
        
    } catch (error) {
        log(`主程序執行失敗: ${error.message}`, 'ERROR');
        console.error(error.stack);
    }
}

main(); 