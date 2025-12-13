import './assets/main.css'

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// === 新增部分开始：引入 Element Plus ===
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
// === 新增部分结束 ===

const app = createApp(App)

app.use(router)

// === 告诉 Vue 使用 Element Plus ===
app.use(ElementPlus)

app.mount('#app')
