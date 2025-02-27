String getDate(String date) {
  try {
    final RegExp pattern = RegExp(
      r"^(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])-(\d{4})$",
    );

    if (pattern.hasMatch(date))
      return date;
    else
      return "";
  } catch (err, stack) {
    print('❌ $err \n ❌ $stack');
    throw "❌ Invalid Date... Please, use the format: [MM]-[DD]-[YYYY]";
  }
}
