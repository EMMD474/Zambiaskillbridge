import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over SharedPreferences used for every structured record.
/// Replace this class (for example with Hive or SQLite) without touching widgets.
class LocalStore {
  LocalStore(this._p);
  final SharedPreferences _p;

  static const prefix = 'sb.';

  bool getBool(String key, [bool fallback = false]) => _p.getBool(key) ?? fallback;
  Future<void> setBool(String key, bool v) => _p.setBool(key, v);

  String? getString(String key) => _p.getString(key);
  Future<void> setString(String key, String v) => _p.setString(key, v);

  List<String> getStrings(String key) => _p.getStringList(key) ?? <String>[];
  Future<void> setStrings(String key, List<String> v) => _p.setStringList(key, v);

  Future<void> remove(String key) => _p.remove(key);

  /// Reads a JSON list, skipping any record that cannot be parsed.
  List<T> readList<T>(String key, T Function(Map<String, dynamic>) from) {
    final raw = _p.getString(key);
    if (raw == null) return <T>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <T>[];
      final out = <T>[];
      for (final e in decoded) {
        try {
          out.add(from(Map<String, dynamic>.from(e as Map)));
        } catch (_) {
          // Outdated or damaged record: ignore it rather than crash.
        }
      }
      return out;
    } catch (_) {
      return <T>[];
    }
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> v) =>
      _p.setString(key, jsonEncode(v));

  Map<String, dynamic>? readMap(String key) {
    final raw = _p.getString(key);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeMap(String key, Map<String, dynamic>? v) =>
      v == null ? _p.remove(key) : _p.setString(key, jsonEncode(v));

  /// Removes only SkillBridge keys, never anything else on the device.
  Future<void> clearApp() async {
    for (final k in _p.getKeys().where((k) => k.startsWith(prefix)).toList()) {
      await _p.remove(k);
    }
  }
}

/// Copies picked photos into the app's own documents folder so they survive
/// cache clean ups, and deletes only that folder when demo data is cleared.
class MediaStore {
  static const _dirName = 'skillbridge_media';

  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/$_dirName');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  Future<String> persist(XFile file) async {
    final d = await _dir();
    final ext = file.path.contains('.') ? file.path.split('.').last : 'jpg';
    final dest = '${d.path}/${DateTime.now().microsecondsSinceEpoch}.$ext';
    await File(file.path).copy(dest);
    return dest;
  }

  Future<void> clearAll() async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final d = Directory('${base.path}/$_dirName');
      if (await d.exists()) await d.delete(recursive: true);
    } catch (_) {
      // Nothing to clean up, or the folder is locked. Not fatal.
    }
  }
}
