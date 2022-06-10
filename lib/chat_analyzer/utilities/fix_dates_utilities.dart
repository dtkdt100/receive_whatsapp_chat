class FixDateUtilities {
  /// Fixing a string hour of whatsapp to a parsable dart date
  static String hourStringOrganization(String hourFromLine) {
    String hour = hourFromLine.split(':')[0];
    String minute = hourFromLine.split(':')[1].split(' ')[0];
    if (hourFromLine.split(' ').length == 1) return '${fixMonthOrDayTo01(hour)}:$minute:00';
    if (hourFromLine.split(' ')[1] == 'PM') {
      hour = '${int.parse(hour) + 12}';
    } else {
      hour = fixMonthOrDayTo01(hour);
    }
    return "$hour:$minute:00";
  }

  /// Fixing a string date of whatsapp to a parsable dart date
  static String dateStringOrganization(String dateFromLine) {
    dateFromLine = dateFromLine.replaceAll('[', '');
    List listOfMonthDayYear = dateFromLine.split(RegExp(r"[/|.]"));
    listOfMonthDayYear[0] = fixMonthOrDayTo01(listOfMonthDayYear[0]);
    listOfMonthDayYear[1] = fixMonthOrDayTo01(listOfMonthDayYear[1]);
    listOfMonthDayYear[2] = _fixYear20(listOfMonthDayYear[2]);
    listOfMonthDayYear = _sortList(listOfMonthDayYear);
    String date = _listToStringDate(listOfMonthDayYear);
    return date;
  }

  /// List of String to String - to use the function [DateTime.parse]
  static String _listToStringDate(List list) {
    var concatenate = StringBuffer();
    for (var item in list) {
      concatenate.write(item);
    }
    return '$concatenate';
  }

  ///Sort the list in order to parse the list to string
  static List _sortList(List list) {
    List newList = [];
    newList.add(list[2]);
    newList.add('-');
    newList.add(list[1]);
    newList.add('-');
    newList.add(list[0]);
    return newList;
  }

  /// Som months write as one single number when they should be write as two, for example:
  /// 9 should be 09, 1 should be 01...
  static String fixMonthOrDayTo01(String fix) {
    if (fix.length == 2) {
      return fix;
    } else {
      return '0$fix';
    }
  }

  ///The year in Whatsapp are 22, where it should be 2022.
  ///This function added the 2 missing numbers (maybe if you are watching this it is now 3!)
  static String _fixYear20(String year) {
    if (year.length == 4) return year;
    String firstFirstTwoLetters = '${DateTime.now().year}'.substring(0, 2);
    return '$firstFirstTwoLetters$year';
  }
}
