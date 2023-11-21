import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
class DetailScreen extends StatelessWidget {
  const DetailScreen();

  @override
  Widget build(BuildContext context) {
    final varTodo = ModalRoute.of(context)!.settings.arguments as ParseObject;
    final varTitle = varTodo.get<String>('title')!;
    final varDone = varTodo.get<bool>('done')!;
    final varDesc = varTodo.get<String>('description')!;
    var taskStatus = 'Open';
    var taskStatusColor = Colors.red;
    if(varDone){
      taskStatus = 'Done';
      taskStatusColor = Colors.green;
    }
   
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: 
       new Container(
        padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),

        child: new Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                 margin: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "Status:",
                   style: TextStyle(fontSize: 10),
                ),
              ),
            ),
             Align(
              alignment: Alignment.centerLeft,
              child: Container(
                color: taskStatusColor,
                child: Text(
                  taskStatus,
                   style: TextStyle(fontSize: 15),
                ),
              ),
            ),
             Align(
              alignment: Alignment.centerLeft,
              child: Container(
                 margin: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "Title:",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Text(
                  varTitle,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'Description:',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
               
                child: Text(
                  varDesc,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}