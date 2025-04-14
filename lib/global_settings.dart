

class GlobalSettings {
  static final GlobalSettings _instance = GlobalSettings._internal();

  GlobalSettings._internal();

  static GlobalSettings get instance => _instance;

  String language = 'English';
  String? ip;

  void update_ip(String ip) {
    
    this.ip = ip;
  }
}
