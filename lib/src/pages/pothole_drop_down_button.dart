import 'package:deteccion_de_baches/src/themes/color.dart';
import 'package:flutter/material.dart';

class PotholeDropDownButton extends StatefulWidget {
  double? width;
  String? selectedItem;
  List<String> items;
  Function callback;
  PotholeDropDownButton(
      {required this.width,
      required this.selectedItem,
      required this.items,
      required this.callback,
      Key? key})
      : super(key: key);

  @override
  State<PotholeDropDownButton> createState() => _PotholeDropDownButtonState();
}

class _PotholeDropDownButtonState extends State<PotholeDropDownButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(width: 3, color: PotholeColor.primary)),
              iconColor: PotholeColor.primary),
          value: widget.selectedItem,
          items: widget.items
              .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white))))
              .toList(),
          onChanged: (item) => setState(() {
            widget.selectedItem = item;
            widget.callback(widget.selectedItem);
          }),
        ));
  }
}
