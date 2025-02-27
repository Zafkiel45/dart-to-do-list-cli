import "dart:io";
import 'dart:convert';
import 'dart:math';
import '../utils/fileExists.dart';
import '../utils/generateId.dart';
import '../utils/getOrCreateFile.dart';
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
        case "show":
          ShowList(arguments[1]).list();
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
      final File list = await getOrCreateFile('./lists/${jsonListName}.json');

      final List<dynamic> fileContent = jsonDecode(await list.readAsString());
      final List idList = fileContent.map((item) => item["id"]).toList();
      final int maxId =
          idList.isEmpty ? 0 : idList.reduce((prev, next) => max(prev, next));

      final DateTime taskBirth = DateTime.now();

      final Map<String, dynamic> taskContent = {
        "name": ItemName,
        "id": generateTaskId(maxId),
        "createdAt": "${taskBirth.year}-${taskBirth.month}-${taskBirth.day}",
        "deadline": getDate(itemDeadline),
      };

      fileContent.add(taskContent);

      final String encodedContent = jsonEncode(fileContent);
      await list.writeAsString(encodedContent);

      print("✅ Task added successfully!");
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

class ShowList {
  final String listName;

  ShowList(this.listName);
  void list() async {
    final File file = File('./lists/$listName.json');

    try {
      if (await fileExists(file)) {
        final List<dynamic> fileContent = jsonDecode(await file.readAsString());

        const List<String> listHeader = ['name', 'id', 'createdAt', 'deadline'];

        String header = '';
        String line = '';

        for (String item in listHeader) {
          header += item.padRight(25) + "|";
        }
        ;

        for (Map<String, dynamic> item in fileContent) {
          List<String> fields = ['name', 'id', 'createdAt', 'deadline'];

          for (String field in fields) {
            line += (item["$field"].toString()).padRight(25) + "|";
          }
          ;

          line += "\n";
        }

        print(header);
        print(line);
      }
    } catch (err, stack) {
      print('❌ $err \n ❌ $stack');
    }
  }
}
