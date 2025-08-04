const axios = require('axios');

async function testAPI() {
    try {
        const response = await axios.get('http://localhost:3001/health');
        console.log('API Test Result:', response.data);
        return true;
    } catch (error) {
        console.error('API Test Failed:', error.message);
        return false;
    }
}

testAPI();