import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Hive supports JSON-compatible maps', () async {
    final dir = await Directory.systemTemp.createTemp('movies_hive_test_');
    Hive.init(dir.path);
    final box = await Hive.openBox<Map>('json_test');
    await box.put('key', <String, Object?>{
      'payload': <String, Object?>{'title': 'verified sample'},
    });
    final value = box.get('key');
    expect((value?['payload'] as Map)['title'], 'verified sample');
    await box.close();
    await dir.delete(recursive: true);
  });
}
