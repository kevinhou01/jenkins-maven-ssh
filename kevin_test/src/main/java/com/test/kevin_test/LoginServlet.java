package com.test.kevin_test;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
   
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //一般都会在doGet()方法中调用doPost()方法，或者在doPost()方法中调用doGet()方法
        doPost(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //设置编码格式，可以防止乱码出现
        response.setContentType("text/html; charset=UTF-8");
        //response.setCharacterEncoding("utf-8");
        //request.setCharacterEncoding("utf-8");
        //获取用户提交过来的用户名和密码，是通过表单中input的name属性获取的
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        System.out.println(username+":"+password);
        //获取输出流，用户显示信息，也可以用转发或者重定向
        PrintWriter pw = response.getWriter();
        if("admin".equals(username) && "123".equals(password)){
            pw.write("login success");
            /*
             * 要先创建success.jsp文件
             */
            //转发
//            request.getRequestDispatcher("success.jsp").forward(request, response);;
            //重定向
//            response.sendRedirect("success.jsp");
        }else{
            pw.write("login fail");
            /*
             * 要先创建fail.jsp文件
             */
            //转发
//            request.getRequestDispatcher("fail.jsp").forward(request, response);;
            //重定向
//            response.sendRedirect("fail.jsp");
        }
    
    }

}