import 'package:flutter/material.dart';
import 'package:cookcraft/utils/firebase_auth_service.dart';
import 'package:cookcraft/Page/auth/register.dart';
import 'package:cookcraft/Page/profilePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  void login() async {
    setState(() {
      _isLoading = true;
    });

    String? error = await _authService.loginUser(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  void googleLogin() async {
    setState(() {
      _isGoogleLoading = true;
    });

    String? error = await _authService.signInWithGoogle();

    setState(() {
      _isGoogleLoading = false;
    });

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(''),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 10),
            Text(
              'เข้าสู่ระบบ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'อีเมล',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("หรือ", style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isGoogleLoading ? null : googleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                elevation: 1,
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isGoogleLoading
                  ? CircularProgressIndicator()
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/google_logo.png',
                    height: 24,
                    width: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'เข้าสู่ระบบด้วย Google',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: Text('ลืมรหัสผ่าน?', style: TextStyle(fontSize: 14, color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('ยังไม่มีบัญชี? สมัครสมาชิกเลย', style: TextStyle(fontSize: 14, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}