<script setup>
// 接收父组件传递的数据
defineProps({
  books: {
    type: Array,
    default: () => [] // 默认为空数组
  }
})

// 定义向父组件发送的事件
const emit = defineEmits(['borrow'])

// 处理点击事件，通知父组件
const onBookClick = (book) => {
  emit('borrow', book)
}
</script>

<template>
  <div class="book-grid">
    <div
      v-for="book in books"
      :key="book.id"
      class="book-card"
      @click="onBookClick(book)"
    >
      <div class="card-image">
        <div class="placeholder-cover">
          <span class="cover-title">{{ book.title }}</span>
          <div class="hover-mask">点击查看详情</div>
        </div>
      </div>

      <div class="card-details">
        <h4 class="book-title" :title="book.title">{{ book.title }}</h4>
        <div class="book-author">{{ book.author }}</div>

        <div class="book-meta">
          <span class="price">¥{{ book.price }}</span>
          <el-tag
            size="small"
            :type="book.stock > 0 ? 'success' : 'danger'"
            effect="plain"
          >
            {{ book.stock > 0 ? `库存 ${book.stock}` : '暂无库存' }}
          </el-tag>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* === Grid 布局调整 === */
.book-grid {
  display: grid;
  /* 自适应列宽，最小 240px */
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 36px;
  padding-bottom: 40px;
  /* [关键修复]：确保在宽屏下如果一行填不满，剩余卡片居中，或者整体居中 */
  justify-content: center;
}

/* === 卡片交互 === */
.book-card {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid #f0f2f5;
  transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
  cursor: pointer;
  display: flex;
  flex-direction: column;
  position: relative;
  top: 0;
}

.book-card:hover {
  transform: translateY(-12px) scale(1.02);
  box-shadow: 0 20px 40px rgba(0,0,0,0.08);
  border-color: transparent;
  z-index: 2;
}

.card-image {
  height: 280px;
  background: #f8faff;
  position: relative;
  overflow: hidden;
  border-bottom: 1px solid #f5f7fa;
}

.placeholder-cover {
  width: 100%;
  height: 100%;
  background: linear-gradient(to bottom right, #eef2f8, #ffffff);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 30px;
  box-sizing: border-box;
  text-align: center;
  transition: transform 0.4s;
}
.book-card:hover .placeholder-cover { transform: scale(1.05); }

.cover-title {
  font-family: "Times New Roman", serif;
  font-size: 22px;
  font-weight: 800;
  color: #909399;
  line-height: 1.4;
  text-shadow: 1px 1px 2px rgba(255,255,255,0.8);
}

.hover-mask {
  position: absolute;
  top:0; left:0;
  width:100%; height:100%;
  background: rgba(0, 94, 184, 0.9);
  backdrop-filter: blur(4px);
  color:#fff;
  display:flex;
  align-items:center;
  justify-content:center;
  opacity:0;
  transition:all 0.3s;
  font-weight: 700;
  font-size: 18px;
  letter-spacing: 1px;
  transform: translateY(20px);
}

.book-card:hover .hover-mask { opacity: 1; transform: translateY(0); }

.card-details {
  padding: 20px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.book-title {
  margin: 0 0 8px;
  font-size: 18px;
  font-weight: 700;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  color: #1f2d3d;
}

.book-author {
  font-size: 14px;
  color: #909399;
  margin-bottom: 16px;
  font-weight: 500;
}

.book-meta {
  margin-top: auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price {
  color: #ff4d4f;
  font-weight: 800;
  font-size: 20px;
}
.price::before { content: '¥'; font-size: 14px; margin-right: 2px; font-weight: 600;}
</style>
