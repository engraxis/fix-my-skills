class AuthErrors {
  static const String ERROR_INVALID_EMAIL = 'ERROR: INVALID_EMAIL';
  static const String ERROR_EMAIL_ALREADY_IN_USE =
      'ERROR: EMAIL_ALREADY_IN_USE';

  static const String ERROR_USER_NOT_FOUND = 'ERROR: USER_NOT_FOUND';
  static const String ERROR_WRONG_PASSWORD = 'ERROR: WRONG_PASSWORD';
}

class WeekDays {
  static const List<String> dayNames = [
    'sun',
    'mon',
    'tue',
    'wed',
    'thr',
    'fri',
    'sat',
  ];
}

class Keys {
  static const String users = 'users';
  static const String instructors = 'instructors';
  static const String admin = 'admin';
  static const String profilePictures = 'profilePictures';
  static const String name = 'name';
  static const String email = 'email';
  static const String uid = 'uid';
  static const String pictureUrl = 'pictureUrl';
  static const String isInstructor = 'isInstructor';

  static const String timeTable = 'timeTable';
  static const String weeklyAvailability = 'weeklyAvailability';
  static const String isDayAvailable = 'isDayAvailable';
  static const String from = 'from';
  static const String to = 'to';
  static const String videos = 'videos';
  static const String videoId = 'videoId';

  static const String access = 'access';
  static const String adminWaiting = 'adminWaiting';
  static const String adminAssigned = 'adminAssigned';
  static const String adminUpdated = 'adminUpdated';
  static const String adminFinalised = 'adminFinalised';
  static const String adminFeatured = 'adminFeatured';

  static const String instructorWaiting = 'instructorWaiting';
  static const String instructorCompleted = 'instructorCompleted';

  static const String userWaiting = 'userWaiting';
  static const String userCompleted = 'userCompleted';

  static const String messages = 'messages';
  static const String date = 'date';
  static const String text = 'text';
  static const String myChats = 'myChats';

  static const String appointments = 'appointments';
  static const String appointmentDetails = 'appointmentDetails';

  static const String links = 'links';
  static const String privacyLink = 'privacyLink';
  static const String termsLink = 'termsLink';
  static const String faqLink = 'faqLink';

  static const String config = 'config';
  static const String prices = 'prices';
  static const String pricePerVideo = 'pricePerVideo';
  static const String pricePerSecond = 'pricePerSecond';
  static const String videoTimeLimit = 'videoTimeLimit';
  static const String allTimeEarnings = 'allTimeEarnings';
}
