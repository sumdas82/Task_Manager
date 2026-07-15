class Urls {
  static String baseURL = 'https://task-manager-api.ostad.live/api/v1';
  static String SignUpURL = '$baseURL/Registration';
  static String SignInURL = '$baseURL/Login';
  static String getTaskCountURL = '$baseURL/taskStatusCount';
  static String CreateTaskURL = '$baseURL/createTask';
  static String updateProfileURL = '$baseURL/ProfileUpdate';
  static String getTaskByStatusURL(String status) =>
      '$baseURL/listTaskByStatus/$status';
  static String deleteTaskURL(String id) => '$baseURL/deleteTask/$id';
  static String updateTaskStatusURL(String id, String Status) =>
      '$baseURL/updateTaskStatus/$id/$Status';

  // NOTE: this one was not given in the teacher's urls.dart, guessing the
  // pattern here based on the other endpoints. used for full task edit
  // (title, description, status, priority all together). test this one
  // and check with teacher if it does not work
  static String updateTaskURL(String id) => '$baseURL/updateTask/$id';
}
