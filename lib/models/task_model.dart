class TaskModel {
  late String taskName;
  late String taskId;
  late int dt;


  TaskModel({
    required this.taskName,
    required this.taskId,
    required this.dt,

  });

  factory TaskModel.fromMap(Map<String,dynamic>map){
    return TaskModel(taskName: map['taskName'], taskId: map['taskId'], dt: map['dt'],);
  }
}
