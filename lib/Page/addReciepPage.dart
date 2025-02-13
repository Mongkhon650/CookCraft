import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({Key? key}) : super(key: key);

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController servingController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  List<Map<String, TextEditingController>> ingredientControllers = [];
  List<TextEditingController> stepControllers = [];
  List<XFile?> stepImages = [];

  XFile? recipeImage;

  @override
  void initState() {
    super.initState();
    addIngredient();
    stepControllers.add(TextEditingController());
    stepImages.add(null);
  }

  Future<void> pickRecipeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        recipeImage = image;
      });
    }
  }

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
      ingredientControllers.add({
        'name': TextEditingController(),
        'amount': TextEditingController(),
        'unit': TextEditingController(),
      });
    });
  }

  void addStep() {
    setState(() {
      stepControllers.add(TextEditingController());
      stepImages.add(null);
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

  Future<String?> uploadImage(XFile? image) async {
    if (image == null) return null;
    final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
    await storageRef.putFile(File(image.path));
    return await storageRef.getDownloadURL();
  }

  Future<void> saveRecipe({bool publish = false}) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final recipeImageUrl = await uploadImage(recipeImage);
    final stepImageUrls = await Future.wait(stepImages.map((image) => uploadImage(image)));

    final recipeRef = await firestore.collection('recipes').add({
      'name': nameController.text,
      'serving': servingController.text,
      'prep_time': timeController.text,
      'image_url': recipeImageUrl ?? '',
      'user_id': 'user_id_1',
      'published': publish,
    });

    for (int i = 0; i < ingredientControllers.length; i++) {
      await firestore.collection('ingredients').add({
        'name': ingredientControllers[i]['name']!.text,
        'quantity': {
          'amount': int.tryParse(ingredientControllers[i]['amount']!.text) ?? 0,
          'unit': ingredientControllers[i]['unit']!.text,
        },
        'recipe_id': recipeRef.id,
      });
    }

    for (int i = 0; i < stepControllers.length; i++) {
      await firestore.collection('steps').add({
        'description': stepControllers[i].text,
        'image_url': stepImageUrls[i] ?? '',
        'recipe_id': recipeRef.id,
        'step_number': i + 1,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(publish ? 'สูตรอาหารถูกโพสต์เรียบร้อยแล้ว' : 'สูตรอาหารถูกบันทึกเรียบร้อยแล้ว')),
    );
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
            onPressed: () => saveRecipe(publish: false),
            child: const Text("บันทึก", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => saveRecipe(publish: true),
            child: const Text("โพสต์", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "ชื่อสูตร", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("สำหรับ"),
                      TextField(
                        controller: servingController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "1 คน",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("เวลาที่ใช้"),
                      TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "30 นาที",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("ส่วนผสม", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Column(
              children: List.generate(ingredientControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: ingredientControllers[index]['name'],
                        decoration: const InputDecoration(
                          labelText: "ชื่อส่วนผสม",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ingredientControllers[index]['amount'],
                              decoration: const InputDecoration(
                                labelText: "จำนวน",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: ingredientControllers[index]['unit'],
                              decoration: const InputDecoration(
                                labelText: "หน่วย",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeIngredient(index),
                          ),
                        ],
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
            const Text("วิธีทำ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Column(
              children: List.generate(stepControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stepControllers[index],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "เพิ่มขั้นตอน เช่น ตั้งกระทะแล้วใส่น้ำมัน",
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeStep(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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