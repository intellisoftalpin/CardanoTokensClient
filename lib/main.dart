import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'generated/codegen_loader.g.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await GetStorage.init('MyStorage');
  await GetStorage.init('PassPrefer');
  await Hive.initFlutter();
  runApp(
      EasyLocalization(
        supportedLocales: [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: Locale('en'),
        assetLoader: CodegenLoader(),
        child: App(),
      )
  );
}
