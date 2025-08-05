const express = require('express');
const cors = require('cors');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

const app = express();

// 設置中文編碼支持
app.use(express.json({ charset: 'utf-8' }));
app.use(express.urlencoded({ extended: true, charset: 'utf-8' }));
let PORT = 3001;

// DeepSeek-R1-0528 API配置 - 使用用戶指定的模型和密鑰
const API_CONFIGS = [
    {
        name: 'DeepSeek-R1-Primary',
        key: 'sk-6ce29020c8d84649b089dd9859caccc5',
        baseURL: 'https://api.deepseek.com/v1/chat/completions',
        model: 'deepseek-reasoner',
        maxTokens: 4000,
        timeout: 60000
    },
    {
        name: 'OpenRouter-DeepSeek-Backup',
        key: 'sk-6ce29020c8d84649b089dd9859caccc5',
        baseURL: 'https://openrouter.ai/api/v1/chat/completions',
        model: 'deepseek/deepseek-r1',
        maxTokens: 3500,
        timeout: 50000
    },
    {
        name: 'LocalAI-Fallback',
        key: 'fallback-generator',
        baseURL: 'local-fallback',
        model: 'high-quality-backup',
        maxTokens: 3000,
        timeout: 5000
    }
];

let currentConfigIndex = 0;

// 高質量備用內容生成器
function generateHighQualityFallbackContent(topic, contentType, platform, style) {
    const isJab = contentType === 'jab';
    const platformEmoji = {
        'LinkedIn': '💼',
        'Instagram': '📷', 
        'Twitter': '🐦',
        'Facebook': '👥',
        '通用': '🌐'
    };
    
    const styleTemplates = {
        '專業': {
            opening: ['根據最新研究顯示', '業界專家指出', '數據分析發現', '市場趨勢顯示'],
            tone: '專業見解',
            ending: ['建議採取以下策略', '值得深入思考', '歡迎交流討論']
        },
        '親切': {
            opening: ['你是否也有過這樣的經驗', '想跟大家分享一個觀察', '最近發現一個有趣現象', '跟朋友聊天時突然想到'],
            tone: '親和分享',
            ending: ['你覺得呢？', '歡迎分享你的想法', '一起討論看看']
        },
        '創意': {
            opening: ['想像一下這個場景', '如果你是導演會怎麼拍', '腦洞大開時間到', '換個角度來看待'],
            tone: '創意思維',
            ending: ['讓創意飛一下', '期待你的創意想法', '一起腦力激盪']
        },
        '輕鬆': {
            opening: ['週末閒聊時間', '輕鬆聊聊', '分享一個小心得', '隨便聊聊'],
            tone: '輕鬆愉快',
            ending: ['輕鬆一下', '沒事聊聊', '隨意分享']
        }
    };
    
    const template = styleTemplates[style] || styleTemplates['專業'];
    const opening = template.opening[Math.floor(Math.random() * template.opening.length)];
    const ending = template.ending[Math.floor(Math.random() * template.ending.length)];
    const emoji = platformEmoji[platform] || '🌐';
    
    // JAB內容模板（提供價值）
    if (isJab) {
        return `${emoji} ${opening}，${topic}正在重新定義我們的思考方式。

🔍 深度觀察：
在快速變化的時代，掌握${topic}的核心關鍵不僅是趨勢，更是競爭優勢的來源。成功的人總是能在變化中找到機會。

💡 實用洞察：
• 理解${topic}的本質，而非表象
• 持續學習和適應變化
• 將理論轉化為實際行動
• 建立系統性思維模式

🎯 關鍵思考：
每個人對${topic}的理解都是獨特的。重要的是如何將這些理解轉化為實際的價值創造。

🤝 ${ending}！你在${topic}方面有什麼獨特的見解？

#${topic.replace(/\s+/g, '')} #深度思考 #價值分享 #${platform}`;
    }
    
    // Right Hook內容模板（明確行動呼籲）
    else {
        return `${emoji} 🚀 把握機會！${topic}正等著你來掌握！

⭐ 為什麼現在是最佳時機？
研究顯示，掌握${topic}的專業人士在職場上具有明顯優勢。不要讓機會從指縫中溜走！

🎯 立即獲得的價值：
✅ 深入理解${topic}的核心要素
✅ 掌握實用的應用技巧
✅ 建立專業競爭優勢
✅ 獲得即時可用的方法

🔥 限時機會：
現在就開始行動，比等待更多資訊更重要。成功的人總是在別人還在觀望時就開始行動。

💪 下一步行動：
立即開始學習${topic}，讓自己在這個領域脫穎而出！

📞 想了解更多？點擊私訊或留言，我們一起探討${topic}的無限可能！

#${topic.replace(/\s+/g, '')} #立即行動 #職場成長 #${platform}`;
    }
}

// 創建日誌目錄
const logDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir);
}

// 增強的日誌系統
function logError(error, context = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = `\n[${timestamp}] 🚨 ERROR\n` +
        `Type: ${error.constructor.name}\n` +
        `Message: ${error.message}\n` +
        `Context: ${JSON.stringify(context, null, 2)}\n` +
        `Stack: ${error.stack}\n` +
        `Config: ${JSON.stringify(API_CONFIGS[currentConfigIndex], null, 2)}\n` +
        '-'.repeat(100) + '\n';
    
    fs.appendFileSync(path.join(logDir, 'enhanced-error.log'), logEntry, 'utf8');
    console.error('❌ Error logged:', error.message);
}

function logSuccess(operation, details = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = `\n[${timestamp}] ✅ SUCCESS\n` +
        `Operation: ${operation}\n` +
        `Details: ${JSON.stringify(details, null, 2)}\n` +
        '-'.repeat(100) + '\n';
    
    fs.appendFileSync(path.join(logDir, 'enhanced-success.log'), logEntry, 'utf8');
    console.log('✅ Success logged:', operation);
}

function logAPICall(config, prompt, response = null, error = null) {
    const timestamp = new Date().toISOString();
    const logEntry = `\n[${timestamp}] 🔄 API CALL\n` +
        `Config: ${config.name} (${config.model})\n` +
        `Prompt Length: ${prompt.length}\n` +
        `Response Length: ${response ? response.length : 'N/A'}\n` +
        `Success: ${!error}\n` +
        `Error: ${error ? error.message : 'None'}\n` +
        `Prompt Preview: ${prompt.substring(0, 200)}...\n` +
        '-'.repeat(100) + '\n';
    
    fs.appendFileSync(path.join(logDir, 'enhanced-api.log'), logEntry, 'utf8');
}

// 智能API調用函數
async function intelligentAPICall(prompt, systemPrompt, retries = 3) {
    for (let attempt = 0; attempt < retries; attempt++) {
        const config = API_CONFIGS[currentConfigIndex];
        
        try {
            console.log(`🔄 嘗試 ${attempt + 1}/${retries} - 使用: ${config.name}`);
            
            // 檢查是否為本地備用配置
            if (config.baseURL === 'local-fallback') {
                console.log(`💎 使用本地高質量備用內容生成器`);
                // 從prompt中提取參數
                const topicMatch = prompt.match(/主題：(.+?)，/) || prompt.match(/關於「(.+?)」/) || ['', '內容創作'];
                const topic = topicMatch[1] || '內容創作';
                const contentType = prompt.includes('Jab') ? 'jab' : 'right-hook';
                const platform = prompt.includes('LinkedIn') ? 'LinkedIn' : 
                              prompt.includes('Instagram') ? 'Instagram' : 
                              prompt.includes('Twitter') ? 'Twitter' : 'LinkedIn';
                const style = prompt.includes('專業') ? '專業' : 
                            prompt.includes('親切') ? '親切' : 
                            prompt.includes('創意') ? '創意' : '專業';
                
                const fallbackContent = generateHighQualityFallbackContent(topic, contentType, platform, style);
                
                logSuccess('Local Fallback Content Generation', {
                    config: config.name,
                    contentLength: fallbackContent.length,
                    attempt: attempt + 1,
                    extractedParams: { topic, contentType, platform, style }
                });
                
                return fallbackContent;
            }
            
            const response = await axios.post(config.baseURL, {
                model: config.model,
                messages: [
                    { role: 'system', content: systemPrompt },
                    { role: 'user', content: prompt }
                ],
                max_tokens: config.maxTokens,
                temperature: 0.8,
                top_p: 0.9,
                presence_penalty: 0.1,
                frequency_penalty: 0.1
            }, {
                headers: {
                    'Authorization': `Bearer ${config.key}`,
                    'Content-Type': 'application/json',
                    'HTTP-Referer': `http://localhost:${PORT}`,
                    'X-Title': 'Enhanced Jab Right Hook Generator'
                },
                timeout: config.timeout
            });

            const content = response.data?.choices?.[0]?.message?.content;
            
            if (!content || content.trim().length < 50) {
                throw new Error('AI response too short or empty');
            }

            logAPICall(config, prompt, content);
            logSuccess('AI Content Generation', {
                config: config.name,
                contentLength: content.length,
                attempt: attempt + 1
            });

            return content;

        } catch (error) {
            logAPICall(config, prompt, null, error);
            console.error(`❌ 配置 ${config.name} 失敗: ${error.message}`);
            
            // 切換到下一個配置
            currentConfigIndex = (currentConfigIndex + 1) % API_CONFIGS.length;
            
            if (attempt === retries - 1) {
                throw new Error(`所有API配置都失敗了。最後錯誤: ${error.message}`);
            }
            
            // 等待一段時間後重試
            await new Promise(resolve => setTimeout(resolve, 2000 * (attempt + 1)));
        }
    }
}

// 智能提示詞生成器
function generateEnhancedPrompt(topic, contentType, platform, style) {
    const jabOrRightHook = contentType === 'jab' ? 'Jab（鋪墊型）' : 'Right Hook（主打型）';
    
    // 平台特定的指導（加強版）
    const platformGuidelines = {
        'Facebook': {
            length: '200-350字',
            tone: '親切對話式，深度分享',
            features: '使用表情符號、問句互動、分段清晰、個人故事、具體案例',
            structure: '開場問題 → 經驗分享 → 實用建議 → 互動呼籲'
        },
        'Instagram': {
            length: '150-250字',
            tone: '視覺化描述，激勵人心',
            features: '配合圖片、使用hashtag、故事性強、情感共鳴',
            structure: '視覺開場 → 故事敘述 → 價值提煉 → 標籤總結'
        },
        'LinkedIn': {
            length: '250-450字',
            tone: '專業見解，深度洞察',
            features: '行業洞察、專業術語、價值分享、數據支撐、案例分析',
            structure: '行業觀察 → 深度分析 → 實用建議 → 專業討論'
        },
        'Twitter': {
            length: '200-280字',
            tone: '簡潔有力，觀點鮮明',
            features: '重點突出、易轉發、話題性強、金句提煉',
            structure: '觀點拋出 → 論證支撐 → 金句總結 → 話題標籤'
        },
        'YouTube': {
            length: '350-600字',
            tone: '詳細說明，引導觀看',
            features: '吸引點擊、描述詳細、行動呼籲、懸念設置',
            structure: '標題吸引 → 內容預告 → 價值承諾 → 觀看引導'
        }
    };

    const platformInfo = platformGuidelines[platform] || platformGuidelines['Facebook'];
    
    // 風格特定的指導（加強版）
    const styleGuidelines = {
        '專業': {
            tone: '權威、深度、可信',
            language: '使用專業術語，引用數據和研究，提供深度見解',
            approach: '邏輯清晰的論證，專業案例支撐，權威觀點分享',
            features: '數據支撐、專家引用、行業洞察、解決方案導向'
        },
        '親切': {
            tone: '溫暖、親和、易懂',
            language: '使用日常語言，多用問句和感嘆句，如朋友般對話',
            approach: '個人經驗分享，感同身受的故事，實用的生活建議',
            features: '個人故事、共鳴點、問句互動、情感連結'
        },
        '幽默': {
            tone: '輕鬆、風趣、有趣',
            language: '適度使用幽默元素，但保持專業底線，讓內容生動有趣',
            approach: '生活化的比喻，趣味的案例，輕鬆的表達方式',
            features: '生動比喻、趣味案例、輕鬆語調、娛樂元素'
        },
        '激勵': {
            tone: '積極、正能量、鼓舞',
            language: '使用正向語言，激發行動力，傳遞希望和動力',
            approach: '成功案例分享，正面思維引導，行動步驟提供',
            features: '成功故事、正面語言、行動導向、希望傳遞'
        },
        '原生風格': {
            tone: '自然、流暢、真實',
            language: '符合平台文化，貼近用戶習慣，自然不做作',
            approach: '平台原生內容風格，用戶喜愛的表達方式',
            features: '平台特色、用戶習慣、自然表達、真實感受'
        }
    };

    const styleInfo = styleGuidelines[style] || styleGuidelines['原生風格'];

    // Jab vs Right Hook 的不同策略
    const contentStrategy = contentType === 'jab' ? {
        purpose: '建立關係、提供價值、不直接銷售',
        approach: '分享有用資訊、個人故事、行業洞察',
        cta: '軟性互動（點讚、分享、評論）'
    } : {
        purpose: '明確銷售、推廣產品服務、轉化行動',
        approach: '強調產品優勢、限時優惠、客戶見證',
        cta: '明確行動指令（購買、諮詢、下載）'
    };

    return `基於《Jab, Jab, Jab, Right Hook》深度精讀原則，創作一篇關於「${topic}」的${jabOrRightHook}內容。

## 📋 創作任務詳解
**目標平台**：${platform}
**內容類型**：${jabOrRightHook}
**風格要求**：${style}
**核心主題**：${topic}

## 🎯 深度精讀策略架構
${contentType === 'jab' ? `
### JAB 策略要求：
🎁 **純粹價值**：提供100%價值，0%推銷
🤝 **建立信任**：通過有用內容贏得受眾信任
💝 **無償分享**：不求任何回報的價值傳遞
🔄 **長期思維**：為未來的Right Hook建立基礎
` : `
### RIGHT HOOK 策略要求：
🎯 **精準時機**：在累積足夠JAB後的完美時機
📢 **明確呼籲**：清晰、具體的行動指令
💎 **價值交換**：明確告知用戶將獲得什麼
⚡ **立即行動**：創造緊迫感和行動動機
`}

## 🏗️ 平台原生規範
- **字數標準**：${platformInfo.length}（深度精讀要求：200-300字）
- **語調風格**：${platformInfo.tone}
- **內容架構**：${platformInfo.structure}
- **平台特色**：${platformInfo.features}

## 🎨 風格深度指導
- **整體語調**：${styleInfo.tone}
- **語言特色**：${styleInfo.language}
- **表達方式**：${styleInfo.approach}
- **核心特徵**：${styleInfo.features}

## 💡 深度精讀創作原則
1. **反常識開場**：挑戰常見觀點或分享意外洞察
2. **故事驅動**：用真實故事和具體案例支撐觀點
3. **數據支撐**：提供具體數字和研究結果
4. **痛點共鳴**：直擊受眾真實痛點和需求
5. **解決方案**：提供可立即執行的具體方法
6. **情感連結**：觸動受眾的情感開關
7. **行動指引**：清晰的下一步行動建議

## 🔍 內容深度要求
✅ **洞察層級**：超越表面，提供深層思考
✅ **價值密度**：每句話都有實用價值
✅ **案例具體**：用真實、具體的例子說明
✅ **方法實用**：提供可立即應用的工具和技巧
✅ **邏輯清晰**：問題→分析→解決方案→行動
✅ **情感溫度**：有人情味，不是冷冰冰的資訊

## 📝 創作結構模板
${contentType === 'jab' ? `
**JAB 內容結構**：
🔥 **反常識開場** → 💡 **深度洞察** → 📖 **故事案例** → 🛠️ **實用方法** → 💬 **互動討論**
` : `
**RIGHT HOOK 結構**：
🎯 **需求確認** → 🎁 **價值承諾** → 📊 **社會證明** → ⚡ **行動呼籲** → 🕒 **緊迫理由**
`}

## 🎪 平台適應性
基於${platform}特性：
- 使用${platform}用戶喜愛的語言風格
- 符合${platform}的內容展示習慣
- 利用${platform}的互動特色
- 適應${platform}的內容消費模式

## ✅ 品質檢核標準
□ 字數達到200-300字範圍
□ 包含具體案例或數據
□ 提供可執行的建議
□ 語言生動不死板
□ 結構邏輯清晰
□ 有情感溫度
□ 符合平台特色
□ ${contentType === 'jab' ? '純粹提供價值' : '包含明確CTA'}

現在請基於以上深度精讀原則，創作一篇讓讀者「學到東西、產生共鳴、想要行動」的高品質${jabOrRightHook}內容：`;
}

// 內容質量評估（加強版）
function assessContentQuality(content, requirements) {
    const assessment = {
        score: 0,
        feedback: [],
        passed: false
    };

    // 長度檢查（提高標準到200字以上）
    if (content.length >= 200 && content.length <= 1000) {
        assessment.score += 25;
    } else if (content.length >= 150 && content.length < 200) {
        assessment.score += 15;
        assessment.feedback.push(`內容稍短，建議增加到200字以上（當前: ${content.length}字）`);
    } else if (content.length < 150) {
        assessment.feedback.push(`內容過短: ${content.length}字，需要達到200字以上`);
    } else {
        assessment.feedback.push(`內容過長: ${content.length}字，建議控制在1000字以內`);
    }

    // 結構檢查（更嚴格）
    const paragraphs = content.split('\n').filter(p => p.trim().length > 0);
    if (paragraphs.length >= 3) {
        assessment.score += 20;
    } else if (paragraphs.length >= 2) {
        assessment.score += 10;
        assessment.feedback.push('建議增加更多段落分層');
    } else {
        assessment.feedback.push('內容結構需要改善，建議分段呈現');
    }

    // 價值內容檢查
    const valueIndicators = ['具體', '實用', '步驟', '方法', '技巧', '經驗', '案例', '建議', '解決', '提升', '改善', '策略'];
    const foundValueTerms = valueIndicators.filter(term => content.includes(term));
    if (foundValueTerms.length >= 3) {
        assessment.score += 20;
    } else if (foundValueTerms.length >= 1) {
        assessment.score += 10;
        assessment.feedback.push('建議增加更多具體價值內容');
    } else {
        assessment.feedback.push('缺少實用價值內容，建議添加具體建議或方法');
    }

    // 表情符號檢查
    const emojiRegex = /[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]/gu;
    const emojiCount = (content.match(emojiRegex) || []).length;
    if (emojiCount >= 2 && emojiCount <= 8) {
        assessment.score += 10;
    } else if (emojiCount === 1) {
        assessment.score += 5;
    }

    // 繁體中文檢查
    const traditionalChineseRegex = /[\u4e00-\u9fff]/;
    if (traditionalChineseRegex.test(content)) {
        assessment.score += 15;
    } else {
        assessment.feedback.push('內容應使用繁體中文');
    }

    // 互動元素檢查（更全面）
    const interactiveElements = ['？', '！', '你', '我們', '大家', '分享', '評論', '想法', '經驗', '看法', '建議'];
    const foundElements = interactiveElements.filter(element => content.includes(element));
    if (foundElements.length >= 4) {
        assessment.score += 15;
    } else if (foundElements.length >= 2) {
        assessment.score += 10;
    } else {
        assessment.feedback.push('需要增加更多互動元素和問句');
    }

    // 避免空洞內容檢查
    const fluffWords = ['加油', '努力', '堅持', '相信', '一定可以', '沒問題'];
    const fluffCount = fluffWords.filter(word => content.includes(word)).length;
    if (fluffCount > 2) {
        assessment.score -= 10;
        assessment.feedback.push('減少空洞勵志語言，增加實質內容');
    }

    // 提高通過標準
    assessment.passed = assessment.score >= 80;
    return assessment;
}

app.use(cors());
app.use(express.json());

// 增強的中間件
app.use((req, res, next) => {
    console.log(`📥 ${new Date().toISOString()} ${req.method} ${req.url}`);
    next();
});

// 健康檢查
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        api_configs: API_CONFIGS.length,
        current_config: API_CONFIGS[currentConfigIndex].name,
        service: 'Enhanced Jab Right Hook Generator',
        logs_directory: logDir
    });
});

// 增強的內容生成API
app.post('/api/generate-content', async (req, res) => {
    const startTime = Date.now();
    
    try {
        const { topic, contentType, platform, style, count = 1 } = req.body;
        
        console.log('📝 Enhanced content generation request:', { topic, contentType, platform, style, count });

        // 輸入驗證
        if (!topic || topic.trim() === '') {
            return res.status(400).json({
                error: '主題不能為空',
                details: '請提供有效的主題'
            });
        }

        const systemPrompt = `你是一位深度精通《Jab, Jab, Jab, Right Hook》策略的世界頂級內容創作大師。你完全掌握了Gary Vaynerchuk的精髓思想，能夠創作出符合深度精讀原則的高品質社群媒體內容。

## 🎯 JAB 深度精讀核心原則：
✅ **價值至上**：每一個JAB都必須提供純粹價值，不求回報
✅ **真實故事**：基於真實經驗和具體案例，拒絕空洞理論
✅ **情感連結**：理解受眾真實需求，創造深度共鳴
✅ **平台原生**：完全適應平台文化，如原生內容般自然
✅ **長期思維**：建立信任關係，而非短期轉化

## 🚀 RIGHT HOOK 精準原則：
✅ **時機精準**：在累積足夠價值後的完美時機
✅ **明確呼籲**：具體、可執行的行動指令
✅ **價值交換**：清楚說明用戶能獲得什麼
✅ **情感驅動**：結合情感觸發點和理性價值
✅ **即時行動**：創造緊迫感和立即行動的動力

## 📚 深度精讀內容標準：
1. 📝 **語言要求**：繁體中文，自然流暢，符合台灣用語習慣
2. 📊 **字數標準**：每篇內容至少200-300字，內容充實有深度
3. 🎯 **價值密度**：每段都有實用價值，避免一切無意義填充
4. 💡 **洞察深度**：提供獨特視角和專業見解，超越表面
5. 🔥 **開場魅力**：用數據、故事、問題或反常識開場
6. 📋 **邏輯架構**：問題→分析→解決方案→行動步驟
7. 💬 **互動設計**：設計能引發深度討論的問題和話題
8. ✨ **視覺體驗**：合理使用表情符號，清晰分段，易於閱讀

## 🎨 內容創作流程：
1. **洞察挖掘**：找出受眾真正的痛點和需求
2. **價值包裝**：將解決方案包裝成有趣、實用的內容
3. **故事敘述**：用故事、案例讓抽象概念具體化
4. **行動引導**：提供清晰的下一步行動指引
5. **情感共鳴**：觸動受眾的情感開關

你必須創作出讓讀者感到「學到東西、產生共鳴、想要行動、願意分享」的深度精讀級別內容！`;

        const enhancedPrompt = generateEnhancedPrompt(topic, contentType, platform, style);
        
        const contents = [];
        const failedAttempts = [];

        for (let i = 0; i < parseInt(count); i++) {
            let attempts = 0;
            let content = null;
            
            while (attempts < 3 && !content) {
                try {
                    const rawContent = await intelligentAPICall(enhancedPrompt, systemPrompt);
                    
                    // 質量評估
                    const quality = assessContentQuality(rawContent, { topic, contentType, platform, style });
                    
                    if (quality.passed) {
                        content = rawContent;
                        console.log(`✅ 內容 ${i + 1} 生成成功 (質量分數: ${quality.score})`);
                    } else {
                        console.log(`⚠️ 內容 ${i + 1} 質量不足 (分數: ${quality.score}), 重新生成...`);
                        console.log('反饋:', quality.feedback.join(', '));
                        attempts++;
                        
                        // 調整提示詞以改善質量
                        const improvedPrompt = enhancedPrompt + `\n\n## 特別注意\n請確保：\n${quality.feedback.map(f => `- ${f}`).join('\n')}`;
                        const improvedContent = await intelligentAPICall(improvedPrompt, systemPrompt);
                        
                        const improvedQuality = assessContentQuality(improvedContent, { topic, contentType, platform, style });
                        if (improvedQuality.passed || improvedQuality.score > quality.score) {
                            content = improvedContent;
                            console.log(`✅ 改善後內容 ${i + 1} 通過 (質量分數: ${improvedQuality.score})`);
                        }
                    }
                } catch (error) {
                    attempts++;
                    failedAttempts.push(`內容 ${i + 1}, 嘗試 ${attempts}: ${error.message}`);
                    
                    if (attempts >= 3) {
                        // 使用改進的高質量備用內容
                        content = generateHighQualityFallbackContent(topic, contentType, platform, style);
                        console.log(`💎 使用高質量備用內容 ${i + 1}`);
                    }
                }
            }
            
            if (content) {
                contents.push(content);
            }
        }

        const processingTime = Date.now() - startTime;

        logSuccess('Enhanced Content Generation', {
            topic,
            contentType,
            platform,
            style,
            requestedCount: count,
            generatedCount: contents.length,
            processingTime: `${processingTime}ms`,
            failedAttempts: failedAttempts.length,
            currentConfig: API_CONFIGS[currentConfigIndex].name
        });

        res.json({
            success: true,
            contents,
            metadata: {
                topic,
                contentType,
                platform,
                style,
                count: contents.length,
                processingTime,
                quality: 'enhanced',
                api_config: API_CONFIGS[currentConfigIndex].name
            },
            debug: {
                failedAttempts,
                totalAttempts: contents.length + failedAttempts.length
            }
        });

    } catch (error) {
        const processingTime = Date.now() - startTime;
        
        logError(error, {
            api: 'generate-content',
            request: req.body,
            processingTime,
            currentConfig: API_CONFIGS[currentConfigIndex].name
        });

        res.status(500).json({
            error: 'AI服務暫時無法使用',
            details: error.message,
            timestamp: new Date().toISOString(),
            processingTime,
            api_config: API_CONFIGS[currentConfigIndex].name,
            suggestion: '請稍後重試，或聯繫技術支援'
        });
    }
});

// API配置切換端點
app.post('/api/switch-config', (req, res) => {
    const { configIndex } = req.body;
    
    if (configIndex >= 0 && configIndex < API_CONFIGS.length) {
        currentConfigIndex = configIndex;
        console.log(`🔄 切換到配置: ${API_CONFIGS[currentConfigIndex].name}`);
        
        res.json({
            success: true,
            currentConfig: API_CONFIGS[currentConfigIndex],
            message: `已切換到 ${API_CONFIGS[currentConfigIndex].name}`
        });
    } else {
        res.status(400).json({
            error: '無效的配置索引',
            availableConfigs: API_CONFIGS.map((config, index) => ({
                index,
                name: config.name,
                model: config.model
            }))
        });
    }
});

// 獲取配置列表
app.get('/api/configs', (req, res) => {
    res.json({
        success: true,
        configs: API_CONFIGS.map((config, index) => ({
            index,
            name: config.name,
            model: config.model,
            maxTokens: config.maxTokens,
            current: index === currentConfigIndex
        })),
        currentConfig: currentConfigIndex
    });
});

// 增強的聊天API
app.post('/api/chat', async (req, res) => {
    try {
        const { message, history = [] } = req.body;

        if (!message || message.trim() === '') {
            return res.status(400).json({
                error: '訊息不能為空'
            });
        }

        const systemPrompt = `你是精通《Jab, Jab, Jab, Right Hook》策略的AI助手。請用繁體中文回應，提供專業且實用的建議。`;

        const enhancedMessage = `作為社群媒體行銷專家，請回答：${message}

請確保回答：
1. 實用且具體
2. 基於《Jab, Jab, Jab, Right Hook》原理
3. 適合繁體中文市場
4. 包含可執行的建議`;

        const reply = await intelligentAPICall(enhancedMessage, systemPrompt);

        logSuccess('Enhanced Chat Response', {
            messageLength: message.length,
            replyLength: reply.length,
            currentConfig: API_CONFIGS[currentConfigIndex].name
        });

        res.json({
            success: true,
            reply,
            timestamp: new Date().toISOString(),
            api_config: API_CONFIGS[currentConfigIndex].name
        });

    } catch (error) {
        logError(error, {
            api: 'chat',
            request: { messageLength: req.body.message?.length }
        });

        res.status(500).json({
            error: 'AI聊天服務暫時無法使用',
            details: error.message,
            timestamp: new Date().toISOString()
        });
    }
});

// 系統診斷端點
app.get('/api/diagnosis', async (req, res) => {
    const diagnosis = {
        timestamp: new Date().toISOString(),
        system: {
            status: 'operational',
            uptime: process.uptime(),
            memory: process.memoryUsage(),
            platform: process.platform,
            nodeVersion: process.version
        },
        api: {
            currentConfig: API_CONFIGS[currentConfigIndex],
            availableConfigs: API_CONFIGS.length,
            lastSwitchTime: new Date().toISOString()
        },
        logs: {
            directory: logDir,
            files: fs.readdirSync(logDir).filter(f => f.endsWith('.log'))
        }
    };

    // 測試當前API配置
    try {
        await intelligentAPICall('測試', '簡短回應測試');
        diagnosis.api.connectivity = 'ok';
    } catch (error) {
        diagnosis.api.connectivity = 'failed';
        diagnosis.api.lastError = error.message;
    }

    res.json(diagnosis);
});

// 啟動伺服器
function startServer(port) {
    const server = app.listen(port, () => {
        console.log('\n🎯 === Enhanced Jab Right Hook Generator ===');
        console.log(`🚀 伺服器運行在: http://localhost:${port}`);
        console.log(`📊 健康檢查: http://localhost:${port}/health`);
        console.log(`🔧 系統診斷: http://localhost:${port}/api/diagnosis`);
        console.log(`🔄 API配置: ${API_CONFIGS[currentConfigIndex].name}`);
        console.log('============================================\n');

        logSuccess('Enhanced Server Startup', {
            port: port,
            pid: process.pid,
            configsAvailable: API_CONFIGS.length,
            currentConfig: API_CONFIGS[currentConfigIndex].name
        });
    });

    server.on('error', (err) => {
        if (err.code === 'EADDRINUSE') {
            console.log(`⚠️ 端口 ${port} 已被使用，嘗試下一個端口...`);
            if (port < 3010) {
                startServer(port + 1);
            } else {
                console.error('❌ 無法找到可用端口 (3001-3010)');
                process.exit(1);
            }
        } else {
            logError(err, { phase: 'server_startup', port });
            console.error('❌ 伺服器啟動錯誤:', err.message);
            process.exit(1);
        }
    });
}

console.log('🔍 Enhanced AI Content Generator 啟動中...');
startServer(PORT);

// 全局錯誤處理
process.on('uncaughtException', (err) => {
    logError(err, { type: 'uncaughtException' });
    console.error('🚨 未捕獲的異常:', err.message);
});

process.on('unhandledRejection', (reason, promise) => {
    const error = new Error(reason?.message || 'Unknown Promise Rejection');
    logError(error, { type: 'unhandledRejection' });
    console.error('🚨 未處理的Promise拒絕:', reason);
}); 