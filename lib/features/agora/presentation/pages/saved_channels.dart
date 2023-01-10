import 'package:agora/features/agora/data/models/channel.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/custom_widgets.dart';

class SavedChannelsPage extends StatefulWidget {
  const SavedChannelsPage({super.key});

  @override
  State<SavedChannelsPage> createState() => _SavedChannelsPageState();
}

class _SavedChannelsPageState extends State<SavedChannelsPage> {
  final channelNameController = TextEditingController();

  final channelDescController = TextEditingController();

  final channelFormKey = GlobalKey<FormState>();

  late final Box<Channel> box;
  // Future addChannel(
  //   String name,
  //   String description,
  // ) async {
  //   final channel = Channel()
  //     ..name = name
  //     ..description = description
  //     ..createdAt = DateTime.now();
  //   // ..updatedAt = DateTime.now();

  //   final box = Boxes.getChannels();
  //   box.add(channel);
  // }

  addChannel() async {
    // Add info to people box

    Channel channel = Channel(
      name: channelNameController.text,
      description: channelDescController.text,
      createdAt: DateTime.now(),
    );
    box.add(channel);
    print('Channel ${channel.name} added to box!');
  }

  getChannel() {
    // Get info from people box
  }

  updateChannel(int index) {
    // Update info of people box

    Channel channel = Channel(
      name: channelNameController.text,
      description: channelDescController.text,
      updatedAt: DateTime.now(),
    );
    box.putAt(index, channel);
    //   print('Channel ${channel.name} updated!');
  }

  deleteChannel(int index) {
    // Delete info from people box

    box.deleteAt(index);
    print('Item deleted from box at index: $index');
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field can\'t be empty';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Get reference to an already opened box
    box = Hive.box<Channel>('channels');
  }

  @override
  void dispose() {
    // Hive.close();
    channelNameController.dispose();
    channelDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Pallete.white),
        backgroundColor: Pallete.primary,
        title: const Text('Saved Channels',
            style:
                TextStyle(color: Pallete.white, fontStyle: FontStyle.italic)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          final channels = box.values.toList().cast<Channel>();
          if (box.isEmpty) {
            return const Center(
              child: Text('Empty'),
            );
          } else {
            return ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];

                return ListTile(
                  hoverColor: Pallete.lightTextColor,
                  title: Text(channel.name),
                  subtitle: Text(channel.description),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Pallete.error,
                    ),
                    onPressed: () => deleteChannel(index),
                  ),
                );
              },
            );
          }
        },
        // child: const Center(
        //   child: Text('Saved Channels'),
        // ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            enableDrag: true,
            isDismissible: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            builder: (context) {
              return addChannelBottomSheetUI(
                context: context,
                channelNameController: channelNameController,
                channelDescController: channelDescController,
                onPressed: () {
                  print("pressed");
                },
              );
            },
          );
        },
        backgroundColor: Pallete.primary,
        child: const Icon(Icons.add),
      ),
    );
    // return const Center(child: Text('Empty'));
  }

  Widget addChannelBottomSheetUI(
      {required BuildContext context,
      required TextEditingController channelNameController,
      required TextEditingController channelDescController,
      required VoidCallback onPressed}) {
    return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            width: double.infinity,
            // height: MediaQuery.of(context).size.height * 0.46,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              color: Pallete.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Form(
              key: channelFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Add a new channel'.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Pallete.primary)),
                  const SizedBox(height: 20),
                  customTextField(
                    'Channel Name',
                    channelNameController,
                    _fieldValidator,
                    true,
                    Pallete.primary,
                  ),
                  const SizedBox(height: 20),
                  customTextField(
                    'Channel Description',
                    channelDescController,
                    _fieldValidator,
                    true,
                    Pallete.primary,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: customButton("Save", false, () {
                          if (channelFormKey.currentState!.validate()) {
                            addChannel();
                            Navigator.of(context).pop();
                          }
                        }, Pallete.primary),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: customButton("Cancel", true,
                            () => Navigator.pop(context), Pallete.primary),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
