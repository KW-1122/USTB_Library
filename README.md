# USTB Library

北京科技大学图书馆管理系统

## 技术栈

- **后端**: Spring Boot 4.0.0 + Java 17 + KingBase
- **前端**: Vue 3 + Vite + Element Plus

## 功能特性

- 📚 图书搜索（书名、作者、ISBN）
- 👤 用户注册/登录
- 📖 图书借阅/归还
- 🔐 管理员图书录入
- 📋 我的借阅记录

## 快速开始

### 后端

```bash
cd ustb-library-system
mvn spring-boot:run
```

### 前端

```bash
cd ustb-library-web
npm install
npm run dev
```

## 数据库配置

修改 `ustb-library-system/src/main/resources/application.properties` 中的数据库连接信息。
