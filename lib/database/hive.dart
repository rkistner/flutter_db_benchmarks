import 'dart:io';

import 'package:db_benchmarks/interface/user.dart';
import 'package:db_benchmarks/model/user.dart';
import 'package:hive/hive.dart';
import 'package:db_benchmarks/interface/benchmark.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HiveDBImpl implements Benchmark {
  late Box box;
  @override
  String get name => 'Hive';

  @override
  Future<void> setUp() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(dir.path, 'hive.db');
    if (await File(dbPath).exists()) {
      await File(dbPath).delete();
    }

    Hive.init(dbPath);
    box = await Hive.openBox('box');
  }

  @override
  Future<void> tearDown() async {
    await box.close();
    await Hive.close();
  }

  @override
  Future<int> readUsers(List<User> users, bool optimise) async {
    final s = Stopwatch()..start();
    for (var user in users) {
      box.get(user.id);
    }
    s.stop();
    return s.elapsedMilliseconds;
  }

  @override
  Future<int> writeUsers(List<User> users, bool optimise) async {
    if (optimise) {
      final Map<dynamic, dynamic> data = {};
      for (var user in users) {
        data[user.id] = user.toMap();
      }
      var s = Stopwatch()..start();
      await box.putAll(data);
      s.stop();
      return s.elapsedMilliseconds;
    } else {
      var s = Stopwatch()..start();
      for (var user in users) {
        await box.put(user.id, user.toMap());
      }
      s.stop();
      return s.elapsedMilliseconds;
    }
  }

  @override
  Future<int> deleteUsers(List<User> users, bool optimise) async {
    if (optimise) {
      final ids = users.map((e) => e.id);
      var s = Stopwatch()..start();
      await box.deleteAll(ids);
      s.stop();
      return s.elapsedMilliseconds;
    } else {
      var s = Stopwatch()..start();
      for (var user in users) {
        await box.delete(user.id);
      }
      s.stop();
      return s.elapsedMilliseconds;
    }
  }

  @override
  List<User> generateUsers(int count) {
    return List.generate(
      count,
      (index) => UserModel(
        id: index,
        createdAt: DateTime.now(),
        username: 'username',
        email: 'email',
        age: 25,
      ),
    );
  }
}