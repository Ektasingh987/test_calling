class AppConstants {
  AppConstants._();

  // Hive Box Names
  static const String postsBox = 'posts_box';
  static const String callLogsBox = 'call_logs_box';

  // Hive Type IDs
  static const int postModelTypeId = 0;
  static const int postUserModelTypeId = 1;
  static const int callLogModelTypeId = 2;

  // Pagination
  static const int pageSize = 10;

  // Agora
  static const int localUid = 0;
  static const int remoteUid = 1;

  // Timeouts (fast failover to cache)
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 5);
}

