import "dart:io"; // Like FileSystem in Node.js
import 'dart:convert';
import 'dart:math'; // it necessary to serialize JSON files
import '../utils/generateId.dart';
import '../utils/normalizeStrings.dart';
import '../utils/validateDate.dart';

// The deadline argument should not be mandatory, but this was needed in first
// instance, because the "arguments" does not accept null arguments, triggering
// an error... the value "no-date" fulfils the deadline field with: ""(empty string).
void main(List<String> arguments) {
  Application app = Application(arguments);

  app.executeProgram();
}

class Application {
  final List<String> arguments;
  late Object operation;

  Application(this.arguments);

  void executeProgram() {
    try {
      switch (arguments[0]) {
        case "add":
          AddTask operation = AddTask(arguments[1], arguments[2], arguments[3]);
          operation.addTask();
        case "delete":
          DeleteTask operation = DeleteTask(
            arguments[1],
            int.parse(arguments[2]),
          );
          operation.deleteTask();
        case "deadline":
          AddDeadline instance = AddDeadline(
            arguments[1],
            arguments[2],
            arguments[3],
          );

          instance.addDealine();
        default:
          throw "None correspondent operation";
      }
      ;
    } catch (err, stack) {
      throw "❗❗❗ An error ocurried: ➡️ $err ➡️ $stack";
    }
  }
}

class AddTask {
  final String listName;
  final String ItemName;
  final String itemDeadline;

  AddTask(this.listName, this.ItemName, this.itemDeadline);

  void addTask() async {
    try {
      final String jsonListName = normalizeStrings('$listName');
      final File list = File('./lists/${jsonListName}.json');

      if (list.existsSync()) {
        final String fileContent = await list.readAsString();
        final List<dynamic> fileContentDecoded = jsonDecode(fileContent);
        final List idList =
            fileContentDecoded.map((item) => item["id"]).toList();
        final int maxId = idList.reduce((prev, next) => max(prev, next));

        final DateTime taskBirth = DateTime.now();

        final Map<String, dynamic> taskContent = {
          "name": ItemName,
          "id": generateTaskId(maxId),
          "createdAt": "${taskBirth.year}-${taskBirth.month}-${taskBirth.day}",
          "deadline": getDate(itemDeadline),
        };

        fileContentDecoded.add(taskContent);

        final String encodedContent = jsonEncode(fileContentDecoded);
        await list.writeAsString(encodedContent);

        // make sure you do not confuse "jsonDecode" with "JsonDecoder" again...
      } else {
        CreateList? newList = CreateList(listName);

        await newList.createList();

        final String fileContent = await list.readAsString(encoding: utf8);
        final List<dynamic> fileContentDecoded = jsonDecode(fileContent);

        final DateTime taskBirth = DateTime.now();

        final Map<String, dynamic> taskContent = {
          "name": ItemName,
          "id": 1,
          "createdAt": "${taskBirth.year}-${taskBirth.month}-${taskBirth.day}",
          "deadline": getDate(itemDeadline),
        };

        fileContentDecoded.add(taskContent);

        final encodedContent = jsonEncode(fileContentDecoded);

        await list.writeAsString(encodedContent);
      }
    } catch (exception, stack) {
      print("An error occurent: $exception in the stack: $stack");
    }
  }
}

class DeleteTask {
  final String listName;
  final int taskId;

  DeleteTask(this.listName, this.taskId);

  void deleteTask() async {
    try {
      final File file = File(
        './lists/${normalizeStrings(listName)}.json',
      );

      if (file.existsSync()) {
        final String fileContent = await file.readAsString();
        final List<dynamic> decodedContent = jsonDecode(fileContent);
        final List<dynamic> newList =
            decodedContent.where((item) {
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

class AddDeadline {
  final String fileName;
  final String itemId;
  final String itemDeadline;

  AddDeadline(this.fileName, this.itemDeadline, this.itemId);

  void addDealine() async {
    try {
      File file = File('./lists/$fileName.json');

      final String source = await file.readAsString();
      final List<dynamic> decodedSource = json.decode(source);

      final List<dynamic> updatedList =
          decodedSource.map((item) {
            if (item["id"] == num.parse(itemId)) {
              item["deadline"] = getDate(itemDeadline);
              return item;
            }
            ;

            return item;
          }).toList();

      await file.writeAsString(jsonEncode(updatedList));
    } catch (err, stack) {
      throw "An error ocurried: $err, $stack";
    }
  }
}

class CreateList {
  final String listName;

  CreateList(this.listName);

  Future createList() async {
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
