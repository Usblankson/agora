import 'package:agora/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


import 'features/agora/data/models/channel.dart';
import 'features/agora/presentation/pages/index.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // initialize hive
  await Hive.initFlutter();

  Hive.registerAdapter(ChannelAdapter());
  await Hive.openBox<Channel>('channels');
 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Callme',
      theme: ThemeData(),
      home: const IndexPage(),
    );
  }
}
