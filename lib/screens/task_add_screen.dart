import 'package:crudapp/screens/task_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class TaskAddScreen extends StatefulWidget {
  const TaskAddScreen({Key? key}) : super(key: key);

  @override
  _TaskAddScreenState createState() => _TaskAddScreenState();
}

class _TaskAddScreenState extends State<TaskAddScreen> {
  var textController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Add Screen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
            child: Column(
              children: [
                Text('Add Your Task',style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
                SizedBox(height: 20,),
                TextField(
                  controller: textController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)

                      ),

                      hintText: 'Add Task'
                  ),
                ),
                ElevatedButton(onPressed: ()async{
                  var taskName = textController.text.trim();
                  var uid = FirebaseAuth.instance.currentUser!.uid;
                  var dt = DateTime.now().millisecondsSinceEpoch;
                  var userRef = FirebaseDatabase.instance.ref().child('tasks').child(uid);
                  var taskId = userRef.push().key;
                  Map<String,dynamic> taskInfo ={
                    'taskName':taskName,
                    'dt' :dt,
                    'taskId' : taskId,


                  };
                  print(taskInfo.toString());
                  userRef.child(taskId!).set(taskInfo);
                  Fluttertoast.showToast(msg: 'Task Added');
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
                    return TaskListScreen();

                  }), (route) => false);


                }, child: Text('Submit')),
              ],
            )
        ),
      ) ,
    );
  }
}