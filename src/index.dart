import "dart:io"; // Like FileSystem in Node.js
void main(List<String> arguments) {
  Application app = new Application(arguments);

  app.executeProgram();
} 

class Application {

  final List<String> arguments;
  late Object operation;

  Application(this.arguments);

  void executeProgram() {

    switch(arguments[0]) {
      case "add": 
        AddTask operation = AddTask(arguments[1], arguments[2]);
        operation.HandleAddTask();
      default: 
        throw "None correspondent operation";
    };
  }
}

class AddTask {
  final String listName; 
  final String ItemName;

  AddTask(this.listName, this.ItemName);

  void HandleAddTask() async {
    final File list = File('./lists/${listName}.json');

    if(list.existsSync()) {
      list.writeAsString('$ItemName', mode: FileMode.append);
      print('I am writting in the file!');
    } else {
      CreateList? newList = new CreateList(listName);
      print('I am creating and writting in the file!');

      newList.HandleCreateList();

      await list.writeAsString('$ItemName', mode: FileMode.append);
    }
  }
}

class DeleteTask {

}

class AddDeadline {

}

class CreateList {
  final String listName; 

  CreateList(this.listName);

  void HandleCreateList() async {
    File list = File('./lists/${this.listName}.json');

    await list.create();

    print('list: ${list.path} was created successfuly!');
  }
}