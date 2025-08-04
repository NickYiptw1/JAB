const axios = require('axios');

console.log('🔍 AI內容生產器快速診斷工具');
console.log('==================================');

// 測試 1: 檢查依賴包
console.log('📦 檢查依賴包...');
try {
  const express = require('express');
  const cors = require('cors');
  console.log('✅ Express 和 CORS 已安裝');
} catch (error) {
  console.log('❌ 依賴包缺失:', error.message);
  process.exit(1);
}

// 測試 2: 檢查 API 金鑰
const API_KEY = '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';
console.log('🔑 API 金鑰長度:', API_KEY.length);
console.log('🔑 API 金鑰前綴:', API_KEY.substring(0, 20) + '...');

// 測試 3: 測試 OpenRouter API
async function testAPI() {
  console.log('\n🧪 測試 OpenRouter API 連接...');
  try {
    const response = await axios.post('https://openrouter.ai/api/v1/chat/completions', {
      model: 'tngtech/deepseek-r1t2-chimera:free',
      messages: [
        { role: 'user', content: '請簡單回應「API連接成功」' }
      ],
      max_tokens: 10
    }, {
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'http://localhost:3001',
        'X-Title': 'Quick Test'
      },
      timeout: 15000
    });

    const reply = response.data?.choices?.[0]?.message?.content || '無回應';
    console.log('✅ API 連接成功!');
    console.log('📝 AI 回應:', reply);
    
    console.log('\n🎯 診斷結果: API 正常運作');
    console.log('💡 建議: 執行 start-server.bat 或 start-server.ps1 啟動伺服器');
    
  } catch (error) {
    console.log('❌ API 連接失敗:');
    console.log('- 錯誤類型:', error.constructor.name);
    console.log('- 錯誤訊息:', error.message);
    
    if (error.response) {
      console.log('- HTTP 狀態:', error.response.status);
      console.log('- 響應數據:', JSON.stringify(error.response.data, null, 2));
    }
    
    if (error.code === 'ENOTFOUND') {
      console.log('\n💡 建議: 檢查網路連接');
    } else if (error.response?.status === 401) {
      console.log('\n💡 建議: API 金鑰可能無效或過期');
    } else if (error.response?.status === 429) {
      console.log('\n💡 建議: API 額度用盡，請稍後再試');
    }
  }
}

// 測試 4: 檢查端口
console.log('\n🌐 檢查端口 3001...');
const net = require('net');
const server = net.createServer();

server.listen(3001, () => {
  console.log('✅ 端口 3001 可用');
  server.close(() => {
    // 開始 API 測試
    testAPI();
  });
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.log('⚠️ 端口 3001 已被使用 (伺服器可能已經在運行)');
    // 仍然測試 API
    testAPI();
  } else {
    console.log('❌ 端口錯誤:', err.message);
  }
}); 