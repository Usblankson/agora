import 'dart:async';
import 'package:agora/core/constants/agora.dart';
import 'package:agora/features/agora/presentation/pages/saved_channels.dart';
import 'package:agora/features/agora/presentation/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:agora/core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final channelController = TextEditingController();
  bool validateError = false;

  ClientRoleType? role = ClientRoleType.clientRoleBroadcaster;

  String token = apptoken;

  int uid = 0; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }

  void join() async {
    await agoraEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine
    setupVideoSDKEngine();
  }

  // Clean up the resources when you leave
  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pallete.primary,
        title: const Text('Callme',
            style:
                TextStyle(color: Pallete.white, fontStyle: FontStyle.italic)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              // Center(
              //     child: SvgPicture.network(
              //   agoralogUrl,
              //   placeholderBuilder: (BuildContext context) => Container(
              //       padding: const EdgeInsets.all(30.0),
              //       child: const CircularProgressIndicator()),
              // )),
              // const SizedBox(height: 20),

              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: Pallete.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: _localPreview()),
              ),
              const SizedBox(height: 10),
              //Container for the Remote video
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: Pallete.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: _remoteVideo()),
              ),
              const SizedBox(height: 10),
              // Button Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isJoined ? null : () => {join()},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Pallete.primary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        disabledForegroundColor: Colors.grey.withOpacity(0.38),
                        disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text("Join"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isJoined ? () => {leave()} : null,
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            _isJoined ? Colors.white : Pallete.primary,
                        backgroundColor:
                            _isJoined ? Pallete.error : Pallete.grey,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        disabledForegroundColor: Colors.grey.withOpacity(0.38),
                        disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text("Leave"),
                    ),
                  ),
                ],
              ),
              // Button Row ends
              const SizedBox(height: 10),
              customButton("Saved Channel", false, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedChannelsPage(),
                    ));
              }, Pallete.primary)
            ],
          )),
    );
  }

// Display local video preview
  Widget _localPreview() {
    if (_isJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: uid),
        ),
      );
    } else {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      );
    }
  }

// Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channelName),
        ),
      );
    } else {
      String msg = '';
      if (_isJoined) msg = 'Waiting for a remote user to join';
      return Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      );
    }
  }
}
