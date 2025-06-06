class Conect {
  static const String BASE_IP = "192.168.100.47";

  static const int API_TIMEOUT_SECONDS = 15;

  static String getBaseUrl() {
    return "http://$BASE_IP/api";
  }
}