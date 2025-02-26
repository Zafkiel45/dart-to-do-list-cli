import "dart:io"; // Like FileSystem in Node.js
import 'dart:convert';
import 'dart:math'; // it necessary to serialize JSON files

void main(List<String> arguments) {
  Application app = new Application(arguments);

  app.executeProgram();
}

mixin NormalizeStrings {
  String HandleNormalizeStrings(String string) {
    return string.toLowerCase();
  }
}

mixin GenerateTaskId {
  int HandleGenerateId(List<dynamic> list) {
    // STUDY NOTES =============================================================
    // Unfortunatelly, I was tricked! in Dart, the arrow notation is used only
    // in single expression or statements, differently from JavaScript!
    // If I write () => {}, it is as return a Set<T>! Only brances is necessary
    // in anonymous functions.
    // STUDY NOTES =============================================================

    // to read more about "toList()" method!
    final List<int> idList = list.map<int>((id) => id["id"]).toList();

    final int id = idList.reduce((value, element) {
      if (value.isNaN) value = 1;

      return max(value, element) + 1;
    });

    return id;
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
      case "delete":
        DeleteTask operation = DeleteTask(arguments[1], int.parse(arguments[2]));
        operation.HandleDeleteTask();
      default:
        throw "None correspondent operation";
    }
    ;
  }
}

class AddTask with NormalizeStrings, GenerateTaskId {
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
        final List<dynamic> fileContentDecoded = jsonDecode(fileContent);
        final Map<String, dynamic> taskContent = {
          "name": ItemName,
          "id": HandleGenerateId(fileContentDecoded),
        };

        fileContentDecoded.add(taskContent);

        final String encodedContent = jsonEncode(fileContentDecoded);
        await list.writeAsString(encodedContent);

        // make sure you do not confuse "jsonDecode" with "JsonDecoder" again...
      } else {
        CreateList? newList = new CreateList(listName);

        await newList.HandleCreateList();

        final String fileContent = await list.readAsString(encoding: utf8);
        final List<dynamic> fileContentDecoded = jsonDecode(fileContent);
        final Map<String, dynamic> taskContent = {"name": ItemName, "id": 0};

        fileContentDecoded.add(taskContent);

        final encodedContent = jsonEncode(fileContentDecoded);

        await list.writeAsString(encodedContent);
      }
    } catch (exception, stack) {
      print("An error occurent: $exception in the stack: $stack");
    }
  }
}

class DeleteTask with NormalizeStrings {
  final String listName;
  final int taskId; 

  DeleteTask(this.listName, this.taskId);

  void HandleDeleteTask() async {
    try {
      final File file = File('./lists/${HandleNormalizeStrings(listName)}.json');

      if (file.existsSync()) {
        final String fileContent = await file.readAsString();
        final List<dynamic> decodedContent = jsonDecode(fileContent);
        final List<dynamic> newList = decodedContent.where((item) {
          return item["id"] != taskId;
        }).toList();
        final sourceEncoded = jsonEncode(newList);
        await file.writeAsString(sourceEncoded);

        print('item deleted succesfully!');
      }
    } catch (err, stack) {
      throw 'An error ocurred: $err. The stack: $stack';
    }
  }
}

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
