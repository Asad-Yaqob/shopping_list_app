import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return NewItemState();
  }
}

class NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();

  var _enteredTitle = '';
  var _intialQuantity = 1;
  var _selectedCategory = categories[Categories.fruit]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      final url = Uri.https('flutter-prep-4c36c-default-rtdb.firebaseio.com',
          'shopping-list.json');

        final response = await http.post(url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(
              {
                'name': _enteredTitle,
                'quantity': _intialQuantity,
                'category': _selectedCategory.title,
              },
            ));

        final Map<String, dynamic> resData = json.decode(response.body);

        if (!context.mounted) {
          return;
        }

        Navigator.of(context).pop(GroceryItem(
            id: resData['name'],
            name: _enteredTitle,
            quantity: _intialQuantity,
            category: _selectedCategory));
    
      // Navigator.of(context).pop(GroceryItem(
      //   id: DateTime.now().toString(),
      //   name: _enteredTitle,
      //   quantity: _intialQuantity,
      //   category: _selectedCategory,
      // ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('title'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return "Must be between 1 and 50 characters.";
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _enteredTitle = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(label: Text('Quantity')),
                        initialValue: _intialQuantity.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return "Must be a valid, positive number.";
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _intialQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                          value: _selectedCategory,
                          items: [
                            // To loop through the map, we need to use .entries
                            for (final category in categories.entries)
                              DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Text(category.value.title)
                                  ],
                                ),
                              )
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          }),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: _isSending ? null : _saveItem,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Add Item'),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
