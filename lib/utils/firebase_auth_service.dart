import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ฟังก์ชันสมัครสมาชิก
  Future<String?> registerUser(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // บันทึกข้อมูลผู้ใช้ลง Firestore
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'display_name': name,
        'email': email,
        'is_banned': false,
        'is_admin': false,
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

  // ฟังก์ชันเข้าสู่ระบบด้วย Google
  Future<String?> signInWithGoogle() async {
    try {
      // เริ่มการล็อกอินด้วย Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // ถ้าผู้ใช้ยกเลิกการล็อกอิน
      if (googleUser == null) {
        return "การเข้าสู่ระบบถูกยกเลิก";
      }

      // รับข้อมูลการตรวจสอบจาก Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // สร้าง credential สำหรับ Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // เข้าสู่ระบบ Firebase ด้วย Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // ตรวจสอบว่ามีข้อมูลผู้ใช้ใน Firestore หรือไม่
        final userDoc = await _db.collection('users').doc(user.uid).get();

        // ถ้าไม่มีข้อมูลให้สร้างใหม่
        if (!userDoc.exists) {
          await _db.collection('users').doc(user.uid).set({
            'display_name': user.displayName ?? "ผู้ใช้ Google",
            'email': user.email ?? "",
            'is_banned': false,
            'is_admin': false,
            'profile_image': user.photoURL ?? '',
            'provider': 'google',
          });
        }

        return null; // สำเร็จ
      } else {
        return "ไม่สามารถเข้าสู่ระบบได้";
      }
    } catch (e) {
      return e.toString();
    }
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> logoutUser() async {
    await _googleSignIn.signOut(); // ออกจากระบบ Google ด้วย
    await _auth.signOut();
  }

  // เช็คว่ามีผู้ใช้ล็อกอินอยู่หรือไม่
  User? get currentUser => _auth.currentUser;
}