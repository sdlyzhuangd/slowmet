import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        // 亮色主题
        colorScheme: ColorScheme.light(
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          background: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.deepPurple,
          thumbColor: Colors.deepPurpleAccent,
          inactiveTrackColor: Colors.deepPurple.withOpacity(0.3),
        ),
      ),
      darkTheme: ThemeData(
        // 暗色主题
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          background: const Color(0xFF1A1A1A),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        useMaterial3: true,
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.deepPurple,
          thumbColor: Colors.deepPurpleAccent,
          inactiveTrackColor: Colors.deepPurple.withOpacity(0.3),
        ),
      ),
      home: MyHomePage(
        title: '超慢跑节拍器',
        onThemeToggle: toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key, 
    required this.title,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  final String title;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBeatLight(0, Colors.red),
          const SizedBox(width: 20),
          _buildBeatLight(1, Colors.green),
        ],
      ),
    );
  }

  Widget _buildBeatLight(int beat, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = beatCount == beat && isPlaying;
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color : color.withOpacity(isDark ? 0.2 : 0.1),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '${beat + 1}',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black12 : Colors.white,
        title: Text(widget.title),
        actions: [
          // 修改主题切换按钮
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '节拍: ${bpm.toInt()} BPM',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // BPM 滑动条
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Text('60', 
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54
                    )
                  ),
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
                  Text('240', 
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPlaying ? '节拍器运行中' : '点击开始',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            _buildBeatIndicator(),
            const SizedBox(height: 40),
            Text(
              '每小节2拍\n以二分音符为单位\n红色为重拍，绿色为轻拍',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black45,
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
