import 'package:flutter/material.dart';
import 'package:multiassistant/helper/model.dart';
import 'package:multiassistant/helper/helper.dart';
import 'package:multiassistant/widgets/empty_name.dart';
import 'package:multiassistant/widgets/discard.dart';

class ServerDetail extends StatefulWidget {
  final String title;
  final Server server;

  const ServerDetail(this.server, this.title, {super.key});

  @override
  State<ServerDetail> createState() {
    return _ServerDetailState(server, title);
  }
}

class _ServerDetailState extends State<ServerDetail> {
  Helper helper = Helper();

  String title;
  Server server;

  _ServerDetailState(this.server, this.title);

  TextEditingController nameController = TextEditingController();
  TextEditingController localUrlController = TextEditingController();
  TextEditingController externalUrlController = TextEditingController();

  bool isEdited = false;

  @override
  Widget build(BuildContext context) {
    nameController.text = server.name;
    localUrlController.text = server.localUrl;
    externalUrlController.text = server.externalUrl;

    return WillPopScope(
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.medium(
                title: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              SliverFillRemaining(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: nameController,
                              onChanged: (value) {
                                isEdited = true;
                                server.name = value;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  // <--- border
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                labelText: 'Name',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: localUrlController,
                              onChanged: (value) {
                                isEdited = true;
                                server.localUrl = value;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  // <--- border
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                labelText: 'Local URL',
                                hintText: 'http://homeassistant.local:8123',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: externalUrlController,
                              onChanged: (value) {
                                isEdited = true;
                                server.externalUrl = value;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  // <--- border
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                labelText: 'External URL',
                                hintText: 'https://homeassistant.com',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: FilledButton(
                              onPressed: () {
                                nameController.text.isEmpty
                                    ? showEmptyNameDialog(context)
                                    : _save();
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20,
                                    top: 10.0,
                                    bottom: 10),
                                child: Text(
                                  'Save',
                                  // style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        onWillPop: () async {
          isEdited ? showDiscardDialog(context) : moveToLastScreen();
          return false;
        });
  }

  moveToLastScreen() {
    Navigator.pop(context, true);
  }

  _save() {
    if (server.id != null) {
      helper.updateServer(server);
    } else {
      helper.insertServer(server);
    }
    moveToLastScreen();
  }
}
