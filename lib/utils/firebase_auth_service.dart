import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ฟังก์ชันสมัครสมาชิก
  Future<String?> registerUser(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // บันทึกข้อมูลผู้ใช้ลง Firestore
      await _db.collection('User').doc(userCredential.user!.uid).set({
        'display_name': name,
        'email': email,
        'profile_image': '', // สามารถเพิ่มระบบอัปโหลดรูปโปรไฟล์ภายหลังได้
      });

      return null; // สำเร็จ ไม่มี error
    } catch (e) {
      return e.toString();
    }
  }

  // ฟังก์ชันเข้าสู่ระบบ
  Future<String?> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // เช็คว่ามีผู้ใช้ล็อกอินอยู่หรือไม่
  User? get currentUser => _auth.currentUser;
}
