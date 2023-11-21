import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'screens/task_details.dart';
import 'const/const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = PARSE_KEY_Application_Id;
  final keyClientKey = PARSE_KEY_Client_Id;
  final keyParseServerUrl = PARSE_KEY_ParseServer_Url;

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todoControllerTitle = TextEditingController();
  final todoControllerDesc = TextEditingController();

  void addTask() async {
    if (todoControllerTitle.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Empty title"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveTask(todoControllerTitle.text, todoControllerDesc.text);
    setState(() {
      todoControllerTitle.clear();
      todoControllerDesc.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Task List"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: todoControllerTitle,
                      decoration: InputDecoration(
                          labelText: "Add task title",
                          labelStyle: TextStyle(color: Colors.blueGrey)),
                    ),
                  ),
                ],
              )),
              Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: todoControllerDesc,
                      decoration: InputDecoration(
                          labelText: "Add task Details",
                          labelStyle: TextStyle(color: Colors.blueGrey)),
                    ),
                  ),
                ],
              )),
              Container(
              padding: EdgeInsets.fromLTRB(17.0, 17.0, 17.0, 17.0),
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        onPrimary: Colors.white,
                        primary: Colors.blueAccent,
                      ),
                      onPressed: addTask,
                      child: Text("Add Task"))
                ],
              )),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getTasks(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator()),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error..."),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No Data..."),
                          );
                        } else {
                          return ListView.builder(
                              padding: EdgeInsets.only(top: 10.0),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                //*************************************
                                //Get Parse Object Values
                                final varTodo = snapshot.data![index];
                                final varTitle = varTodo.get<String>('title')!;
                                final varDone =  varTodo.get<bool>('done')!;
                                //*************************************

                                return ListTile(
                                  title: Text(varTitle),
                                  leading: CircleAvatar(
                                    child: Icon(
                                        varDone ? Icons.check : Icons.error),
                                    backgroundColor:
                                    varDone ? Colors.green : Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                          value: varDone,
                                          onChanged: (value) async {
                                            await updateTask(
                                                varTodo.objectId!, value!);
                                            setState(() {
                                              //Refresh UI
                                            });
                                          }),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
                                          await deleteTask(varTodo.objectId!);
                                          setState(() {
                                            final snackBar = SnackBar(
                                              content: Text("Task deleted!"),
                                              duration: Duration(seconds: 2),
                                            );
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(snackBar);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(),
                                        settings: RouteSettings(arguments: varTodo),
                                      ),
                                    );
                                  },
                                );
                              });
                        }
                    }
                  }))
        ],
      ),
    );
  }

  Future<void> saveTask(String title, String desc) async {
    final todo = ParseObject('Task')..set('title', title)
      ..set('description', desc)
      ..set('done', false);
    await todo.save();
    //await Future.delayed(Duration(seconds: 1), () {});
  }

  Future<List<ParseObject>> getTasks() async {
    QueryBuilder<ParseObject> queryTodo =
    QueryBuilder<ParseObject>(ParseObject('Task'));
    final ParseResponse apiResponse = await queryTodo.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateTask(String id, bool done) async {
    var todo = ParseObject('Task')
      ..objectId = id
      ..set('done', done);
    await todo.save();
  }

  Future<void> deleteTask(String id) async {
    var todo = ParseObject('Task')..objectId = id;
    await todo.delete();
  }
}