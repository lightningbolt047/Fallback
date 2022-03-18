import 'package:fallback/widgets_basic/text_widgets/screen_header_text.dart';
import 'package:flutter/material.dart';


class CustomSliverAppBar extends StatelessWidget {

  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final String titleText;

  const CustomSliverAppBar({Key? key,this.actions,this.leading,this.backgroundColor=Colors.transparent, required this.titleText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 50,
      leading: leading,
      leadingWidth: 0,
      bottom: PreferredSize(
        preferredSize: const Size(30,30),
        child: Align(alignment:Alignment.centerLeft,child: ScreenHeaderText(text: titleText)),
      ),
      actions: actions,
      backgroundColor: Colors.transparent,
    );
  }
}
