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
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          background: const Color(0xFF1A1A1A), // 深色背景
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A), // 页面背景色
        useMaterial3: true,
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.deepPurple,
          thumbColor: Colors.deepPurpleAccent,
          inactiveTrackColor: Colors.deepPurple.withOpacity(0.3),
        ),
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
  double bpm = 180;   // 添加 BPM 变量，初始值为 180
  
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
    final interval = 60000 / bpm; // 计算每拍间隔（毫秒）
    
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

  // 添加一个构建拍号指示器的方法
  Widget _buildBeatIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 第一拍指示器
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: beatCount == 0 && isPlaying 
                  ? Colors.red 
                  : Colors.red.withOpacity(0.2),
              boxShadow: beatCount == 0 && isPlaying
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // 第二拍指示器
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: beatCount == 1 && isPlaying 
                  ? Colors.green 
                  : Colors.green.withOpacity(0.2),
              boxShadow: beatCount == 1 && isPlaying
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '节拍: ${bpm.toInt()} BPM',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // BPM 滑动条
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Text('60', style: TextStyle(color: Colors.white70)),
                  Expanded(
                    child: Slider(
                      value: bpm,
                      min: 60,
                      max: 240,
                      divisions: 180,
                      onChanged: isPlaying ? null : (value) {
                        setState(() {
                          bpm = value;
                        });
                      },
                    ),
                  ),
                  Text('240', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPlaying ? '节拍器运行中' : '点击开始',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            _buildBeatIndicator(),
            const SizedBox(height: 40),
            Text(
              '每小节2拍\n以二分音符为单位\n红色为重拍，绿色为轻拍',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _toggleMetronome,
        tooltip: isPlaying ? '停止' : '开始',
        child: Icon(
          isPlaying ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }
}
