import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '超慢跑节拍器'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isPlaying = false;
  final playerHigh = AudioPlayer();  // 重音
  final playerLow = AudioPlayer();   // 轻音
  int beatCount = 0;  // 用于跟踪当前是第几拍
  
  @override
  void initState() {
    super.initState();
    // 预加载音频文件
    playerHigh.setSourceAsset('ding.wav');  // 重音
    playerLow.setSourceAsset('da.wav');     // 轻音
  }

  @override
  void dispose() {
    playerHigh.dispose();
    playerLow.dispose();
    super.dispose();
  }

  void _toggleMetronome() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        beatCount = 0;
        _startMetronome();
      }
    });
  }

  void _startMetronome() async {
    const bpm = 180;
    const interval = 60000 / bpm; // 计算每拍间隔（毫秒）
    
    while (isPlaying) {
      if (beatCount % 2 == 0) {
        await playerHigh.play(AssetSource('ding.wav')); // 第一拍（重音）
      } else {
        await playerLow.play(AssetSource('da.wav'));  // 第二拍（轻音）
      }
      
      beatCount = (beatCount + 1) % 2;  // 在0和1之间循环
      
      setState(() {});  // 更新显示当前拍号
      await Future.delayed(Duration(milliseconds: interval.toInt()));
      if (!isPlaying) break;
    }
  }

  String _getCurrentBeat() {
    if (!isPlaying) return '';
    return '第 ${beatCount + 1} 拍';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '节拍: 180 BPM',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              isPlaying ? '节拍器运行中' : '点击开始',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              _getCurrentBeat(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: beatCount % 2 == 0 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '每小节2拍\n以二分音符为单位\n红色为重音，蓝色为轻音',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMetronome,
        tooltip: isPlaying ? '停止' : '开始',
        child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
