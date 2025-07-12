class FirestoreConstants {
  // Collections
  static const String usersCollection = 'TaskTracker_Users';
  static const String tokenCollection = 'TaskTracker_FCM_Tokens';
  static const String adminCollection = 'TaskTracker_AdminKeys';
  static const String authAdmin = 'Authenticate_Admin';
}

class WorkManagerConstants {
  static const String morningTaskName = 'TaskTracker_MorningRemainder';
  static const String periodicTaskName = 'TaskTracker_PeriodicRemainder';
  static const String morningUniqueName = 'TaskTracker_MorningTaskCheck';
  static const String periodicUniqueName = 'TaskTracker_PeriodicTaskCheck';
  static const String nightTaskName = 'TaskTracker_NightRemainder';
  static const String nightUniqueName = 'TaskTracker_NightTaskCheck';
  static const String specificTaskName = 'TaskTracker_SpecificTaskRemainder';
  static const String workManagerCancel =
      'Previous Periodic Notifications Cancel';
  static const String workManagerInitialize = 'New Periodic Notifications Set';
}

class HiveDatabaseConstants {
  static const String todoHive = 'TodoBox';
  static const String managerHive = 'WorkManagerTasks';
  static const String managerInitialize = 'WorkManagerInitialize';
  static const String managerFrequency = "ManagerFrequency";
  static const String frequencyValue = "ManagerFrequencyValue";
  static const String permissionHive = 'PermissionsAsked';
  static const String permissionHiveAsk = 'PermissionAlreadyAsked';
  static const String authHive = 'UserInfo';
  static const String themeHive = "AppTheme";
}

class NotificationConstants {
  static String channelId = "TaskTrackerDefaultID";
  static const String channelName = 'TaskTracker_NotificationChannel';
  static const String channelDescription = 'Notifications for todo tasks';
  static const String dailyTitle = 'Daily Reminder';
  static const String dailyBody = 'Check your pending tasks for today!';
  static const String newFreshTitle = 'Organize Today';
  static const String newFreshBody =
      'Start today fresh. Set new tasks to stay organized!';
  static const String pendingTitle = 'Task Pending';
  static const String pendingBody = 'Last day of today pending tasks';
}

class AppConstants {
  static const String appTitle = "Task Tracker";
}
