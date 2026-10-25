import 'package:flutter_driver/driver_extension.dart';
import 'package:magpie_nest/main.dart' as app;

Future<void> main() async {
  enableFlutterDriverExtension();
  await app.main();
}
