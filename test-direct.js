const axios = require('axios');
const fs = require('fs');
const path = require('path');

async function testAPI() {
    const logDir = path.join(__dirname, 'logs');
    if (!fs.existsSync(logDir)) {
        fs.mkdirSync(logDir);
    }

    try {
        const response = await axios.get('http://localhost:3001/health');
        const logEntry = `[${new Date().toISOString()}] Test Success: ${JSON.stringify(response.data)}\n`;
        fs.appendFileSync(path.join(logDir, 'test.log'), logEntry);
        console.log('Direct Test Success:', response.data);
        return true;
    } catch (error) {
        const logEntry = `[${new Date().toISOString()}] Test Failed: ${error.message}\n`;
        fs.appendFileSync(path.join(logDir, 'test.log'), logEntry);
        console.error('Direct Test Failed:', error.message);
        return false;
    }
}

testAPI();