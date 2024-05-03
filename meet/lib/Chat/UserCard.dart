import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  final String text2;
  const UserCard({
    super.key,
    required this.text,
    required this.text2,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // color: Theme.of(context).colorScheme.secondary,
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.white),
            SizedBox(width: 17),
            Text(text, style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            SizedBox(width: 17),
            Text("# ${text2}", style: TextStyle(color: Colors.grey, fontSize: 20, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
