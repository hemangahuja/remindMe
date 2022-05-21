import 'package:flutter/material.dart';

class MyInput extends StatefulWidget {
  final Function(String) onSubmitted;
  const MyInput({Key? key, required this.onSubmitted}) : super(key: key);

  @override
  State<MyInput> createState() => _MyInputState();
}

class _MyInputState extends State<MyInput> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: TextFormField(
        onFieldSubmitted: (value) => {
          //clear the input

          widget.onSubmitted(value)
        },
        decoration: const InputDecoration(
          labelText: 'Enter some text',
        ),
      ),
    );
  }
}
