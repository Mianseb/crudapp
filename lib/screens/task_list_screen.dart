import 'package:crudapp/models/task_model.dart';
import 'package:crudapp/screens/profile_screen.dart';
import 'package:crudapp/screens/sign_in_screen.dart';
import 'package:crudapp/screens/task_add_screen.dart';
import 'package:crudapp/screens/update_task_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  User? user;
  DatabaseReference? taskRef;
  FirebaseAuth auth = FirebaseAuth.instance;


  @override
  void initState() {
    // TODO: implement initState
    user = auth.currentUser;

    if(user!=null){
      String uid = user!.uid;
      taskRef = FirebaseDatabase.instance.ref().child('tasks').child(uid);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: true,
        title: Text('Task Screen'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return ProfileScreen();
              }));
            },
            icon: Icon(Icons.person),
          ),
          IconButton(
            onPressed: (){
              showDialog(
                  barrierDismissible: false,
                  context: context, builder: (context){
                return AlertDialog(
                  title: Text('Confirmation...'),
                  content: Text('Are you sure logout?'),
                  actions: [
                    TextButton(onPressed: (){
                      FirebaseAuth auth = FirebaseAuth.instance;
                      auth.signOut();

                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
                        return SignInPage();

                      }), (route) => false);
                      Fluttertoast.showToast(msg: 'logout successfully');
                    }, child: Text('Yes')),
                    TextButton(onPressed: (){
                      Navigator.of(context).pop();

                    }, child: Text('No'))
                  ],
                );
              });
            },

            icon: Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return TaskAddScreen();
            }));
          });

        },
        child: Icon(Icons.add),
      ),

      body: StreamBuilder(stream: taskRef!.onValue,
        builder: (context,snapshot){
          if(snapshot.hasData && !snapshot.hasError){
            var event= snapshot.data as DatabaseEvent;
            var snapshot2 = event.snapshot.value;
            if(snapshot2==null){
              return Center(child: Text('No Data Added yet'),);
            }
            Map<String,dynamic> map = Map<String,dynamic>.from(snapshot2 as Map);
            var tasks = <TaskModel>[];
            print(tasks.length);
            for(var task in map.values){
              TaskModel taskModel = TaskModel.fromMap(Map<String,dynamic>.from(task));

              tasks.add(taskModel);

            }
            return ListView.builder(
                itemCount:tasks.length ,
                itemBuilder: (context,index){
                  TaskModel task = tasks[index];
                  print(task.taskName.toString());
                  return Container(
                      height: MediaQuery.of(context).size.height*0.178,
                      child: Card(
                        child: Column(
                          children: [
                            Text(getHumanReadableDate(task.dt)),
                            Text(task.taskName),

                            SizedBox(height: 30,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                    return UpdateScreen(taskModel: task);
                                  }));


                                }, icon: Icon(Icons.edit,color: Colors.blue,)),
                                IconButton(onPressed: (){
                                  setState(() {

                                    showDialog(
                                        barrierDismissible: false,
                                        context: context, builder: (context){

                                      return AlertDialog(title: Text('Confirmation!!1'),
                                        content: Text('Are you sure to delete it?'),
                                        actions: [

                                          TextButton(onPressed: (){
                                            Fluttertoast.showToast(msg: 'Deleted');
                                            taskRef!.child(task.taskId).remove();
                                            Navigator.of(context).pop();
                                          }, child: Text('Yes')),

                                          TextButton(onPressed: (){
                                            Navigator.of(context).pop();
                                          }, child: Text('No'))
                                        ],
                                      );
                                    });
                                  });
                                }, icon: Icon(Icons.delete,color:  Colors.red,))
                              ],)
                          ],
                        ),
                      )
                  );
                });

          }

          return Center(child: CircularProgressIndicator(),);

        },
      ),
    );

  }
  String getHumanReadableDate(int dt){
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt);
    return DateFormat('EEEE – kk:mm').format(dateTime);
  }
}