bool HandleValidateDate(String date) {
  try {
    if(date.isEmpty) return false;
  
    final RegExp pattern = RegExp(r"^(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])-(\d{4})$"); 
  
    return pattern.hasMatch(date);
  } catch (err, stack) {
    throw "❗❗❗ An error occured: ➡️ $err ➡️ $stack";
  }
}

String HandleGetDate(String date) {
  if(HandleValidateDate(date)) return date;
  else if(date == "no-date") return "";
  else return throw "Invalid Date... Please, use the format: [MM]-[DD]-[YYYY]";
}