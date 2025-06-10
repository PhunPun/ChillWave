import 'package:chillwave/themes/colors/colors.dart';
import 'package:chillwave/widgets/top_bxh_list.dart';
import 'package:flutter/material.dart';

class TopBxhList100 extends StatelessWidget {
  const TopBxhList100({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Những bài hát hot nhất', 
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: Color(MyColor.se5)
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
          colors: [Color(MyColor.se2), Color(MyColor.pr2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: ListView(
          children: [
            TopBxhList(topNumber: 100, full: true,)
          ],
        ),
      ),
    );
  }
}