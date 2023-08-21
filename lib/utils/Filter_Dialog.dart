import 'package:blackcoffer_video/Screens/WelcomePage.dart';
import 'package:blackcoffer_video/constants/category_list.dart';
import 'package:flutter/material.dart';

class FilterDialogs extends StatefulWidget {
  const FilterDialogs({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialogs> {
  String? res;
  String selectedCategory = '';
  String selectedOrder = '';
  bool _groupValue = true;
  bool error = false;

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void selectOrder(String category) {
    setState(() {
      selectedOrder = category;
    });
  }

  List tempList = ['views', 'likes', 'dislikes'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: 300, // Adjust width as needed
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Center(
              child: Text(
                'Filter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Categories',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            SizedBox(
                height: 168, // Limit the height of the ListView
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: categoryList.map((category) {
                    return RadioListTile(
                      title: Text(category),
                      value: category,
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        selectCategory(value!);
                      },
                    );
                  }).toList(),
                )),
            const Divider(),
            const Center(
                child: Text(
              'OR',
              style: TextStyle(fontSize: 20),
            )),
            const Divider(),
            const Text(
              'Order by',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 168, // Limit the height of the ListView
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: tempList.map(
                  (category) {
                    return RadioListTile(
                      title: Text(category),
                      value: category,
                      groupValue: selectedOrder,
                      onChanged: (value) {
                        selectOrder(value!);
                      },
                    );
                  },
                ).toList(),
              ),
            ),
            const Center(
              child: Text(
                'Type',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            Row(
              children: [
                Radio(
                    value: false,
                    groupValue: _groupValue,
                    onChanged: (value) {
                      setState(() {
                        _groupValue = false;
                      });
                    }),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Title(
                      color: Colors.blueAccent,
                      child: const Text('Increasing')),
                ),
                Radio(
                    value: true,
                    groupValue: _groupValue,
                    onChanged: (value) {
                      setState(() {
                        _groupValue = true;
                      });
                    }),
                Title(
                    color: Colors.blueAccent, child: const Text('Decreasing')),
              ],
            ),
            const Divider(),
            error
                ? Center(
                    child: Text(
                      'Please dont select both values at same time',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                : Container(),
          ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: (() => setState(
                  () {
                    selectedCategory = '';
                    selectedOrder = '';
                    _groupValue = true;
                  },
                )),
            child: const Text('Reset')),
        TextButton(
          onPressed: () => {
            if (selectedCategory.isNotEmpty && selectedOrder.isNotEmpty)
              {
                setState(
                  () {
                    error = true;
                  },
                )
              }
            else
              {
                Navigator.pop(context),
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WelcomePage(
                            filter: (selectedOrder.isNotEmpty
                                ? selectedCategory
                                : ""),
                            desc: _groupValue,
                            whereC: (selectedCategory.isNotEmpty
                                ? "Category"
                                : null),
                            whereV: (selectedCategory)))),
              }
          },
          child: const Text("Submit"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
