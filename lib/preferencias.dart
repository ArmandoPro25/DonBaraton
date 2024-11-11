import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class Preferencias {
  static const USER = 'user_name';
  static const PASS = 'pass';

  SharedPreferences? _preferencias;
  SharedPreferences? _preferenciasEncriptadas;
  EncryptedSharedPreferences _encryptedSharedPreferences = EncryptedSharedPreferences();

  String nombre = '';
  String pass = '';

  Future<SharedPreferences> get preferences async {
    if (_preferencias == null) {
      _preferencias = await SharedPreferences.getInstance();
      _preferenciasEncriptadas = await _encryptedSharedPreferences.getInstance();
      nombre = _preferencias?.getString(USER)??'';
      pass = _preferenciasEncriptadas?.getString(PASS)??'';
    }
    return _preferencias!;
  }

  Future<Preferencias> init() async {
    _preferencias = await preferences;
    return this;
  }

  Future<void> guardarUsuario() async {
    await _preferencias!.setString(USER, nombre);
  }

  Future<void> guardarContrasena() async {
    await _preferenciasEncriptadas!.setString(PASS, pass);
  }
}