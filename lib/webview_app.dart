import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multiassistant/helper/helper.dart';
import 'package:multiassistant/helper/model.dart';
import 'package:sqflite/sqflite.dart' show Database;
import 'package:multiassistant/server_detail.dart';
import 'package:multiassistant/web_page.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  Helper helper = Helper();

  List<Server> serverList = [];
  int count = 0;

  List<String> connectionStatus = [];

  bool isLoading = false;

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
          SliverAppBar.large(
            title: Text(
              'MultiAssistant',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            bottom: PreferredSize(
              preferredSize: const Size(double.infinity, 4),
              child: isLoading ? const LinearProgressIndicator() : Container(),
            ),
          ),
          SliverFillRemaining(
            child: serverList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "No servers found. Please add a server.",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  )
                : Container(
                    // margin: EdgeInsets.only(top: ),
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
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        // _checkConnection(index);
        return Slidable(
          startActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                // borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                // padding: const EdgeInsets.only(top: -8.0, bottom: -8.0),
                icon: Icons.edit,
                autoClose: true,
                label: 'Edit',
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                onPressed: (context) {
                  navigateToDetail(serverList[index], 'Edit Server');
                },
              ),
            ],
          ),
          endActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                icon: Icons.delete,
                label: 'Delete',
                backgroundColor: Theme.of(context).colorScheme.error,
                onPressed: (context) {
                  _delete(context, index);
                },
              ),
            ],
          ),
          child: ListTile(
            // contentPadding: EdgeInsets.all(8.0),
            title: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(serverList[index].name,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            // subtitle: _checkConnection(index) == ''
            //     ? const Text("puste")
            //     : Text(connectionStatus[index]),
            onTap: () {
              _checkUrl(index);
            },
            onLongPress: () {
              navigateToDetail(serverList[index], 'Edit Server');
            },
          ),
        );
      },
    );
  }

  void _delete(BuildContext context, index) {
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
                helper.deleteServer(serverList[index].id!);
                connectionStatus.removeAt(index);
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
      connectionStatus.add("");
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
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http.get(Uri.parse(serverList[index].localUrl));
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        navigateToServer(serverList[index].localUrl);
      }
    } on SocketException catch (_) {
      var response = await http.get(Uri.parse(serverList[index].externalUrl));
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        navigateToServer(serverList[index].externalUrl);
      }
    } on Exception catch (_) {
      setState(() {
        isLoading = false;
      });
      snackBar();
    }
  }

  Future<String> _checkConnection(index) async {
    try {
      var response = await http.get(Uri.parse(serverList[index].localUrl));
      if (response.statusCode == 200) {
        setState(() {
          connectionStatus[index] = "Local connection";
        });
        // connectionStatus.insert(index, "Local connection");
        return "Local connection";
      }
    } on SocketException catch (_) {
      var response = await http.get(Uri.parse(serverList[index].externalUrl));
      if (response.statusCode == 200) {
        // setState(() {
        //   connectionState = "External connection";
        // });
        connectionStatus.insert(index, 'External connection');
        return 'External connection';
        // return const Text('External connection');
      }
    } on Exception catch (_) {
      // setState(() {
      //   connectionState = "No connection";
      // });
      connectionStatus.insert(index, 'No connetion');
      return 'No connection';
      // return const Text('No connection');
    }

    return '';
    // return const Text('');
  }
}
