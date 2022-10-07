

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';

const List<String> list = <String>['Appetizers', 'Beef', 'Chicken', 'Desserts','Drinks','Pastries','Sea Food','Sauces','Salads','Vegetables'];


Future  main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const  DropdownButtonApp());
}

class DropdownButtonApp extends StatelessWidget {
  const DropdownButtonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.red,title: const Center(child: Text('Add New Recipe',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),))),
        body: const Center(
          child: DropdownButtonExample(),
        )

      ),
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list.first;
  var recipeNameController = TextEditingController();
  var recipeDescriptionController = TextEditingController();
  String recipeImage = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqtIJmmt6csVgTG36MocRoy02meZWqrLOiIQ&usqp=CAU";

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [

                ListTile(
                  title: const Text("Choose The category "),
                  trailing: DropdownButtonHideUnderline(child: DropdownButton<String>(



                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down_rounded,color: Colors.red,),
                    elevation: 16,
                    style: const TextStyle(color: Colors.red),
                    underline: Container(
                      height: 2,
                      color: Colors.red,
                    ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),),
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  validator: (value){
                    if(value!.isEmpty){
                      return "enter recipe name";
                    }
                  },
                  controller: recipeNameController,
                  decoration: const InputDecoration(
                      border:OutlineInputBorder(),
                    labelText: "Recipe Name"
                  ),
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,



                  validator: (value){
                    if(value!.isEmpty){
                      return"enter recipe description";
                    }
                  },
                  controller: recipeDescriptionController,
                  decoration: const InputDecoration(
                      border:OutlineInputBorder(),
                    labelText: "Recipe Description"
                  ),
                ),
                const SizedBox(height: 10,),

                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        onTap: (){
                          addImage();
                        },
                        child: Image.network("$recipeImage",height: 200,width: 200,),
                            ),
                    ),
                    const Text("Add recipe image")


                  ],
                ),
                const SizedBox(height: 10,),

                Row(
                  children: [
                    Expanded(

                      child: ElevatedButton(

                          onPressed: () {
                       if(_formKey.currentState!.validate()){
                         addRecipe();
                         print(dropdownValue);
                         recipeNameController.clear();
                         recipeDescriptionController.clear();
                         
                       }

                      }, child: const Text("Add Recipe",)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  void addRecipe()async {
    String recipeName = recipeNameController.text.trim();
    String descriptionController = recipeDescriptionController.text.trim();
    await FirebaseFirestore.instance.collection("Categories").doc(dropdownValue).collection(dropdownValue).doc(recipeName).set({

      "name" :recipeName ,
      "description": descriptionController,
      'image' : recipeImage,

    });

}
  File? file;
  void addImage() async{
  final ImagePicker _picker = ImagePicker();
  // Pick an image
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  file = File(image!.path);
  uploadImage(file!);

}

void uploadImage(File file) {
    String ref = "recipes images/${DateTime.now().millisecondsSinceEpoch}";
    FirebaseStorage.instance.ref(ref).putFile(file)
        .then((p0) {
          getImageUrl(ref);
    }).catchError((error){
      print(error.toString());
    });
}

void getImageUrl(String ref) async{
    recipeImage = await FirebaseStorage.instance.ref(ref).getDownloadURL();
    setState(() {

    });

}

}

