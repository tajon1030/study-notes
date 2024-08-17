import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

import '../const/keys.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({super.key});

  @override
  State<CamScreen> createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  RtcEngine? engine;
  int? uid = 0;
  int? remoteUid;

  Future<void> init() async {
    // 권한받기
    final resp = await [Permission.camera, Permission.microphone].request();
    final cameraPermission = resp[Permission.camera];
    final microphonePermission = resp[Permission.microphone];
    if (cameraPermission != PermissionStatus.granted ||
        microphonePermission != PermissionStatus.granted) {
      throw Exception('카메라 또는 마이크 권한이 없습니다.');
    }
    if (engine == null) {
      engine = createAgoraRtcEngine(); // 엔진생성
      await engine!.initialize(
        // 엔진생성후 초기화해줘야함
        RtcEngineContext(
          appId: appId,
        ),
      );

      engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed){},
          onLeaveChannel: (RtcConnection connection, RtcStats stats){},
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print('-----User Joined-----');
            setState(() {
              this.remoteUid = remoteUid;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            setState(() {
              this.remoteUid = null;
            });
          },
        ),
      );

      await engine!.enableVideo(); // 영상 활성화
      await engine!.startPreview(); // 화면을 보이게 시작한다.
      ChannelMediaOptions options =
          ChannelMediaOptions(); // 송출을 어떻게 할것인지에 대한 옵션
      await engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid!, // 0을 넣으면 아고라에서 랜덤하게 uid배정해줌
        options: options,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live'),
      ),
      body: FutureBuilder<void>(
          future: init(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            return Stack(
              children: [
                /// 메인화면
                Container(
                  /// remote = 상대방
                  child: renderMainView(),
                ),

                /// 서브화면
                Container(
                  width: 120,
                  height: 160,
                  child: AgoraVideoView(
                    /// 그냥 controller는 내 화면을 보여줌
                    controller: VideoViewController(
                      rtcEngine: engine!,
                      canvas: VideoCanvas(uid: uid),
                    ),
                  ),
                ),

                /// 나가기버튼
                Positioned(
                  bottom: 16,
                  right: 16,
                  left: 16,
                  child: ElevatedButton(
                    onPressed: () {
                      engine!.leaveChannel();
                      engine!.release();
                      Navigator.of(context).pop();
                    },
                    child: Text('나가기'),
                  ),
                ),
              ],
            );
          }),
    );
  }

  renderMainView() {
    if (remoteUid == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: engine!,
        canvas: VideoCanvas(
          uid: remoteUid,
        ),
        connection: RtcConnection(
          channelId: channelName,
        ),
      ),
    );
  }
}
