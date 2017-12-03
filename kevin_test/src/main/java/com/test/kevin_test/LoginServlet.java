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
        doPost(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //response.setContentType("text/html; charset=UTF-8");
        //response.setCharacterEncoding("utf-8");
        //request.setCharacterEncoding("utf-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        System.out.println(username+":"+password);
        PrintWriter pw = response.getWriter();
        if("admin".equals(username) && "123".equals(password)){
            pw.write("login success");
            /*
             */
//            request.getRequestDispatcher("success.jsp").forward(request, response);;
//            response.sendRedirect("success.jsp");
        }else{
            pw.write("login fail");
            /*
             */
//            request.getRequestDispatcher("fail.jsp").forward(request, response);;
//            response.sendRedirect("fail.jsp");
        }
    
    }

}