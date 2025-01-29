import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({Key? key}) : super(key: key);

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController servingController = TextEditingController(text: "1 คน");
  final TextEditingController timeController = TextEditingController(text: "30 นาที");

  List<TextEditingController> ingredientControllers = [];
  List<TextEditingController> stepControllers = [];
  List<XFile?> stepImages = [];

  XFile? recipeImage;

  @override
  void initState() {
    super.initState();
    ingredientControllers.add(TextEditingController(text: "ไข่ไก่ 3 ฟอง"));
    ingredientControllers.add(TextEditingController(text: "ข้าว 250 กรัม"));
    stepControllers.add(TextEditingController(text: "นำกระเทียมมาสับให้ละเอียด"));
    stepImages.add(null); // รูปของขั้นตอนแรก
  }

  // ฟังก์ชันเลือกรูปอาหาร
  Future<void> pickRecipeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        recipeImage = image;
      });
    }
  }

  // ฟังก์ชันเลือกรูปของแต่ละขั้นตอน
  Future<void> pickStepImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        stepImages[index] = image;
      });
    }
  }

  void addIngredient() {
    setState(() {
      ingredientControllers.add(TextEditingController());
    });
  }

  void addStep() {
    setState(() {
      stepControllers.add(TextEditingController());
      stepImages.add(null); // เพิ่มตัวเก็บรูปของขั้นตอนใหม่
    });
  }

  void removeIngredient(int index) {
    setState(() {
      ingredientControllers.removeAt(index);
    });
  }

  void removeStep(int index) {
    setState(() {
      stepControllers.removeAt(index);
      stepImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement save recipe functionality
            },
            child: const Text("บันทึก", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement upload functionality
            },
            child: const Text("โพสต์", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพอาหาร
            GestureDetector(
              onTap: pickRecipeImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: recipeImage == null
                    ? const Center(
                  child: Text("📷 ใส่รูปอาหารที่ทำเสร็จ", style: TextStyle(color: Colors.black54)),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(recipeImage!.path), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ชื่อสูตร
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "ชื่อสูตร", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            // จำนวนเสิร์ฟและเวลา
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: servingController,
                    decoration: const InputDecoration(labelText: "สำหรับ", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: "เวลาที่ใช้", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ส่วนผสม
            const Text("ส่วนผสม", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Column(
              children: List.generate(ingredientControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ingredientControllers[index],
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeIngredient(index),
                      ),
                    ],
                  ),
                );
              }),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: addIngredient,
                child: const Text("+ เพิ่มส่วนผสม"),
              ),
            ),
            const SizedBox(height: 20),

            // วิธีทำ
            const Text("วิธีทำ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Column(
              children: List.generate(stepControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // จัดให้อยู่ด้านบน
                    children: [
                      // ช่องป้อนข้อความ (อยู่ด้านบน)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stepControllers[index],
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                            ),
                          ),
                          // ปุ่มลบ
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeStep(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10), // ระยะห่างระหว่างช่องข้อความกับปุ่มเลือกภาพ

                      // ปุ่มเลือกภาพขั้นตอน (อยู่ด้านล่าง)
                      GestureDetector(
                        onTap: () => pickStepImage(index),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: stepImages[index] == null
                              ? const Icon(Icons.camera_alt, size: 40, color: Colors.black54)
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(stepImages[index]!.path), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // เพิ่มระยะห่าง
                    ],
                  ),
                );
              }),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: addStep,
                child: const Text("+ เพิ่มขั้นตอน"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
