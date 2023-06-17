import 'package:database/required_components.dart';
import 'package:database/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:database/required_components.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQFlite',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _privatelist = [];

  void _refreshList() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _privatelist = data;
      _refreshList();
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);

    _refreshList();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshList();
  }

  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshList();
  }

  SizedBox sizedBoxWidget(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
    );
  }

  void dataForm(int? id) async {
    if (id == null) {
      _titleController.clear();
      _descriptionController.clear();
    }
    if (id != null) {
      final existingValue =
          _privatelist.firstWhere((element) => element['id'] == id);
      _titleController.text = existingValue['title'];
      _descriptionController.text = existingValue['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addItem();
                      }
                      if (id != null) {
                        await _updateItem(id);
                      }
                      _titleController.text = '';
                      _descriptionController.text = '';
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SQL Test")),
      body: ListView.builder(
          itemCount: _privatelist.length,
          itemBuilder: (BuildContext context, int index) => Card(
                color: Colors.lightBlueAccent,
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(_privatelist[index][title]),
                  subtitle: Text(_privatelist[index][description]),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => dataForm(_privatelist[index][id]),
                      ),
                      IconButton(
                          onPressed: () =>
                              _deleteItem(_privatelist[index][id]),
                          icon: const Icon(Icons.delete))
                    ]),
                  ),
                ),
              )),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add), onPressed: () => dataForm(null)),
    );
  }
}
