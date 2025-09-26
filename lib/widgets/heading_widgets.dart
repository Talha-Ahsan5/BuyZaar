import 'package:flutter/material.dart';

class HeadingWidgets extends StatelessWidget {
  final String titleHeading, subHeadingTitle, textBtn;
  final VoidCallback onTap;
  const HeadingWidgets({
    super.key,
    required this.titleHeading,
    required this.subHeadingTitle,
    required this.textBtn,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleHeading, // 'Categories',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subHeadingTitle, // 'About me',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.blue),
              ),
              child: GestureDetector(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                   textBtn, // 'See more >',
                    style: TextStyle(color: Colors.blue[400]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
