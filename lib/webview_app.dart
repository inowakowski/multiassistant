import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multiassistant/helper/helper.dart';
import 'package:multiassistant/helper/model.dart';
import 'package:sqflite/sqflite.dart' show Database;
import 'package:multiassistant/server_detail.dart';
import 'package:multiassistant/web_page.dart';
import 'package:multiassistant/helper/check_url.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  Helper helper = Helper();

  List<Server> serverList = [];
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (serverList.isEmpty) {
      serverList = [];
      updateListView();
    } else {
      updateListView();
    }

    helper.getServersMapList();
    helper.getServersList();

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () {
            navigateToDetail(Server('', '', ''), 'Add Server');
          },
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: const Text('MultiAssistant',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
            // backgroundColor: Colors.blue,
          ),
          SliverFillRemaining(
            child: serverList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No servers found. Please add a server.",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  )
                : Container(
                    child: getServersList(),
                  ),
          ),
        ],
      ),
    );
  }

  void updateListView() {
    final Future<Database> dbFuture = helper.initializeDb();
    dbFuture.then((database) {
      Future<List<Server>> serverListFuture = helper.getServersList();
      serverListFuture.then((serverList) {
        setState(() {
          this.serverList = serverList;
          count = serverList.length;
        });
      });
    });
  }

  ListView getServersList() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Slidable(
          startActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const DrawerMotion(),
            children: [
              CustomSlidableAction(
                backgroundColor: Theme.of(context).colorScheme.background,
                onPressed: (context) {
                  navigateToDetail(serverList[index], 'Edit Server');
                },
                child: LayoutBuilder(
                  builder: (context, constraints) => SizedBox(
                    height: constraints.maxHeight - 8,
                    child: SlidableAction(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      icon: Icons.edit,
                      label: 'Edit',
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                      onPressed: (context) {
                        navigateToDetail(serverList[index], 'Edit Server');
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          endActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const DrawerMotion(),
            children: [
              CustomSlidableAction(
                backgroundColor: Theme.of(context).colorScheme.background,
                onPressed: (context) {
                  navigateToDetail(serverList[index], 'Edit Server');
                },
                child: LayoutBuilder(
                  builder: (context, constraints) => SizedBox(
                    height: constraints.maxHeight - 8,
                    child: SlidableAction(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      icon: Icons.delete,
                      label: 'Delete',
                      backgroundColor: Theme.of(context).colorScheme.onError,
                      onPressed: (context) {
                        navigateToDetail(serverList[index], 'Edit Server');
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          child: Card(
            child: ListTile(
              title: Text(serverList[index].name,
                  style: const TextStyle(fontSize: 20.0)),
              subtitle: Text(
                '',
              ),
              onTap: () {
                _checkUrl(index);
              },
              onLongPress: () {
                navigateToDetail(serverList[index], 'Edit Server');
              },
            ),
          ),
        );
      },
    );
  }

  void _delete(BuildContext context, Server serverList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete"),
          content: const Text("Are you sure you want to delete this server?"),
          actions: [
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                helper.deleteServer(serverList.id!);
                updateListView();
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> navigateToDetail(Server server, String s) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ServerDetail(server, s);
    }));

    if (result == true) {
      updateListView();
    }
  }

  Future<void> navigateToServer(String url) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return WebViewPage(url);
    }));
  }

  Future<void> snackBar() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Server is not reachable"),
      ),
    );
  }

  _checkUrl(index) async {
    try {
      var response = await http.get(Uri.parse(serverList[index].localUrl));
      if (response.statusCode == 200) {
        navigateToServer(serverList[index].localUrl);
      }
    } on SocketException catch (_) {
      var response = await http.get(Uri.parse(serverList[index].externalUrl));
      if (response.statusCode == 200) {
        navigateToServer(serverList[index].externalUrl);
      }
    } on Exception catch (_) {
      snackBar();
    }
  }
}
