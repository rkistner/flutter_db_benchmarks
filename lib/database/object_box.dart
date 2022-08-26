import 'dart:io';

import 'package:db_benchmarks/interface/benchmark.dart';
import 'package:db_benchmarks/interface/user.dart';
import 'package:db_benchmarks/model/object_box_user.dart';
import 'package:db_benchmarks/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ObjectBoxDBImpl implements Benchmark {
  late Store store;
  late Box<ObjBoxUserModel> box;
  @override
  String get name => 'Object box';

  @override
  Future<void> setUp() async {
    var dir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dir.path, 'objectbox.db');
    if (await File(dbPath).exists()) {
      await File(dbPath).delete();
    }

    store = await openStore(directory: dbPath);
    box = store.box<ObjBoxUserModel>();
  }

  @override
  Future<void> tearDown() async {
    store.close();
  }

  @override
  Future<int> readUsers(List<User> users, bool optimise) async {
    if (optimise) {
      final ids = users.map((e) => e.id).toList();
      final s = Stopwatch()..start();
      box.getMany(ids);
      s.stop();
      return s.elapsedMilliseconds;
    } else {
      final s = Stopwatch()..start();
      for (var user in users) {
        box.get(user.id);
      }
      s.stop();
      return s.elapsedMilliseconds;
    }
  }

  @override
  Future<int> writeUsers(List<User> users, bool optimise) async {
    final castUsers = List.castFrom<User, ObjBoxUserModel>(users);
    if (optimise) {
      var s = Stopwatch()..start();
      box.putMany(castUsers);
      s.stop();
      return s.elapsedMilliseconds;
    } else {
      var s = Stopwatch()..start();
      for (var user in castUsers) {
        box.put(user);
      }
      s.stop();
      return s.elapsedMilliseconds;
    }
  }

  @override
  Future<int> deleteUsers(List<User> users, bool optimise) async {
    if (optimise) {
      final ids = users.map((e) => e.id).toList();
      var s = Stopwatch()..start();
      box.removeMany(ids);
      s.stop();
      return s.elapsedMilliseconds;
    } else {
      var s = Stopwatch()..start();
      for (var user in users) {
        box.remove(user.id);
      }
      s.stop();
      return s.elapsedMilliseconds;
    }
  }

  @override
  List<User> generateUsers(int count) {
    return List.generate(
      count,
      (_) => ObjBoxUserModel(
        id: 0,
        createdAt: DateTime.now(),
        username: 'username',
        email: 'email',
        age: 25,
      ),
    );
  }
}