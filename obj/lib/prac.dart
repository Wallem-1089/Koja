void main() {
  User userOne = User('luigi', 25);
  print(userOne.username);
  userOne.login();

  User userTwo = User("Mario", 13);
  print(userTwo.username);

  SuperUser userThree = SuperUser("walter", 19);
  print(userThree.age);
  userThree.publish();
}

class User{
  var username;
  var age;
  //construtor function
  User(String u, int a){
    username = u;
    age = a;
  }

  void login() {
    print("user logged in");
  }
}

class SuperUser extends User {
  SuperUser(super.username, super.age);

  void publish() {
    print("The info has been published");
  }
}