class RobotDevice {
  String name;
  String ip;
  String password;

  RobotDevice({required this.name, required this.ip, required this.password});

  // Convert to Map for saving to phone storage later
  Map<String, String> toMap() => {'name': name, 'ip': ip, 'password': password};
}