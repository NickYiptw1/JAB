# AI內容生產器修復指南

## 常見問題處理

1. 伺服器無法啟動
   - 檢查 Node.js 是否正確安裝
   - 檢查端口 3001 是否被佔用
   - 執行 `quick-fix.bat` 進行快速修復

2. 前端無法連接
   - 確認伺服器是否正在運行
   - 檢查瀏覽器控制台錯誤信息
   - 使用 `test-fixed.html` 進行測試

3. 內容生成失敗
   - 檢查 API 配置是否正確
   - 查看錯誤日誌
   - 使用較小的生成量進行測試

## 修復步驟

1. 基礎修復
   ```bash
   npm install
   node simple-server-fixed.js
   ```

2. 進階修復
   ```bash
   node comprehensive-debug.js
   node enhanced-server.js
   ```

3. 完整重置
   - 刪除 node_modules 目錄
   - 刪除 logs 目錄
   - 重新執行 npm install
   - 使用 ultimate-startup.bat 啟動