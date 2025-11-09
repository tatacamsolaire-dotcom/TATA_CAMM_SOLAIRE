
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const String fileName = 'gvultra_data.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<Map<String, dynamic>> readAll() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final txt = await file.readAsString();
        return json.decode(txt) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'products': [], 'sales': []};
  }

  Future<void> writeAll(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(json.encode(data));
  }

  Future<File> exportJson() async {
    final data = await readAll();
    final dir = await getApplicationDocumentsDirectory();
    final out = File('${dir.path}/export_gvultra_${DateTime.now().millisecondsSinceEpoch}.json');
    await out.writeAsString(json.encode(data));
    return out;
  }

  Future<void> importJson(File file) async {
    final txt = await file.readAsString();
    final map = json.decode(txt);
    if (map is Map<String, dynamic>) {
      await writeAll(map);
    }
  }

  Future<void> clearAll() async {
    await writeAll({'products': [], 'sales': []});
  }
}
