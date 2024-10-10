// FIRST AND THE BEST WAY TO HANDLE API FOR THIS APP.
/* ===============================================================
            =============================================================== */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';

import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isloading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  void _loadData() async {
    final url = Uri.https(
        'flutter-prep-4c36c-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url);

      // handling if something went wrong.
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to load data. Please try again later.";
        });
      }

      // Handling the no data case if response is null from firebase.
      if (response.body == 'null') {
        setState(() {
          _isloading = false;
        });

        return;
      }

      final Map<String, dynamic> listOfData = json.decode(response.body);
      final List<GroceryItem> loadedData = [];

      for (final item in listOfData.entries) {
        final category = categories.entries
            .firstWhere(
                (category) => category.value.title == item.value['category'])
            .value;

        loadedData.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }

      setState(() {
        _groceryItems = loadedData;
        _isloading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Something went wronge. Please try again later.";
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutter-prep-4c36c-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something went wrong")));
      }

      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'No Items... Feel free to add.',
        style: TextStyle(color: Colors.white),
      ),
    );

    if (_isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}

  // ANOTHER WAY OF HANDLING API WITH FUTURE BUILDER, BUT ITS NOT SUITABLE WITH THIS APP.
         /* ===============================================================
            =============================================================== */

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shopping_list_app/data/categories.dart';

// import 'package:shopping_list_app/models/grocery_item.dart';
// import 'package:shopping_list_app/widgets/new_item.dart';

// class GroceryList extends StatefulWidget {
//   const GroceryList({super.key});

//   @override
//   State<GroceryList> createState() => _GroceryListState();
// }

// class _GroceryListState extends State<GroceryList> {
//   List<GroceryItem> _groceryItems = [];
//   late Future<List<GroceryItem>> _loadedItems;
  
//   @override
//   void initState() {
//     super.initState();

//     _loadedItems = _loadData();
//   }

//   Future<List<GroceryItem>> _loadData() async {
//     final url = Uri.https(
//         'flutter-prep-4c36c-default-rtdb.firebaseio.com', 'shopping-list.json');

//     final response = await http.get(url);

//     // handling if something went wrong.
//     if (response.statusCode >= 400) {
//       throw Exception('Failed to load data. Please try again later.');
//     }

//      if (response.body == 'null') {

//       return [];
//     }

//     final Map<String, dynamic> listOfData = json.decode(response.body);
//     final List<GroceryItem> loadedData = [];

//     for (final item in listOfData.entries) {
//       final category = categories.entries
//           .firstWhere(
//               (category) => category.value.title == item.value['category'])
//           .value;

//       loadedData.add(GroceryItem(
//           id: item.key,
//           name: item.value['name'],
//           quantity: item.value['quantity'],
//           category: category));
//     }

//     return loadedData;
//   }

//   void _addItem() async {
//     final newItem = await Navigator.of(context).push<GroceryItem>(
//       MaterialPageRoute(
//         builder: (ctx) => const NewItem(),
//       ),
//     );

//     if (newItem == null) {
//       return;
//     }

//     setState(() {
//       _groceryItems.add(newItem);
//     });
//   }

//   void _removeItem(GroceryItem item) async {
//     final index = _groceryItems.indexOf(item);

//     setState(() {
//       _groceryItems.remove(item);
//     });

//     final url = Uri.https('flutter-prep-4c36c-default-rtdb.firebaseio.com',
//         'shopping-list/${item.id}.json');

//     final response = await http.delete(url);

//     if (response.statusCode >= 400) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).clearSnackBars();
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Something went wrong")));
//       }

//       setState(() {
//         _groceryItems.insert(index, item);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Groceries'),
//         actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
//       ),
//       body: FutureBuilder(
//         future: _loadedItems,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 snapshot.error.toString(),
//               ),
//             );
//           }

//           if (snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No Items... Feel free to add.',
//                 style: TextStyle(color: Colors.white),
//               ),
//             );
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) => Dismissible(
//               key: ValueKey(snapshot.data![index].id),
//               onDismissed: (direction) {
//                 _removeItem(snapshot.data![index]);
//               },
//               child: ListTile(
//                 title: Text(snapshot.data![index].name),
//                 leading: Container(
//                   width: 24,
//                   height: 24,
//                   color: snapshot.data![index].category.color,
//                 ),
//                 trailing: Text(snapshot.data![index].quantity.toString()),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
