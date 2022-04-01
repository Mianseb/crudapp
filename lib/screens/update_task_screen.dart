import 'package:crudapp/models/task_model.dart';
import 'package:crudapp/screens/task_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class UpdateScreen extends StatefulWidget {
  final TaskModel taskModel;
  UpdateScreen({Key? key, required this.taskModel,}) : super(key: key);


  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  var task = TextEditingController();
  @override
  void initState() {
    task.text =widget.taskModel.taskName;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      title: Text('Update Screen'),
      centerTitle: true,


    ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(child: Column(

            children: [
              TextField(
                controller: task,

                decoration: InputDecoration(

                ),

              ),
              ElevatedButton(onPressed: ()async{
                var uid = FirebaseAuth.instance.currentUser!.uid;
                DatabaseReference taskRef = FirebaseDatabase.instance.ref().child('tasks').child(uid);

                await taskRef.child(widget.taskModel.taskId).update({
                  'taskName': task.text
                });
                Fluttertoast.showToast(msg: 'SuccessFully Updated');
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
                  return TaskListScreen();
                }), (route) => false);


              }, child: Text('Update')),
            ],
          ),),
        )
    );
  }
}