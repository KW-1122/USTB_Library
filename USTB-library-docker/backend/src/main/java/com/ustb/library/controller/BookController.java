package com.ustb.library.controller;

import com.ustb.library.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/books")
public class BookController {

    @Autowired
    private BookService bookService;

    @GetMapping("/list")
    public List<Map<String, Object>> getBooks(@RequestParam(required = false) String keyword) {
        // 逻辑全部移交给 Service
        return bookService.getBookList(keyword);
    }

    @PostMapping("/borrow")
    public String borrowBook(@RequestBody Map<String, Integer> request) {
        Integer userId = request.get("userId");
        Integer bookId = request.get("bookId");

        // Controller 只负责传参和返回结果，不处理 SQL
        bookService.processBorrow(userId, bookId);

        return "借阅成功！";
    }
    // 还书接口
    @PostMapping("/return")
    public String returnBook(@RequestBody Map<String, Integer> request) {
        // 前端传过来的是借阅记录的ID (borrow_records 表的主键)
        Integer recordId = request.get("recordId");

        bookService.processReturn(recordId);

        return "归还成功！";
    }
    // 管理员录入图书接口
    @PostMapping("/add")
    public String addBook(@RequestBody Map<String, Object> request) {
        // 1. 获取操作者的 ID
        Integer operatorId = (Integer) request.get("operatorId");

        // 2. 严厉的权限检查 (后端防线)
        if (!bookService.isAdmin(operatorId)) {
            throw new RuntimeException("无权操作！只有管理员可以录入图书。");
        }

        // 3. 执行添加
        bookService.addBook(request);
        return "图书录入成功！";
    }
}