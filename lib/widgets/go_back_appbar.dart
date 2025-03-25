import 'package:flutter/material.dart';

class GoBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GoBackAppBar({
    super.key,
    required this.titleText,
  });

  final String titleText;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFF2F5F7),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey,
          height: 0.5,
        ),
      ),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(titleText),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
