# 超慢跑的节拍器

    这是一个完全有AI完成的项目超慢跑节拍器。没编写修改一句代码，出现的问题错误，均有AI解决
    flutter全平台，超慢跑下的叮嗒声，祝你运动成功。

项目基于flutter框架IDEA生成基础的项目，其他均交给AI完成。完成过程可以参见log过程
1. apk的编译需要先keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
2. 然后修改android\key.properties
3. flutter build apk --release 生成Android release
4. flutter build windows --release 生成win发行版本
5. 也可以其他版本，命令请问ai
    