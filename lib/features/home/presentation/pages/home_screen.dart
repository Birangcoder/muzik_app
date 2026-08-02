import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Text('jordan', style: Theme.of(context).textTheme.titleLarge,),
              Spacer(),
              Icon(Icons.person)
            ],
          ),
          Text('Home screen'),
        ]
      ),
    );
  }
}
