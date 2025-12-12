package com.ustb.library.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 1. 登录接口
    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> loginData) {
        String phone = loginData.get("username");
        String password = loginData.get("password");

        String sql = "SELECT id, username, real_name, user_type FROM users WHERE username = ? AND password = ?";
        try {
            return jdbcTemplate.queryForMap(sql, phone, password);
        } catch (Exception e) {
            throw new RuntimeException("账号或密码错误");
        }
    }

    // 2. 注册接口 (新增)
    @PostMapping("/register")
    public String register(@RequestBody Map<String, String> regData) {
        String phone = regData.get("username");
        String password = regData.get("password");
        String realName = regData.get("realName"); // 真实姓名

        // 检查手机号是否已存在
        Integer count = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM users WHERE username = ?", Integer.class, phone);

        if (count != null && count > 0) {
            throw new RuntimeException("该手机号已注册！");
        }

        // 插入新用户
        String sql = "INSERT INTO users (username, password, real_name, user_type) VALUES (?, ?, ?, 'STUDENT')";
        jdbcTemplate.update(sql, phone, password, realName);

        return "注册成功";
    }

    // 3. 查询我的借阅
    @GetMapping("/{userId}/borrowed")
    public List<Map<String, Object>> getMyBorrowedBooks(@PathVariable Integer userId) {
        String sql = "SELECT r.id, b.title, b.author, r.borrow_date, r.due_date " +
                "FROM borrow_records r " +
                "JOIN books b ON r.book_id = b.id " +
                "WHERE r.user_id = ? AND r.status = 'BORROWING' " +
                "ORDER BY r.borrow_date DESC";
        return jdbcTemplate.queryForList(sql, userId);
    }
}