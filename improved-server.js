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
    fs.appendFileSync(path.join(logDir, 'improved-error.log'), logEntry);
}

// 成功日誌
function logSuccess(operation, details = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] SUCCESS: ${operation}\nDetails: ${JSON.stringify(details)}\n\n`;
    fs.appendFileSync(path.join(logDir, 'improved-success.log'), logEntry);
}

// 生成多角度內容
function generateDiverseAngles(topic, contentType, platform, style) {
    const angles = [];
    
    // 根據平台特性生成角度
    const platformAngles = {
        'Facebook': ['社群互動', '生活分享', '話題討論'],
        'Instagram': ['視覺故事', '生活風格', '美學展現'],
        'LinkedIn': ['專業見解', '行業趨勢', '職場經驗'],
        'Twitter': ['即時評論', '簡短精闢', '話題參與']
    };
    
    if (platformAngles[platform]) {
        angles.push(...platformAngles[platform]);
    }
    
    // 根據內容類型添加角度
    if (contentType === 'jab') {
        angles.push('價值分享', '經驗交流', '知識傳遞');
    } else {
        angles.push('問題解決', '需求滿足', '行動呼籲');
    }
    
    return angles;
}

// 獲取平台策略
function getPlatformStrategy(platform) {
    const strategies = {
        'Facebook': {
            maxLength: 500,
            format: '段落式',
            mediaType: '圖片、影片、連結',
            engagement: '互動式問題、投票'
        },
        'Instagram': {
            maxLength: 300,
            format: '視覺為主',
            mediaType: '精美圖片、故事性影片',
            engagement: '標籤、位置標記'
        },
        'LinkedIn': {
            maxLength: 1000,
            format: '專業文章',
            mediaType: '文件、簡報、文章',
            engagement: '專業討論、行業標籤'
        },
        'Twitter': {
            maxLength: 280,
            format: '簡潔有力',
            mediaType: '圖片、GIF',
            engagement: '話題標籤、轉推'
        }
    };
    
    return strategies[platform] || strategies['Facebook'];
}

// 獲取風格語言
function getStyleLanguage(style) {
    const styleGuides = {
        '專業': {
            tone: '正式、權威',
            vocabulary: '專業術語',
            structure: '邏輯清晰'
        },
        '輕鬆': {
            tone: '友善、親切',
            vocabulary: '日常用語',
            structure: '對話式'
        },
        '幽默': {
            tone: '風趣、活潑',
            vocabulary: '俏皮用語',
            structure: '故事性'
        },
        '激勵': {
            tone: '積極、鼓舞',
            vocabulary: '正能量詞彙',
            structure: '引導式'
        }
    };
    
    return styleGuides[style] || styleGuides['專業'];
}

// 生成多樣化提示詞
function generateDiversePrompt(topic, contentType, platform, style, customPrompt = '', variationSeed = '') {
    const angles = generateDiverseAngles(topic, contentType, platform, style);
    const platformStrategy = getPlatformStrategy(platform);
    const styleGuide = getStyleLanguage(style);
    
    let prompt = `
主題：${topic}
內容類型：${contentType}
平台：${platform}
風格：${style}

內容要求：
1. 符合${platform}平台特性：${JSON.stringify(platformStrategy)}
2. 採用${style}風格：${JSON.stringify(styleGuide)}
3. 內容角度參考：${angles.join('、')}
4. 字數限制：${platformStrategy.maxLength}字以內
5. 建議使用：${platformStrategy.mediaType}
6. 互動方式：${platformStrategy.engagement}

${customPrompt ? '自定義要求：' + customPrompt : ''}
${variationSeed ? '變化方向：' + variationSeed : ''}

請生成符合以上要求的內容。`;

    return prompt;
}

// 智能API調用
async function intelligentAPICall(systemPrompt, userPrompt, retries = 3) {
    // 模擬API調用
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve({
                success: true,
                content: "這是一個示例回應，實際實現時請替換為真實的API調用。"
            });
        }, 2000);
    });
}

// 檢查內容相似度
function checkContentSimilarity(newContent, existingContents) {
    // 簡單的相似度檢查示例
    for (const content of existingContents) {
        const similarity = calculateSimilarity(newContent, content);
        if (similarity > 0.8) {
            return true; // 內容過於相似
        }
    }
    return false;
}

// 計算相似度的輔助函數
function calculateSimilarity(text1, text2) {
    // 這裡應該實現實際的相似度計算算法
    // 這只是一個示例實現
    return 0.5;
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
    logSuccess('Health check requested');
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        version: 'improved-1.0'
    });
});

// 生成內容端點
app.post('/api/generate', async (req, res) => {
    try {
        const { topic, contentType, platform, style, customPrompt } = req.body;
        
        // 生成提示詞
        const prompt = generateDiversePrompt(topic, contentType, platform, style, customPrompt);
        
        // 調用API
        const response = await intelligentAPICall(
            "You are a professional content creator",
            prompt
        );
        
        if (response.success) {
            logSuccess('Content generated', { topic, platform });
            res.json({ success: true, content: response.content });
        } else {
            throw new Error('API response failed');
        }
        
    } catch (error) {
        logError(error, { endpoint: '/api/generate' });
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

// 啟動伺服器
function startServer(port) {
    try {
        app.listen(port, () => {
            console.log(`Improved server is running on port ${port}`);
            logSuccess('Server started', { port });
        });
    } catch (error) {
        logError(error, { phase: 'startup' });
        console.error('Server failed to start:', error);
    }
}

startServer(port);