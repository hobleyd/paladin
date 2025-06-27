import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../database/library_db.dart';

class ShelfSetting extends StatefulWidget {
  int shelfId;

  ShelfSetting({Key? key, required this.shelfId}) : super(key: key);

  @override
  _ShelfSetting createState() => _ShelfSetting();
}

class _ShelfSetting extends State<ShelfSetting> {
  late LibraryDB _library;
  late Shelf _shelf;
  final TextEditingController typeAheadController = TextEditingController();

  static const List<int> shelfSizes = [10, 15, 20, 30];
  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryDB>(builder: (context, model, child) {
      _library = model;
      _shelf = _library.shelves[widget.shelfId-1];
      typeAheadController.text = _shelf.name;

      return Row(children: [
            _getShelfType(),
            Expanded(child: _getShelfName()),
          ]);
    });
  }

  Widget _getShelfName() {
    return InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          labelText: 'Name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        child: TypeAheadField(
          minCharsForSuggestions: 3,
          itemBuilder: (context, Map<String, dynamic> suggestion) {
            return Padding(padding: const EdgeInsets.only(top: 3, bottom: 3, left: 6), child: Text(suggestion[Shelf.shelfTableColumn[_shelf.type]]));
          },
          onSelected: (Map<String, dynamic> suggestion) {
            _shelf.name = suggestion[Shelf.shelfTableColumn[_shelf.type]];
            typeAheadController.text = _shelf.name;
            _library.updateShelf(_shelf);
          },
          suggestionsCallback: (String pattern) async {
            return _library.getShelfName(Shelf.shelfTable[_shelf.type]!, Shelf.shelfTableColumn[_shelf.type]!, pattern, _shelf.size);
          },
          textFieldConfiguration: TextFieldConfiguration(
              autofocus: false,
              controller: typeAheadController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              enabled: !(_shelf.type == CollectionType.CURRENT || _shelf.type == CollectionType.RANDOM)),
        ));
  }

  Widget _getShelfType() {
    return SizedBox(
        width: 150,
        child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              labelText: 'Shelf Type',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            child: DropdownButtonHideUnderline(child: DropdownButton(
              value: _shelf.type,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 10),
              onChanged: (value) {
                _shelf.type = value!;
                _shelf.name = (_shelf.type == CollectionType.CURRENT || _shelf.type == CollectionType.RANDOM) ? Collection.collectionTypes[value]! : "";
                _library.updateShelf(_shelf);
              },
              items: Collection.collectionTypes.entries.map((item) {
                return DropdownMenuItem(value: item.key, child: Text(item.value));
              }).toList(),
            ))));
  }

  Widget _getShelfSize() {
    return SizedBox(
        width: 50,
        child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              labelText: 'Size',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            child: DropdownButtonHideUnderline(child: DropdownButton(
              value: _shelf.size,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 10),
              onChanged: (value) {
                _shelf.size = value!;
                _library.updateShelf(_shelf);
              },
              items: shelfSizes.map((item) {
                return DropdownMenuItem(value: item, child: Text('$item'));
              }).toList(),
            ))));
  }
}