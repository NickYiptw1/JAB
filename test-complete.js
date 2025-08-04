const axios = require('axios');
const fs = require('fs');

async function testComplete() {
    try {
        // 測試健康檢查
        const healthCheck = await axios.get('http://localhost:3001/health');
        console.log('Health Check:', healthCheck.data);

        // 測試內容生成
        const generateTest = await axios.post('http://localhost:3001/api/generate', {
            topic: '測試主題',
            contentType: 'jab',
            platform: 'Facebook',
            style: '專業'
        });
        console.log('Generate Test:', generateTest.data);

        return true;
    } catch (error) {
        console.error('Complete Test Failed:', error.message);
        return false;
    }
}

testComplete();