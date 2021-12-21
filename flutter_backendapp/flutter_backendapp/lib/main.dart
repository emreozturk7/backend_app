import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_backendapp/create.dart';
import 'package:flutter_backendapp/note.dart';
import 'package:flutter_backendapp/update.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(
        title: 'Django App',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Client client = http.Client();
  List<Note> notes = [];

  @override
  void initState() {
    _retrieveNotes();
    super.initState();
  }

  _retrieveNotes() async {
    notes = [];

    List response = json.decode(
        (await client.get(Uri.parse('http://127.0.0.1:8000/notes/'))).body);
    for (var element in response) {
      notes.add(Note.fromMap(element));
    }
    setState(() {});
  }

  void _deleteNote(int id) {
    client.delete(Uri.parse('http://127.0.0.1:8000/notes/$id/delete/'));
    _retrieveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _retrieveNotes();
        },
        child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(notes[index].note),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UpdatePage(
                    client: client,
                    id: notes[index].id,
                    note: notes[index].note,
                  ),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteNote(notes[index].id),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreatePage(
              client: client,
            ),
          ),
        ),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
