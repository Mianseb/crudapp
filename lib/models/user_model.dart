class UserModel {

  int? dt;
  late String uid;
  late String email;
  late String name;
  late String profileImage;

  UserModel(
      { required this.uid, required this.dt, required this.name, required this.email, required this.profileImage});

  UserModel.fromMap(Map<String,dynamic>map){

    uid= map['uid'];
    dt= map['dt'];
    name= map['name'];
    email= map['email'];
    profileImage= map['profileImage'];
  }

}