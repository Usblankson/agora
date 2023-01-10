import 'package:agora/core/constants/agora.dart';
import 'package:agora/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallPage extends StatefulWidget {
  final String? channelName;
  final ClientRoleType? role;

  const CallPage({Key? key, this.channelName, this.role}) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final users = <int>[];
  final infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine
    initializeAgora();
  }

  @override
  void dispose() {
    // Destroy the Agora engine
    users.clear();
    agoraEngine.leaveChannel();
    super.dispose();
  }

  Future<void> initializeAgora() async {
    if (appId.isEmpty) {
      setState(() {
        infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    // Initialize the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));
    await agoraEngine.enableVideo();

    // Set up the event handlers

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pallete.primary,
        title: const Text('Agora Call'),
        centerTitle: true,
      ),
      body: const Center(child: Text('Agora Call')),
    );
  }
}
