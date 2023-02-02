import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multiassistant/helper/helper.dart';
import 'package:multiassistant/helper/model.dart';
import 'package:sqflite/sqflite.dart' show Database;
import 'package:multiassistant/server_detail.dart';
import 'package:multiassistant/web_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
    }

    helper.getServersMapList();
    helper.getServersList();

    return Scaffold(
        appBar: AppBar(
          title: const Text("MultiAssistant"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                navigateToDetail(Server('', '', ''), 'Add Server');
              },
            ),
          ],
        ),
        body: serverList.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No Data",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              )
            : Container(
                child: getServersList(),
              ));
  }

  void updateListView() {
    final Future<Database> dbFuture = helper.initializeDb();
    dbFuture.then((database) {
      Future<List<Server>> serverListFuture = helper.getServersList();
      serverListFuture.then((serverList) {
        setState(() {
          this.serverList = serverList;
          count = serverList.length;
          debugPrint('Count: $count');
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
            motion: const BehindMotion(),
            // dismissible: DismissiblePane(
            //   onDismissed:
            // ),
            children: [
              SlidableAction(
                icon: Icons.edit,
                label: 'Edit',
                backgroundColor: Colors.blue,
                onPressed: (context) {
                  navigateToDetail(serverList[index], 'Edit Server');
                },
              ),
            ],
          ),
          endActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                icon: Icons.delete,
                label: 'Delete',
                backgroundColor: Colors.red,
                onPressed: (context) {
                  _delete(context, serverList[index]);
                },
              ),
            ],
          ),
          child: ListTile(
            // leading: const Icon(MdiIcons.homeAssistant, size: 30.0),
            title: Text(serverList[index].name,
                style: const TextStyle(fontSize: 20.0)),
            subtitle: Text(
              serverList[index].localUrl,
            ),
            trailing: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPage(
                        serverList[index].localUrl,
                        serverList[index].externalUrl,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward_ios)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewPage(
                    serverList[index].localUrl,
                    serverList[index].externalUrl,
                  ),
                ),
              );
            },
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
}
