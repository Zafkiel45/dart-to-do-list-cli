import "dart:io";
import 'dart:convert';
import 'dart:math';
import '../utils/fileExists.dart';
import '../utils/generateId.dart';
import '../utils/normalizeStrings.dart';
import '../utils/validateDate.dart';

void main(List<String> arguments) {
  Application app = Application(arguments);

  app.executeProgram();
}

class Application {
  final List<String> arguments;
  late final Object operation;

  Application(this.arguments);

  void executeProgram() {
    try {
      switch (arguments[0]) {
        case "add":
          AddTask(arguments[1], arguments[2], arguments[3]).addTask();
        case "delete":
          DeleteTask(arguments[1], int.parse(arguments[2])).deleteTask();
        case "deadline":
          AddDeadline(arguments[1], arguments[2], arguments[3]).addDealine();
        default:
          print("❌ Invalid operation");
      }
      ;
    } catch (err, stack) {
      print("❗ Error: $err\nStack trace:\n$stack");
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

      if (await fileExists(list)) {
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
    } catch (err, stack) {
      print("❌ $err \n ❌ $stack");
    }
  }
}

class DeleteTask {
  final String listName;
  final int taskId;

  DeleteTask(this.listName, this.taskId);

  void deleteTask() async {
    try {
      final File file = File('./lists/${normalizeStrings(listName)}.json');

      if (await fileExists(file)) {
        final String fileContent = await file.readAsString();
        final List<dynamic> decodedContent = jsonDecode(fileContent);
        final List<dynamic> newList =
            decodedContent.where((item) {
              return item["id"] != taskId;
            }).toList();
        final sourceEncoded = jsonEncode(newList);
        await file.writeAsString(sourceEncoded);

        print('item deleted succesfully!');
      } else {
        print("❌ File not found!");
        return;
      }
    } catch (err, stack) {
      throw '❌ $err\n ❌ $stack';
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
      throw "❌ $err \n ❌ $stack";
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
    } catch (err, stack) {
      print("❌ $err\n ❌ $stack");
    }
  }
}
