# USTB 图书馆管理系统 (Docker 版)

## 项目简介
这是一个基于 Spring Boot + Vue 3 + PostgreSQL 的全栈图书馆管理系统。
已完成 Docker 容器化封装，可一键部署。

## 技术栈
- **前端**: Vue 3, Vite 7, Element Plus (运行在 Nginx 容器)
- **后端**: Spring Boot 3, JDK 17 (运行在 Eclipse-Temurin 容器)
- **数据库**: PostgreSQL 15 (兼容人大金仓模式)

## 如何运行 (Quick Start)

1. 确保已安装 Docker Desktop。
2. 在项目根目录下打开终端。
3. 运行启动命令：
   docker-compose up --build -d

4. 访问地址：
   - 前端页面: http://localhost
   - 后端接口: http://localhost:8080/api/books/list
     (注：如果端口冲突，请修改 docker-compose.yml 映射端口)

## 注意事项
- 系统启动约需 30 秒，请耐心等待 Backend 容器完成初始化。
- 默认管理员账号: admin / 123456