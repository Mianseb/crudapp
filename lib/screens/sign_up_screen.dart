import 'package:crudapp/screens/task_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  bool passSecure = false;
  var passwordController = TextEditingController();
  var confirmpassController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText:passSecure ,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),

                ),
              ),
              TextField(
                controller: confirmpassController,
                obscureText:passSecure ,
                decoration: InputDecoration(
                  hintText: 'Confirm password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(onPressed: (){
                    setState(() {
                      passSecure = !passSecure;
                    });
                  },
                    icon:passSecure? Icon(Icons.visibility_off) : Icon(Icons.visibility),),
                ),
              ),
              ElevatedButton(
                onPressed: ()async{
                  String name = nameController.text;
                  String email = emailController.text;
                  String password = passwordController.text;
                  String confirmPassword = confirmpassController.text;
                  if(name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                  {
                    Fluttertoast.showToast(msg: 'Provide all fields');
                    return ;
                  }
                  if(password !=confirmPassword)
                  {
                    Fluttertoast.showToast(msg: 'password not match');
                    return;
                  }
                  ProgressDialog progresDialog = ProgressDialog(context, title: Text('Signing Up'), message: Text('Please wait..'));
                  progresDialog.show();





                  try
                  {

                    UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);



                    if(userCredential != null)
                    {


                      String uid = userCredential.user!.uid;
                      int dt =DateTime.now().millisecondsSinceEpoch;
                      await userRef.child(uid).set({
                        'name' : name,
                        'email' : email,
                        'dt' :dt,
                        'uid': uid,
                        'profileImage': '',

                      });
                      Fluttertoast.showToast(msg: 'Success');


                    }

                  }
                  on FirebaseAuthException catch(e)
                  {
                    Fluttertoast.showToast(msg: e.message!);
                    progresDialog.dismiss();
                    return ;
                  }
                  progresDialog.dismiss();
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
                    return TaskListScreen();
                  }), (route) => false);
                },
                child: Text('Sign Up'),
              )
            ],
          ),
        ),
      ),
    );
  }
}