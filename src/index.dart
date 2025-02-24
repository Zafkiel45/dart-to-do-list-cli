import "dart:io"; // Like FileSystem in Node.js
import 'dart:convert'; // it necessary to serialize JSON files

void main(List<String> arguments) {
  Application app = new Application(arguments);

  app.executeProgram();
}

mixin NormalizeStrings {
  String HandleNormalizeStrings(String string) {
    return string.toLowerCase();
  }
}

class Application {
  final List<String> arguments;
  late Object operation;

  Application(this.arguments);

  void executeProgram() {
    switch (arguments[0]) {
      case "add":
        AddTask operation = AddTask(arguments[1], arguments[2]);
        operation.HandleAddTask();
      default:
        throw "None correspondent operation";
    }
    ;
  }
}

class AddTask with NormalizeStrings {
  final String listName;
  final String ItemName;

  AddTask(this.listName, this.ItemName);
  //
  void HandleAddTask() async {
    try {
      final String jsonListName = HandleNormalizeStrings('$listName');
      final File list = File('./lists/${jsonListName}.json');

      if (list.existsSync()) {
        final String fileContent = await list.readAsString();
        final List fileContentDecoded = jsonDecode(fileContent);
        final Map<String, dynamic> taskContent = {"name": ItemName};

        fileContentDecoded.add(taskContent);

        final encodedContent = jsonEncode(fileContentDecoded);
        await list.writeAsString(encodedContent);

        // make sure you do not confuse "jsonDecode" with "JsonDecoder" again...
      } else {
        CreateList? newList = new CreateList(listName);

        await newList.HandleCreateList();

        final String fileContent = await list.readAsString(encoding: utf8);
        final List fileContentDecoded = jsonDecode(fileContent);
        final Map<String, dynamic> taskContent = {"name": ItemName};

        fileContentDecoded.add(taskContent);

        final encodedContent = jsonEncode(fileContentDecoded);

        await list.writeAsString(encodedContent);
      }
    } catch (exception, stack) {
      print("An error occurent: $exception in the stack: $stack");
    }
  }
}

class DeleteTask {}

class AddDeadline {}

class CreateList {
  final String listName;

  CreateList(this.listName);

  Future HandleCreateList() async {
    try {
      final File list = File('./lists/${this.listName}.json');
      final String defaultListValue = jsonEncode([]);

      await list.create();
      await list.writeAsString(defaultListValue);

      print('list: ${list.path} was created successfuly!');
    } catch (exception, stack) {
      print("An error occurent: $exception in the stack: $stack");
    }
  }
}
