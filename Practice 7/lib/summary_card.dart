import 'package:flutter/material.dart';

/// Shows the result of a successful sign-up.
///
/// It knows nothing about the screen: it only asks the box it was given
/// (LayoutBuilder) how wide it is.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birth,
  });

  final String name;
  final String email;
  final String group;
  final String birth;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Name'),
        subtitle: Text(name),
      ),
      ListTile(
        leading: const Icon(Icons.email),
        title: const Text('Email'),
        subtitle: Text(email),
      ),
      ListTile(
        leading: const Icon(Icons.group),
        title: const Text('Group'),
        subtitle: Text(group),
      ),
      ListTile(
        leading: const Icon(Icons.cake),
        title: const Text('Date of birth'),
        subtitle: Text(birth),
      ),
    ];

    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: tiles,
            );
          }
          return Column(mainAxisSize: MainAxisSize.min, children: tiles);
        },
      ),
    );
  }
}
