package com.ustb.library.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class BookService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 修复后的获取图书列表逻辑 (防SQL注入版)
    // 修改 BookService.java 中的 getBookList 方法
    public List<Map<String, Object>> getBookList(String keyword) {
        StringBuilder sql = new StringBuilder();
        // 基础查询
        sql.append("SELECT b.id, b.title, b.author, b.price, b.stock, l.name as location_name ");
        sql.append("FROM books b ");
        sql.append("LEFT JOIN locations l ON b.location_id = l.id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND (b.title LIKE ? OR b.author LIKE ? OR b.isbn LIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        // === 关键修改 ===
        // 原来可能是 ORDER BY b.id DESC (这其实已经是倒序了，如果是乱序请确保这里是 DESC)
        // 确保这里是 DESC，这样 ID 最大的（最新的）会在最前面
        sql.append("ORDER BY b.id DESC");

        return jdbcTemplate.queryForList(sql.toString(), params.toArray());
    }

    // 核心：借书逻辑 (保持不变，或在此确认没有拼接SQL)
    @Transactional
    public void processBorrow(Integer userId, Integer bookId) {
        // ... (这部分原来的代码使用了 ? 占位符，是安全的，可以保持原样)
        // 为了完整性，我把原来的代码逻辑粘贴在这里，确保你不会误删

        // 1. 检查库存
        String checkStockSql = "SELECT stock FROM books WHERE id = ?";
        Integer stock;
        try {
            stock = jdbcTemplate.queryForObject(checkStockSql, Integer.class, bookId);
        } catch (Exception e) {
            throw new RuntimeException("书籍不存在");
        }

        if (stock == null || stock <= 0) {
            throw new RuntimeException("手慢了！这本书已经被借光了。");
        }

        // 2. 扣减库存
        jdbcTemplate.update("UPDATE books SET stock = stock - 1 WHERE id = ?", bookId);

        // 3. 插入记录
        String insertSql = "INSERT INTO borrow_records (user_id, book_id, due_date, status) " +
                "VALUES (?, ?, CURRENT_TIMESTAMP + INTERVAL '30 day', 'BORROWING')";
        jdbcTemplate.update(insertSql, userId, bookId);
    }
    // 4. 核心：还书逻辑 (事务管理)
    @Transactional
    public void processReturn(Integer borrowRecordId) {
        // 1. 查询该借阅记录目前的借阅状态和对应的书籍ID
        String selectSql = "SELECT book_id, status FROM borrow_records WHERE id = ?";
        Map<String, Object> record;
        try {
            record = jdbcTemplate.queryForMap(selectSql, borrowRecordId);
        } catch (Exception e) {
            throw new RuntimeException("借阅记录不存在");
        }

        Integer bookId = (Integer) record.get("book_id");
        String status = (String) record.get("status");

        // 2. 校验状态：只有 "BORROWING" (借阅中) 的才能还
        if (!"BORROWING".equals(status)) {
            throw new RuntimeException("该书已归还或状态异常，无法重复归还");
        }

        // 3. 更新借阅记录状态 -> RETURNED，并写入归还时间
        String updateRecordSql = "UPDATE borrow_records SET status = 'RETURNED', return_date = CURRENT_TIMESTAMP WHERE id = ?";
        jdbcTemplate.update(updateRecordSql, borrowRecordId);

        // 4. 图书库存 + 1
        String updateStockSql = "UPDATE books SET stock = stock + 1 WHERE id = ?";
        jdbcTemplate.update(updateStockSql, bookId);
    }
    // 5. 管理员：添加新书
    public void addBook(Map<String, Object> bookData) {
        String sql = "INSERT INTO books (title, author, isbn, price, stock, location_id) VALUES (?, ?, ?, ?, ?, 1)";
        // location_id 暂时写死为 1 (主馆)，后续你可以做下拉框选择

        jdbcTemplate.update(sql,
                bookData.get("title"),
                bookData.get("author"),
                bookData.get("isbn"),
                bookData.get("price"),
                bookData.get("stock")
        );
    }

    // 辅助方法：检查用户是否为管理员
    public boolean isAdmin(Integer userId) {
        try {
            String sql = "SELECT user_type FROM users WHERE id = ?";
            String type = jdbcTemplate.queryForObject(sql, String.class, userId);
            return "ADMIN".equals(type);
        } catch (Exception e) {
            return false;
        }
    }
}