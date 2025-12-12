<script setup>
import { Search, Notebook, Plus } from '@element-plus/icons-vue'

// 接收父组件传来的数据
defineProps({
  currentUser: Object,
  searchKeyword: String,
  showSearch: Boolean
})

// 定义事件
// 新增了 'openAddBook'
defineEmits(['update:searchKeyword', 'doSearch', 'goHome', 'openLogin', 'openRegister', 'openMyBooks', 'logout', 'openAddBook'])
</script>

<template>
  <header class="navbar">
    <div class="container nav-content">
      <div class="nav-brand" @click="$emit('goHome')">
        <div class="logo-icon"><el-icon><Notebook /></el-icon></div>
        <div class="brand-text">
          <span class="main">USTB Library</span>
          <span class="sub">数字图书馆</span>
        </div>
      </div>

      <div class="nav-search" v-if="showSearch">
        <div class="input-group">
          <input
            :value="searchKeyword"
            @input="$emit('update:searchKeyword', $event.target.value)"
            placeholder="输入书名、ISBN..."
            @keyup.enter="$emit('doSearch')"
          />
          <button @click="$emit('doSearch')"><el-icon><Search /></el-icon></button>
        </div>
      </div>

      <div class="nav-user">
        <template v-if="currentUser">

          <el-button
            v-if="currentUser.user_type === 'ADMIN'"
            type="success"
            round
            plain
            size="small"
            style="margin-right: 8px"
            @click="$emit('openAddBook')"
          >
            <el-icon style="margin-right: 4px"><Plus /></el-icon> 图书录入
          </el-button>

          <div class="user-card" @click="$emit('openMyBooks')">
            <el-avatar :size="32" style="background:#005eb8">{{ currentUser.real_name[0] }}</el-avatar>
            <span class="username">{{ currentUser.real_name }}</span>
            <span class="badge">我的借阅</span>
          </div>
          <el-divider direction="vertical" />
          <el-button link class="logout-btn" @click="$emit('logout')">退出</el-button>
        </template>

        <template v-else>
          <el-button text @click="$emit('openLogin')">登录</el-button>
          <el-button type="primary" round @click="$emit('openRegister')" color="#005eb8">注册</el-button>
        </template>
      </div>
    </div>
  </header>
</template>

<style scoped>
.navbar { height: 64px; background: #fff; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100; }
.nav-content { display: flex; align-items: center; justify-content: space-between; height: 100%; }
.nav-brand { display: flex; align-items: center; cursor: pointer; gap: 12px; }
.logo-icon { width: 36px; height: 36px; background: #005eb8; color: #fff; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 20px; }
.brand-text { display: flex; flex-direction: column; line-height: 1.1; }
.brand-text .main { font-weight: 700; color: #005eb8; font-size: 18px; }
.brand-text .sub { font-size: 12px; color: #909399; letter-spacing: 1px; }

.nav-search .input-group { display: flex; border: 1px solid #dcdfe6; border-radius: 20px; overflow: hidden; padding-left: 15px; background: #f5f7fa; width: 300px; transition: all 0.3s; }
.nav-search .input-group:focus-within { border-color: #005eb8; background: #fff; width: 400px; }
.nav-search input { border: none; background: transparent; outline: none; height: 36px; flex: 1; font-size: 14px; }
.nav-search button { border: none; background: transparent; cursor: pointer; padding: 0 15px; color: #606266; }
.nav-search button:hover { color: #005eb8; }

.nav-user { display: flex; align-items: center; gap: 10px; }
.user-card { display: flex; align-items: center; gap: 8px; padding: 4px 12px; background: #f0f2f5; border-radius: 20px; cursor: pointer; transition: background 0.2s; }
.user-card:hover { background: #e6e8eb; }
.user-card .username { font-weight: 600; color: #333; font-size: 14px; }
.user-card .badge { font-size: 12px; color: #005eb8; }
.logout-btn { color: #909399; }
.logout-btn:hover { color: #f56c6c; }
</style>
