
import 'dart:io';

import 'package:crudapp/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() =>  _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userModel;
  DatabaseReference? userRef;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  File? imageFile;
  bool showLocalFile = false;

  _pickImageFromGallery(ImageSource source) async {
    XFile? xFile = await ImagePicker().pickImage(source: source);

    if (xFile == null) return;

    final tempImage = File(xFile.path);

    imageFile = tempImage;
    showLocalFile = true;
    setState(() {

    });
    //Firebase Upload Code
    ProgressDialog progressDialog = ProgressDialog(
        context, title :Text('Uploading..') ,message: Text('Please wait..')
    );
    progressDialog.show();
    try {
      var fileName = userModel!.email + '.jpg';

      UploadTask uploadTask = FirebaseStorage.instance.ref().child('profile_images').child(fileName).putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;

      String profileImageUrl = await snapshot.ref.getDownloadURL();

      print(profileImageUrl);
      DatabaseReference  userRef = FirebaseDatabase.instance.ref().child('users').child(userModel!.uid);
      await userRef.update({
        'profileImage' : profileImageUrl,
      });
      Fluttertoast.showToast(msg: 'Successfully Uploaded');

      progressDialog.dismiss();


    }catch(e){
      progressDialog.dismiss();
    }
  }
  getUserDetail() async {

    DatabaseEvent event = await userRef!.once();

    DataSnapshot snapshot = event.snapshot;

    if( !snapshot.exists){

    }
    Map map = snapshot.value as Map;



    userModel = UserModel.fromMap(Map<String, dynamic>.from(map));

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;
    if (user != null) {

      userRef=FirebaseDatabase.instance.ref().child('users').child(user!.uid);

      getUserDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),

      body:userModel == null?null:

      Padding(padding: EdgeInsets.all(10.0),
        child: SizedBox(
          width: double.infinity,
          height: 600,
          child: Stack(
            children: [ Column(

              children :[
                Center(
                  child: CircleAvatar(

                    maxRadius: 80,
                    backgroundImage:showLocalFile ?

                    FileImage(imageFile!) as ImageProvider
                        :

                    userModel!.profileImage == ''
                        ? const NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGrQoGh518HulzrSYOTee8UO517D_j6h4AYQ&usqp=CAU')
                        : NetworkImage(userModel!.profileImage)
                  ),
                ),
                Card(child: Text('Name  ${userModel!.name}')),

                Card(child: Text('Email  ${userModel!.email}')),
                Card(child: Text('Since  ${getUserTime(userModel!.dt!)}')),
              ],
            ),
              Positioned(
                  left: 70,
                  right: 70,
                  top: 70,
                  child: IconButton(
                onPressed: (){

                  showModalBottomSheet(context: context, builder: (context){

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: ()async{
                            _pickImageFromGallery(ImageSource.camera);
                          Navigator.of(context).pop();
                          },
                          child: ListTile(
                            leading: Icon(Icons.camera_alt),
                            title: Text('With Camera'),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            _pickImageFromGallery(ImageSource.gallery);

                            Navigator.of(context).pop();
                          },
                          child: ListTile(
                            leading: Icon(Icons.storage),
                            title: Text('From Gallery'),
                          ),
                        ),

                      ],
                    );
                  });
                },icon:  Icon(Icons.camera_alt,size: 30,),
              ))
            ]
          ),
        ),
      ),

    );

  }
  String getUserTime(int dt){
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt);
    return DateFormat('EEE - kk -- mm').format(dateTime);
  }
}
