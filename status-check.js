const http = require('http');

function checkPort(port) {
  return new Promise((resolve) => {
    const req = http.get(`http://localhost:${port}/health`, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        console.log(`✅ 端口 ${port} 正在運行`);
        console.log('回應:', data);
        resolve(true);
      });
    }).on('error', () => {
      console.log(`❌ 端口 ${port} 無法連接`);
      resolve(false);
    });
    
    req.setTimeout(3000, () => {
      req.destroy();
      console.log(`⏰ 端口 ${port} 連接超時`);
      resolve(false);
    });
  });
}

async function checkStatus() {
  console.log('🔍 檢查伺服器狀態...\n');
  
  await checkPort(3001);
  await checkPort(3002);
  
  console.log('\n💡 如果3002端口無法連接，請等待幾秒後重試');
}

checkStatus(); 