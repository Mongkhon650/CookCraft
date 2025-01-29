import 'package:flutter/material.dart';
import 'package:cookcraft/utils/firebase_auth_service.dart';
import 'package:cookcraft/Page/auth/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void login() async {
    String? error = await _authService.loginUser(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (error == null) {
      // สำเร็จ -> ไปหน้าหลัก
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // แสดงข้อความผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('เข้าสู่ระบบ')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'อีเมล'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'รหัสผ่าน'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text('เข้าสู่ระบบ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: Text('ยังไม่มีบัญชี? สมัครสมาชิกที่นี่'),
            ),
          ],
        ),
      ),
    );
  }
}
