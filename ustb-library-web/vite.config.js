import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    host: '0.0.0.0', // <--- 关键修改：允许外部IP访问
    port: 5173,      // 端口保持不变

    allowedHosts: true, // 允许任何域名访问 (Vite 5.x+)

    proxy: {
      '/api': {
        // 这里不用改，因为代理是在你电脑内部完成的
        target: 'http://localhost:8080',
        changeOrigin: true,
      }
    }
  }
})
