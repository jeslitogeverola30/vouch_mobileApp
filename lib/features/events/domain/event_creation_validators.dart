class EventCreationValidators {
  EventCreationValidators._();

  static String? validateTitle(String? value) {
    final title = value?.trim() ?? '';

    if (title.isEmpty) {
      return 'Please enter event title';
    }
    if (title.length < 3) {
      return 'Enter at least 3 characters';
    }

    return null;
  }

  static String? validateLocation(String? value) {
    final location = value?.trim() ?? '';

    if (location.isEmpty) {
      return 'Please enter event location';
    }
    if (location.length < 3) {
      return 'Enter at least 3 characters';
    }

    return null;
  }

  static String? validateShortDescription(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Please enter short description';
    }

    return null;
  }

  static String? validateFullDescription(String? value) {
    final description = value?.trim() ?? '';

    if (description.isEmpty) {
      return 'Please enter full description';
    }
    if (description.length < 10) {
      return 'Please provide more details';
    }

    return null;
  }

  static String? validateEventDate(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Please select event date';
    }

    return null;
  }

  static String? validateTimeInWindow({
    required String? value,
    required int? startMinutes,
    required int? endMinutes,
  }) {
    if ((value?.trim() ?? '').isEmpty ||
        startMinutes == null ||
        endMinutes == null) {
      return 'Please set time in window';
    }

    if (endMinutes <= startMinutes) {
      return 'Invalid time in range';
    }

    return null;
  }

  static String? validateTimeOutWindow({
    required String? value,
    required int? startMinutes,
    required int? endMinutes,
    required int? timeInEndMinutes,
  }) {
    if ((value?.trim() ?? '').isEmpty ||
        startMinutes == null ||
        endMinutes == null) {
      return 'Please set time out window';
    }

    if (endMinutes <= startMinutes) {
      return 'Invalid time out range';
    }

    if (timeInEndMinutes != null && startMinutes <= timeInEndMinutes) {
      return 'Time out must start after time in';
    }

    return null;
  }

  static bool isSupportedImageExtension(String filePath) {
    if (!filePath.contains('.')) {
      return false;
    }

    final extension = filePath.toLowerCase().split('.').last;
    return extension == 'jpg' || extension == 'jpeg' || extension == 'png';
  }

  static bool isFileSizeWithinLimitBytes(
    int sizeInBytes, {
    int maxMegabytes = 5,
  }) {
    final maxSizeInBytes = maxMegabytes * 1024 * 1024;
    return sizeInBytes <= maxSizeInBytes;
  }

  static int timeToMinutes({required int hour, required int minute}) {
    return (hour * 60) + minute;
  }

  static ({int hour, int minute}) addMinutes({
    required int hour,
    required int minute,
    required int minutes,
  }) {
    final totalMinutes = ((hour * 60) + minute + minutes) % (24 * 60);

    return (hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }
}
