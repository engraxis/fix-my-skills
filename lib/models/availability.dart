import '../res/keys.dart';

class Availability {
  static const String from = 'from';
  static const String to = 'to';

  static List<Map<String, dynamic>> _availabilityList = [];

  void clearAvailability() {
    _availabilityList.clear();
  }

  List<Map<String, dynamic>> get availabilityList => _availabilityList;

  void addAvailability(
    String day,
    DateTime fromTime,
    DateTime toTime,
    bool isDayAvailable,
  ) {
    _availabilityList.removeWhere((element) => element.containsKey(day));
    _availabilityList.add(
      {
        day: {
          Keys.from: fromTime,
          Keys.to: toTime,
          Keys.isDayAvailable: isDayAvailable,
        }
      },
    );
  }

  List<Map<String, dynamic>> fetchAvailability(String uid) {
    return _availabilityList;
  }
}
