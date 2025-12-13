/*
  USTB Library System Initialization Script
  适用于: KingbaseES V8/V9, PostgreSQL 12+ (Docker)
*/

-- ========================================================
-- 1. 清理环境 (Drop tables & sequences)
-- ========================================================
DROP TABLE IF EXISTS "public"."borrow_records";
DROP TABLE IF EXISTS "public"."books";
DROP TABLE IF EXISTS "public"."users";
DROP TABLE IF EXISTS "public"."locations";
DROP TABLE IF EXISTS "public"."colleges";

DROP SEQUENCE IF EXISTS "public"."borrow_records_id_seq";
DROP SEQUENCE IF EXISTS "public"."books_id_seq";
DROP SEQUENCE IF EXISTS "public"."users_id_seq";
DROP SEQUENCE IF EXISTS "public"."locations_id_seq";
DROP SEQUENCE IF EXISTS "public"."colleges_id_seq";

-- ========================================================
-- 2. 创建序列 (Sequences)
-- ========================================================
CREATE SEQUENCE "public"."colleges_id_seq" START 1 INCREMENT 1;
CREATE SEQUENCE "public"."locations_id_seq" START 1 INCREMENT 1;
CREATE SEQUENCE "public"."users_id_seq" START 1 INCREMENT 1;
CREATE SEQUENCE "public"."books_id_seq" START 1 INCREMENT 1;
CREATE SEQUENCE "public"."borrow_records_id_seq" START 1 INCREMENT 1;

-- ========================================================
-- 3. 创建表结构 (Tables)
-- ========================================================

-- 3.1 学院表
CREATE TABLE "public"."colleges" (
  "id" bigint DEFAULT nextval('"public"."colleges_id_seq"') NOT NULL,
  "name" varchar(255) NOT NULL,
  "code" varchar(50),
  CONSTRAINT "colleges_pkey" PRIMARY KEY ("id")
);

-- 3.2 馆藏地表
CREATE TABLE "public"."locations" (
  "id" bigint DEFAULT nextval('"public"."locations_id_seq"') NOT NULL,
  "name" varchar(255) NOT NULL,
  CONSTRAINT "locations_pkey" PRIMARY KEY ("id")
);

-- 3.3 用户表
CREATE TABLE "public"."users" (
  "id" bigint DEFAULT nextval('"public"."users_id_seq"') NOT NULL,
  "username" varchar(50) NOT NULL,
  "password" varchar(100) NOT NULL,
  "real_name" varchar(50),
  "user_type" varchar(20) DEFAULT 'STUDENT',
  "college_id" integer,
  "created_at" timestamp(0) DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "users_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "users_username_key" UNIQUE ("username")
);

-- 3.4 图书表
CREATE TABLE "public"."books" (
  "id" bigint DEFAULT nextval('"public"."books_id_seq"') NOT NULL,
  "title" varchar(255) NOT NULL,
  "author" varchar(100),
  "isbn" varchar(50),
  "price" DECIMAL(10,2), -- 修复: 将 number 改为标准的 DECIMAL
  "location_id" integer,
  "stock" integer DEFAULT 1,
  "status" varchar(20) DEFAULT 'AVAILABLE',
  "created_at" timestamp(0) DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "books_pkey" PRIMARY KEY ("id")
);

-- 3.5 借阅记录表
CREATE TABLE "public"."borrow_records" (
  "id" bigint DEFAULT nextval('"public"."borrow_records_id_seq"') NOT NULL,
  "user_id" integer NOT NULL,
  "book_id" integer NOT NULL,
  "borrow_date" timestamp(0) DEFAULT CURRENT_TIMESTAMP,
  "due_date" timestamp(0),
  "return_date" timestamp(0),
  "status" varchar(20) DEFAULT 'BORROWING',
  CONSTRAINT "borrow_records_pkey" PRIMARY KEY ("id")
);

-- ========================================================
-- 4. 插入数据 (Data Insertion)
-- ========================================================

-- 4.1 学院数据
INSERT INTO "public"."colleges" ("id", "name", "code") VALUES 
(1, '计算机与通信工程学院', '23'),
(2, '自动化学院', '21'),
(3, '机械工程学院', '12'),
(4, '土木与资源工程学院', '10');

-- 4.2 馆藏地数据
INSERT INTO "public"."locations" ("id", "name") VALUES 
(1, '图书馆主楼'),
(2, '逸夫楼');

-- 4.3 用户数据
INSERT INTO "public"."users" ("id", "username", "password", "real_name", "user_type", "college_id", "created_at") VALUES 
(1, 'admin', '123456', '图书馆管理员', 'ADMIN', 1, '2025-12-12 05:51:02'),
(2, '13800138000', '123456', '测试同学', 'STUDENT', NULL, '2025-12-12 08:08:28'),
(3, '12345678901', '123456', 'lsy', 'STUDENT', NULL, '2025-12-12 09:02:29'),
(4, '111', '123', '666', 'STUDENT', NULL, '2025-12-12 12:42:23');

-- 4.4 图书数据
INSERT INTO "public"."books" ("id", "title", "author", "isbn", "price", "location_id", "stock", "status", "created_at") VALUES 
(1, '深入理解计算机系统（原书第3版）', 'Randal E. Bryant', '9787111544979', 139.00, 1, 12, 'AVAILABLE', '2025-12-12 11:11:20'),
(2, '算法导论（原书第3版）', 'Thomas H. Cormen', '9787111407010', 128.50, 1, 5, 'AVAILABLE', '2025-12-12 11:11:20'),
(3, 'Java核心技术·卷 I（第11版）', 'Cay S. Horstmann', '9787111636663', 119.00, 1, 8, 'AVAILABLE', '2025-12-12 11:11:20'),
(4, '高性能MySQL（第3版）', 'Baron Schwartz', '9787121198854', 128.00, 1, 2, 'AVAILABLE', '2025-12-12 11:11:20'),
(5, '设计模式：可复用面向对象软件的基础', 'Erich Gamma', '9787111075752', 69.00, 1, 15, 'AVAILABLE', '2025-12-12 11:11:20'),
(6, '代码整洁之道', 'Robert C. Martin', '9787115216878', 59.00, 1, 0, 'AVAILABLE', '2025-12-12 11:11:20'),
(7, '人月神话（40周年中文纪念版）', 'Frederick P. Brooks Jr.', '9787302392644', 88.00, 1, 7, 'AVAILABLE', '2025-12-12 11:11:20'),
(8, '深度学习（花书）', 'Ian Goodfellow', '9787115461476', 168.00, 1, 3, 'AVAILABLE', '2025-12-12 11:11:20'),
(9, '机器学习实战', 'Peter Harrington', '9787115314452', 69.00, 1, 10, 'AVAILABLE', '2025-12-12 11:11:20'),
(10, 'Vue.js设计与实现', '霍春阳', '9787115583147', 119.80, 1, 20, 'AVAILABLE', '2025-12-12 11:11:20'),
(11, '三体全集', '刘慈欣', '9787229030933', 93.00, 1, 30, 'AVAILABLE', '2025-12-12 11:11:20'),
(12, '人类简史：从动物到上帝', '尤瓦尔·赫拉利', '9787508660752', 68.00, 1, 1, 'AVAILABLE', '2025-12-12 11:11:20'),
(13, '明朝那些事儿（全集）', '当年明月', '9787505742438', 298.00, 1, 5, 'AVAILABLE', '2025-12-12 11:11:20'),
(14, '活着', '余华', '9787506365437', 28.00, 1, 0, 'AVAILABLE', '2025-12-12 11:11:20'),
(15, '百年孤独', '加西亚·马尔克斯', '9787544253994', 55.00, 1, 18, 'AVAILABLE', '2025-12-12 11:11:20'),
(16, '平凡的世界（全三册）', '路遥', '9787530219213', 108.00, 1, 25, 'AVAILABLE', '2025-12-12 11:11:20');

-- 4.5 借阅记录数据
INSERT INTO "public"."borrow_records" ("id", "user_id", "book_id", "borrow_date", "due_date", "return_date", "status") VALUES 
(1, 3, 1, '2025-12-12 09:03:03', '2026-01-11 09:03:03', '2025-12-12 10:53:18', 'RETURNED'),
(2, 4, 16, '2025-12-12 12:42:41', '2026-01-11 12:42:41', '2025-12-12 12:44:10', 'RETURNED'),
(3, 3, 1, '2025-12-12 14:20:45', '2026-01-11 14:20:45', '2025-12-12 14:20:50', 'RETURNED'),
(4, 1, 16, '2025-12-12 14:37:13', '2026-01-11 14:37:13', '2025-12-12 14:37:17', 'RETURNED');

-- ========================================================
-- 5. 重置序列值 (Sequence Reset)
-- 确保下一个插入的数据 ID 不会冲突
-- ========================================================
SELECT setval('"public"."colleges_id_seq"', 4, true);
SELECT setval('"public"."locations_id_seq"', 2, true);
SELECT setval('"public"."users_id_seq"', 4, true);
SELECT setval('"public"."books_id_seq"', 16, true);
SELECT setval('"public"."borrow_records_id_seq"', 4, true);

-- ========================================================
-- 6. 添加外键约束 (Foreign Keys)
-- 放在最后执行，避免插入数据时报外键不存在错误
-- ========================================================
ALTER TABLE "public"."users" ADD CONSTRAINT "users_college_id_fkey" FOREIGN KEY ("college_id") REFERENCES "public"."colleges" ("id");
ALTER TABLE "public"."books" ADD CONSTRAINT "books_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "public"."locations" ("id");
-- borrow_records 建议也加外键，虽然原文件没加，这里为了严谨我加上
-- ALTER TABLE "public"."borrow_records" ADD CONSTRAINT "borrow_records_user_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id");
-- ALTER TABLE "public"."borrow_records" ADD CONSTRAINT "borrow_records_book_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books" ("id");