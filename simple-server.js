const express = require('express');
const cors = require('cors');
const axios = require('axios');
const logger = require('./error-logger');

const app = express();
let PORT = 3001; // 起始端口
const API_KEY = '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';

app.use(cors());
app.use(express.json());

// 增強的日誌中間件
app.use(async (req, res, next) => {
  await logger.logAPIRequest(req);
  next();
});

// 錯誤處理中間件
app.use((err, req, res, next) => {
  logger.logError(err, { 
    path: req.path, 
    method: req.method, 
    body: req.body 
  });
  res.status(500).json({
    error: '系統錯誤',
    message: err.message,
    timestamp: new Date().toISOString()
  });
});

// 系統啟動日誌
logger.logSystemEvent('系統啟動', {
  port: PORT,
  apiKeyConfigured: !!API_KEY,
  nodeVersion: process.version
});

console.log('🔑 API Key 設定:', API_KEY ? '✅ 已配置' : '❌ 未配置');
console.log('🔑 API Key 前綴:', API_KEY.substring(0, 20) + '...');

// 健康檢查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    api_key_configured: !!API_KEY,
    service: 'Jab Right Hook Generator (Simple)'
  });
});

// 內容生成 API
app.post('/api/generate-content', async (req, res) => {
  try {
    const { topic, contentType, platform, style, count = 1 } = req.body;
    await logger.logSystemEvent('內容生成請求', { topic, contentType, platform, style, count });
    console.log('📝 內容生成請求:', { topic, contentType, platform, style, count });

    // 輸入驗證
    if (!topic || topic.trim() === '') {
      console.log('❌ 驗證失敗: 主題為空');
      return res.status(400).json({
        error: '主題不能為空',
        details: '請提供有效的主題'
      });
    }

    const jabOrRightHook = contentType === 'jab' ? 'Jab（鋪墊型）' : 'Right Hook（主打型）';
    
    const prompt = `為${platform}平台創建${jabOrRightHook}內容，主題：${topic}，風格：${style}。請用繁體中文回應一個完整可用的社群媒體貼文。`;
    console.log('📋 生成提示:', prompt);

    const response = await axios.post('https://openrouter.ai/api/v1/chat/completions', {
      model: 'tngtech/deepseek-r1t2-chimera:free',
      messages: [
        { role: 'system', content: '你是專業的社群媒體內容創作專家。' },
        { role: 'user', content: prompt }
      ],
      max_tokens: 2000
    }, {
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': `http://localhost:${PORT}`,
        'X-Title': 'Jab Right Hook Generator'
      },
      timeout: 30000 // 30秒超時
    });

    console.log('📊 API 響應狀態:', response.status);
    console.log('📊 API 響應數據結構:', {
      hasData: !!response.data,
      hasChoices: !!response.data?.choices,
      choicesLength: response.data?.choices?.length || 0
    });

    const content = response.data?.choices?.[0]?.message?.content || '無法生成內容';
    console.log('✅ 內容生成成功，長度:', content.length);

    // 生成多個內容（如果需要）
    const contents = [];
    for (let i = 0; i < parseInt(count); i++) {
      if (i === 0) {
        contents.push(content);
      } else {
        // 為多個內容稍微變化提示
        const variedPrompt = `${prompt} (變化版本 ${i + 1})`;
        try {
          const variedResponse = await axios.post('https://openrouter.ai/api/v1/chat/completions', {
            model: 'tngtech/deepseek-r1t2-chimera:free',
            messages: [
              { role: 'system', content: '你是專業的社群媒體內容創作專家。請提供不同的創意角度。' },
              { role: 'user', content: variedPrompt }
            ],
            max_tokens: 2000
          }, {
            headers: {
              'Authorization': `Bearer ${API_KEY}`,
              'Content-Type': 'application/json',
              'HTTP-Referer': `http://localhost:${PORT}`,
              'X-Title': 'Jab Right Hook Generator'
            },
            timeout: 30000
          });
          
          const variedContent = variedResponse.data?.choices?.[0]?.message?.content || `變化內容 ${i + 1}`;
          contents.push(variedContent);
        } catch (variedError) {
          console.log(`⚠️ 生成第 ${i + 1} 個內容失敗，使用基礎內容`);
          contents.push(content + ` (變化版本 ${i + 1})`);
        }
      }
    }

    res.json({
      success: true,
      contents,
      metadata: { topic, contentType, platform, style, count }
    });

  } catch (error) {
    await logger.logError(error, {
      api: 'generate-content',
      request: req.body
    });
    console.error('❌ 內容生成錯誤:');
    console.error('- 錯誤類型:', error.constructor.name);
    console.error('- 錯誤訊息:', error.message);
    
    if (error.response) {
      console.error('- HTTP 狀態:', error.response.status);
      console.error('- 響應數據:', JSON.stringify(error.response.data, null, 2));
    }
    
    if (error.code) {
      console.error('- 錯誤代碼:', error.code);
    }

    res.status(500).json({
      error: 'AI服務暫時無法使用',
      details: error.response?.data?.error?.message || error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// 聊天 API
app.post('/api/chat', async (req, res) => {
  try {
    const { message, contentType, platform, style, history = [] } = req.body;
    await logger.logSystemEvent('聊天請求', { 
      messageLength: message?.length,
      contentType,
      platform,
      historyLength: history.length
    });
    console.log('💬 聊天請求:', { message, contentType, platform, style, historyLength: history.length });

    // 輸入驗證
    if (!message || message.trim() === '') {
      console.log('❌ 聊天驗證失敗: 訊息為空');
      return res.status(400).json({
        error: '訊息不能為空',
        details: '請提供有效的訊息'
      });
    }

    // 建構對話上下文
    const messages = [
      { role: 'system', content: '你是精通《Jab, Jab, Jab, Right Hook》策略的AI助手。你專門幫助用戶創建有效的社群媒體內容策略。' }
    ];

    // 添加歷史對話（最多保留最近5條）
    const recentHistory = history.slice(-5);
    recentHistory.forEach(item => {
      if (item.user) messages.push({ role: 'user', content: item.user });
      if (item.ai) messages.push({ role: 'assistant', content: item.ai });
    });

    // 添加當前訊息
    messages.push({ role: 'user', content: message });

    console.log('📋 對話上下文長度:', messages.length);

    const response = await axios.post('https://openrouter.ai/api/v1/chat/completions', {
      model: 'tngtech/deepseek-r1t2-chimera:free',
      messages,
      max_tokens: 1500,
      temperature: 0.7
    }, {
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': `http://localhost:${PORT}`,
        'X-Title': 'Jab Right Hook Generator'
      },
      timeout: 30000
    });

    console.log('📊 聊天 API 響應狀態:', response.status);
    
    const reply = response.data?.choices?.[0]?.message?.content || '無法回應';
    console.log('✅ 聊天回應成功，長度:', reply.length);

    res.json({ 
      success: true, 
      reply,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    await logger.logError(error, {
      api: 'chat',
      request: {
        messageLength: req.body.message?.length,
        historyLength: req.body.history?.length
      }
    });
    console.error('❌ 聊天錯誤:');
    console.error('- 錯誤類型:', error.constructor.name);
    console.error('- 錯誤訊息:', error.message);
    
    if (error.response) {
      console.error('- HTTP 狀態:', error.response.status);
      console.error('- 響應數據:', JSON.stringify(error.response.data, null, 2));
    }

    res.status(500).json({
      error: 'AI聊天服務暫時無法使用',
      details: error.response?.data?.error?.message || error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// API 測試端點
app.get('/api/test-api', async (req, res) => {
  try {
    await logger.logSystemEvent('API測試開始');
    console.log('🧪 測試 OpenRouter API 連接...');
    
    const response = await axios.post('https://openrouter.ai/api/v1/chat/completions', {
      model: 'tngtech/deepseek-r1t2-chimera:free',
      messages: [
        { role: 'user', content: '測試連接，請回覆OK' }
      ],
      max_tokens: 10
    }, {
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': `http://localhost:${PORT}`,
        'X-Title': 'API Test'
      },
      timeout: 10000
    });

    console.log('✅ API 測試成功');
    await logger.logSystemEvent('API測試完成', { success: true });
    res.json({
      success: true,
      message: 'API 連接正常',
      response: response.data?.choices?.[0]?.message?.content || 'OK',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    await logger.logError(error, { api: 'test-api' });
    console.error('❌ API 測試失敗:', error.message);
    res.status(500).json({
      success: false,
      error: 'API 連接失敗',
      details: error.response?.data || error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// 日誌查看端點
app.get('/api/logs', async (req, res) => {
  try {
    const stats = await logger.getErrorStats();
    res.json({
      success: true,
      stats,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: '無法讀取日誌',
      details: error.message
    });
  }
});

// 清理日誌端點
app.post('/api/logs/clear', async (req, res) => {
  try {
    await logger.clearLogs();
    res.json({
      success: true,
      message: '日誌已清理並備份',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: '清理日誌失敗',
      details: error.message
    });
  }
});

// 智能端口啟動函數
function startServer(port) {
  const server = app.listen(port, () => {
    console.log('\n🎯 === Jab Right Hook Generator 伺服器 ===');
    console.log(`🚀 伺服器成功運行在: http://localhost:${port}`);
    console.log(`📊 健康檢查: http://localhost:${port}/health`);
    console.log(`🧪 API 測試: http://localhost:${port}/api/test-api`);
    console.log('📖 請打開 Jab.html 開始使用');
    console.log('🔍 詳細日誌已啟用，所有請求都會被記錄');
    console.log('==========================================\n');
    
    // 更新前端頁面的端口信息
    PORT = port;
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.log(`⚠️ 端口 ${port} 已被使用，嘗試下一個端口...`);
      if (port < 3010) {
        startServer(port + 1);
      } else {
        console.error('❌ 無法找到可用端口 (3001-3010)');
        console.error('💡 請手動關閉佔用端口的程式或重新啟動電腦');
        process.exit(1);
      }
    } else {
      console.error('❌ 伺服器啟動錯誤:', err.message);
      process.exit(1);
    }
  });
}

// 啟動伺服器
console.log('🔍 正在尋找可用端口...');
startServer(PORT);

// 全局錯誤處理
process.on('uncaughtException', async (err) => {
  await logger.logError(err, { type: 'uncaughtException' });
  console.error('\n🚨 未捕獲的異常:');
  console.error('- 錯誤:', err.message);
  console.error('- 堆疊:', err.stack);
  console.error('- 時間:', new Date().toISOString());
});

process.on('unhandledRejection', async (reason, promise) => {
  await logger.logError(new Error(reason?.message || 'Unknown Promise Rejection'), {
    type: 'unhandledRejection',
    promise: promise
  });
  console.error('\n🚨 未處理的Promise拒絕:');
  console.error('- 原因:', reason);
  console.error('- Promise:', promise);
  console.error('- 時間:', new Date().toISOString());
});