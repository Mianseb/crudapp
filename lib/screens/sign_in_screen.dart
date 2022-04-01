import 'package:crudapp/screens/sign_up_screen.dart';
import 'package:crudapp/screens/task_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var emailController = TextEditingController();
  bool passSecure = true;
  var passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('School Finder'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Stack(

          clipBehavior: Clip.none,
          children:[ Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Column(

                children: [
                  Positioned(

                    height: MediaQuery.of(context).size.height*.2,
                    width: MediaQuery.of(context).size.width*.4,

                    child: Container(


                      width: MediaQuery.of(context).size.width*.9,
                      height: MediaQuery.of(context).size.height*.3,

                      clipBehavior: Clip.none,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),

                          image: DecorationImage(

                            fit: BoxFit.cover,
                            image: AssetImage('assets/images/school.PNG'),
                          )

                      ),
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
                    controller: passController,
                    obscureText:passSecure ,
                    decoration: InputDecoration(
                      hintText: 'Password',
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
                      //Firebase code
                      String email = emailController.text;
                      String password = passController.text;
                      if(email.isEmpty || password.isEmpty)
                      {
                        Fluttertoast.showToast(msg: 'Provide all fields');
                        return ;
                      }
                      ProgressDialog progressDialog = ProgressDialog(context, title: Text('Signing In'), message: Text('Please wait..'));
                      progressDialog.show();

                      try{
                        FirebaseAuth auth = FirebaseAuth.instance;
                        UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
                        if(userCredential !=null)
                        {
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
                            return TaskListScreen();
                          }), (route) => false);
                          Fluttertoast.showToast(msg: 'Success');






                        }

                      }on FirebaseAuthException catch(e)
                      {
                        Fluttertoast.showToast(msg: e.message!);
                        progressDialog.dismiss();
                        return;
                      }



                    },
                    child: Text('Sign In'),
                  ),

                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Not registered yet?'),
                      GestureDetector(onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return SignUpPage();

                        }));
                      },child: Text('Register now',style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)),
                    ],
                  )
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
