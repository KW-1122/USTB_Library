<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, User, Reading, ArrowRight, Plus } from '@element-plus/icons-vue'

// === 引入组件 ===
import TheHeader from '@/components/TheHeader.vue'
import BookList from '@/components/BookList.vue'

// === 数据定义 ===
const currentPage = ref('home')
const books = ref([])
const searchKeyword = ref('')
const currentUser = ref(null)

// 弹窗状态
const loginVisible = ref(false)
const registerVisible = ref(false)
const myBooksVisible = ref(false)
const addBookVisible = ref(false)
const myBorrowedList = ref([])

// 表单数据
const loginForm = ref({ username: '', password: '' })
const regForm = ref({ username: '', password: '', realName: '' })
const bookForm = ref({ title: '', author: '', isbn: '', price: '', stock: 10 })

// === 1. 获取图书 (后端已按 ID 倒序，这里取回来的就是新书) ===
const fetchBooks = async (isSearch = false) => {
  try {
    const res = await axios.get('/api/books/list', {
      params: { keyword: searchKeyword.value }
    })
    books.value = res.data

    if (isSearch) {
      currentPage.value = 'result'
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
  } catch (e) {
    console.log("API未连接")
  }
}

// === 2. 用户交互逻辑 (保持不变) ===
const handleLogin = async () => {
  try {
    const res = await axios.post('/api/user/login', loginForm.value)
    currentUser.value = res.data
    loginVisible.value = false
    ElMessage.success(`欢迎回来，${currentUser.value.real_name}`)
  } catch (e) { ElMessage.error('账号或密码错误') }
}

const handleRegister = async () => {
  if(!regForm.value.username || !regForm.value.password) return ElMessage.warning('请填写完整')
  try {
    await axios.post('/api/user/register', regForm.value)
    ElMessage.success('注册成功！请登录')
    registerVisible.value = false
    loginVisible.value = true
  } catch (e) { ElMessage.error(e.response?.data?.message || '注册失败') }
}

const logout = () => {
  currentUser.value = null
  goHome()
  ElMessage.info('已安全退出')
}

const handleBorrow = async (book) => {
  if (!currentUser.value) {
    loginVisible.value = true
    ElMessage.warning('请先登录后借阅')
    return
  }
  try {
    await ElMessageBox.confirm(`确认借阅《${book.title}》吗？`, '借书确认', { confirmButtonText: '确认借阅', cancelButtonText: '取消' })
    await axios.post('/api/books/borrow', { userId: currentUser.value.id, bookId: book.id })
    ElMessage.success('借阅成功！')
    fetchBooks(false)
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.response?.data?.message || '借阅失败')
  }
}

const openMyBooks = async () => {
  try {
    const res = await axios.get(`/api/user/${currentUser.value.id}/borrowed`)
    myBorrowedList.value = res.data
    myBooksVisible.value = true
  } catch(e) { ElMessage.error('获取记录失败') }
}

const handleReturn = async (row) => {
  try {
    await ElMessageBox.confirm(`确定要归还《${row.title}》吗？`, '还书确认', { type: 'warning' })
    await axios.post('/api/books/return', { recordId: row.id })
    ElMessage.success('归还成功！')
    openMyBooks()
    fetchBooks(false)
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.response?.data?.message || '归还失败')
  }
}

const handleAddBook = async () => {
  if(!bookForm.value.title || !bookForm.value.price) return ElMessage.warning('书名和价格必填')
  try {
    await axios.post('/api/books/add', { ...bookForm.value, operatorId: currentUser.value.id })
    ElMessage.success('录入成功！')
    addBookVisible.value = false
    bookForm.value = { title: '', author: '', isbn: '', price: '', stock: 10 }
    fetchBooks(false)
  } catch (e) {
    ElMessage.error(e.response?.data?.message || '录入失败')
  }
}

const goHome = () => {
  currentPage.value = 'home'
  searchKeyword.value = ''
  fetchBooks(false)
}

onMounted(() => {
  fetchBooks(false)
})
</script>

<template>
  <div class="zlib-layout">

    <TheHeader
      :current-user="currentUser"
      v-model:search-keyword="searchKeyword"
      :show-search="currentPage === 'result'"
      @do-search="fetchBooks(true)"
      @go-home="goHome"
      @open-login="loginVisible = true"
      @open-register="registerVisible = true"
      @open-my-books="openMyBooks"
      @logout="logout"
      @open-add-book="addBookVisible = true"
    />

    <main class="main-content">
      <transition name="fade-slide" mode="out-in">

        <div v-if="currentPage === 'home'" key="home" class="view-home">

          <div class="z-hero">
            <div class="z-logo-area">
              <h1 class="z-logo-text">USTB<span class="light">Library</span></h1>
              <p class="z-slogan">通往知识和文化的门户。每个人都可以使用。</p>
            </div>

            <div class="z-search-wrapper">
              <div class="z-search-tabs">
                <span class="active">通用搜索</span>
              </div>
              <div class="z-search-box">
                <input
                  v-model="searchKeyword"
                  placeholder="按书名、作者、ISBN、出版社等搜索..."
                  @keyup.enter="fetchBooks(true)"
                />
                <button class="z-search-btn" @click="fetchBooks(true)">
                  <el-icon><Search /></el-icon>
                </button>
              </div>
              <div class="z-search-tags">
                热门：<a @click="searchKeyword='Python';fetchBooks(true)">Python</a>
                <a @click="searchKeyword='算法';fetchBooks(true)">算法</a>
                <a @click="searchKeyword='历史';fetchBooks(true)">历史</a>
              </div>
            </div>
          </div>

          <div class="z-section-container">
            <div class="z-section-header">
              <div class="header-title">
                <span class="blue-line"></span>
                <h3>最新添加 / New Arrivals</h3>
              </div>
            </div>

            <BookList :books="books.slice(0, 8)" @borrow="handleBorrow" />
          </div>

        </div>

        <div v-else key="result" class="view-result">
          <div class="result-container">
            <div class="result-meta">
              <el-breadcrumb separator="/">
                <el-breadcrumb-item :to="{ path: '/' }" @click="goHome">首页</el-breadcrumb-item>
                <el-breadcrumb-item>搜索结果</el-breadcrumb-item>
              </el-breadcrumb>
              <h2>“{{ searchKeyword }}” 的搜索结果</h2>
            </div>

            <div class="result-grid">
              <div v-for="book in books" :key="book.id" class="z-list-item">
                <div class="book-cover-wrap">{{ book.title[0] }}</div>
                <div class="book-info">
                  <h3>{{ book.title }}</h3>
                  <p class="author">{{ book.author }}</p>
                  <p class="meta">{{ book.isbn }} | {{ book.location_name || '主馆' }}</p>
                  <div class="status">
                       <span :class="book.stock > 0 ? 'green' : 'red'">
                         {{ book.stock > 0 ? '可借阅' : '暂无库存' }}
                       </span>
                  </div>
                </div>
                <div class="book-action">
                  <el-button type="primary" round size="small" :disabled="book.stock <= 0" @click="handleBorrow(book)">借阅</el-button>
                </div>
              </div>
              <el-empty v-if="books.length === 0" description="没有找到这本书" />
            </div>
          </div>
        </div>

      </transition>
    </main>

    <footer class="z-footer">
      <div class="footer-inner">
        <span>© 2025 USTB Library Project</span>
        <span>由 前端实验小组 技术支持</span>
      </div>
    </footer>

    <el-dialog v-model="loginVisible" title="用户登录" width="400px" center destroy-on-close>
      <el-form size="large" label-position="top">
        <el-form-item label="账号"><el-input v-model="loginForm.username" :prefix-icon="User" placeholder="手机号" /></el-form-item>
        <el-form-item label="密码"><el-input v-model="loginForm.password" type="password" show-password placeholder="密码" /></el-form-item>
        <el-button type="primary" color="#333" style="width: 100%; margin-top: 10px" @click="handleLogin">登 录</el-button>
      </el-form>
    </el-dialog>

    <el-dialog v-model="registerVisible" title="注册新账号" width="400px" center destroy-on-close>
      <el-form size="large" label-position="top">
        <el-form-item label="手机号"><el-input v-model="regForm.username" /></el-form-item>
        <el-form-item label="真实姓名"><el-input v-model="regForm.realName" /></el-form-item>
        <el-form-item label="密码"><el-input v-model="regForm.password" type="password" /></el-form-item>
        <el-button type="success" style="width: 100%; margin-top: 10px" @click="handleRegister">注 册</el-button>
      </el-form>
    </el-dialog>

    <el-dialog v-model="myBooksVisible" title="我的借阅" width="800px">
      <el-table :data="myBorrowedList" stripe>
        <el-table-column property="title" label="书名" />
        <el-table-column label="归还时间">
          <template #default="scope">{{ scope.row.due_date?.substring(0,10) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="100">
          <template #default="scope"><el-button link type="primary" @click="handleReturn(scope.row)">归还</el-button></template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog v-model="addBookVisible" title="新书录入" width="500px">
      <el-form label-width="80px">
        <el-form-item label="书名"><el-input v-model="bookForm.title" /></el-form-item>
        <el-form-item label="作者"><el-input v-model="bookForm.author" /></el-form-item>
        <el-form-item label="ISBN"><el-input v-model="bookForm.isbn" /></el-form-item>
        <el-form-item label="价格"><el-input v-model="bookForm.price" /></el-form-item>
        <el-form-item label="库存"><el-input-number v-model="bookForm.stock" :min="1" /></el-form-item>
        <el-button type="primary" @click="handleAddBook" style="width:100%">提交</el-button>
      </el-form>
    </el-dialog>
  </div>
</template>

<style>
/* 全局重置：背景改为纯白，Z-Lib 风格 */
body { margin: 0; background-color: #fff; color: #333; font-family: "Helvetica Neue", Helvetica, "PingFang SC", "Hiragino Sans GB", Arial, sans-serif; }
</style>

<style scoped>
/* === 布局容器 === */
.zlib-layout { display: flex; flex-direction: column; min-height: 100vh; }
.main-content { flex: 1; display: flex; flex-direction: column; }

/* === 核心：Hero 区域 (Z-Library 风格) === */
.z-hero {
  /* 去掉蓝色背景，改为白色 */
  background: #fff;
  padding: 80px 440px 20px;
  display: flex;
  flex-direction: column;
  align-items: center; /* 绝对居中 */
  text-align: center;
}
/* === 2. 手机端适配 (屏幕宽度小于 768px) === */
@media (max-width: 768px) {
  .z-hero {
    /* 手机屏幕金贵，大幅减少上下留白 */
    padding: 50px 110px 30px;

    /* 手机上不需要那么高，稍微矮一点 */
    min-height: 30vh;

  }

  /* 顺便把字号也变小，防止撑开容器 */
  .z-logo-text {
    font-size: 40px; /* 原来是 60px */
  }


}

.z-logo-area { margin-bottom: 40px; }
.z-logo-text {
  font-size: 60px; /* 超大 Logo */
  margin: 0;
  color: #555; /* 深灰色，显高级 */
  font-weight: 400;
  letter-spacing: -2px;
}
.z-logo-text .light { color: #409eff; font-weight: 300; }
.z-slogan {
  color: #999;
  margin-top: 10px;
  font-size: 16px;
  letter-spacing: 1px;
}

/* 搜索框容器 */
.z-search-wrapper {
  width: 200%;
  max-width: 800px; /* 限制最大宽度，保证在大屏上也居中 */
}

.z-search-tabs {
  text-align: left;
  margin-bottom: -1px; /* 贴合边框 */
  padding-left: 2px;
}
.z-search-tabs span {
  display: inline-block;
  padding: 8px 16px;
  background: #f5f5f5;
  color: #666;
  border-radius: 4px 4px 0 0;
  font-size: 14px;
  cursor: pointer;
  border: 1px solid transparent;
}
.z-search-tabs span.active {
  background: #fff;
  border: 1px solid #dcdfe6;
  border-bottom: 1px solid #fff; /* 遮住下边框 */
  color: #333;
  font-weight: 500;
}

.z-search-box {
  display: flex;
  height: 56px;
  border: 1px solid #dcdfe6; /* 经典的灰色边框 */
  border-radius: 0 4px 4px 4px;
  background: #fff;
  box-shadow: 0 4px 12px rgba(0,0,0,0.03); /* 极淡的阴影 */
  transition: all 0.3s;
}
.z-search-box:focus-within {
  border-color: #409eff;
  box-shadow: 0 4px 20px rgba(64, 158, 255, 0.15);
}

.z-search-box input {
  flex: 1;
  border: none;
  padding: 0 20px;
  font-size: 16px;
  outline: none;
  color: #333;
}
.z-search-btn {
  width: 80px;
  background: #f8f9fa;
  border: none;
  border-left: 1px solid #eee;
  cursor: pointer;
  font-size: 20px;
  color: #666;
  transition: background 0.2s;
}
.z-search-btn:hover { background: #eef1f6; color: #409eff; }

.z-search-tags {
  margin-top: 12px;
  font-size: 13px;
  color: #999;
  text-align: left;
  padding-left: 5px;
}
.z-search-tags a {
  margin: 0 6px;
  color: #409eff;
  cursor: pointer;
  text-decoration: none;
}
.z-search-tags a:hover { text-decoration: underline; }

/* === 最新添加 (书架区域) === */
.z-section-container {
  width: 100%;
  max-width: 1200px; /* 页面内容最大宽度 */
  margin: 0 auto;    /* 居中 */
  padding: 40px 20px;
}

.z-section-header {
  margin-bottom: 24px;
  border-bottom: 2px solid #409eff; /* Z-Lib 风格的蓝色分割线 */
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding-bottom: 8px;
}
.header-title h3 {
  margin: 0;
  font-size: 18px;
  color: #409eff; /* 标题蓝色 */
  font-weight: 400;
}

/* === 搜索结果列表 (简约版) === */
.result-container {
  max-width: 1000px;
  margin: 40px auto;
  padding: 0 20px;
}
.result-meta { margin-bottom: 30px; text-align: center; }
.result-meta h2 { font-weight: 400; color: #333; margin-top: 10px;}

.z-list-item {
  display: flex;
  gap: 20px;
  padding: 20px;
  border-bottom: 1px solid #eee;
  transition: background 0.2s;
}
.z-list-item:hover { background: #fcfcfc; }
.book-cover-wrap {
  width: 80px; height: 110px;
  background: #f0f2f5;
  color: #909399;
  display: flex; align-items: center; justify-content: center;
  font-size: 32px; font-weight: bold; border-radius: 4px;
}
.book-info { flex: 1; text-align: left; }
.book-info h3 { margin: 0 0 8px; color: #409eff; font-size: 18px; cursor: pointer; }
.book-info .author { color: #333; font-weight: 500; margin: 4px 0; font-size: 14px;}
.book-info .meta { color: #999; font-size: 12px; }
.book-info .status .green { color: #67c23a; font-size: 12px; }
.book-info .status .red { color: #f56c6c; font-size: 12px; }
.book-action { display: flex; align-items: center; }

/* === Footer === */
.z-footer {
  margin-top: auto;
  border-top: 1px solid #eee;
  padding: 30px 0;
  background: #fff;
  text-align: center;
}
.footer-inner {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  color: #999;
  font-size: 13px;
  padding: 0 20px;
}

/* === 动效 === */
.fade-slide-enter-active, .fade-slide-leave-active { transition: opacity 0.3s ease; }
.fade-slide-enter-from, .fade-slide-leave-to { opacity: 0; }
</style>
