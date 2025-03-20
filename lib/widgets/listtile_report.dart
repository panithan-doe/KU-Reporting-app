import 'package:flutter/material.dart';

class ListTileReport extends StatelessWidget {
  const ListTileReport({
    super.key,
    required this.image,
    required this.title,
    required this.location,
    required this.status,
    required this.category,
    required this.postDate,

  });

  final String image;
  final String title;
  final String location;
  final String status;
  final String category;
  final String postDate;
  

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // ... push report_info screen
      },
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Leading + Title + Subtitle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Leading
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: Image.asset(image, fit: BoxFit.cover,),
                    )
                    
                  ),
                  
                  SizedBox(
                    width: 14,
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Title
                      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      // Subtitle
                      Text(location, style: TextStyle(color: Colors.grey),),
                    ],
                  )
                ],
              ),

              // End of list
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Status
                  Text(status, style: TextStyle(color: 
                    status == "In progress" ? Colors.orange
                      : status == "Pending" ? Colors.blue
                      : status == "Canceled" ? Colors.red
                      : status == "Completed" ? Colors.green
                      : Colors.grey
                    ),),
                  // Post Date
                  Text('Post date: $postDate', style: TextStyle(color: Colors.grey),),
                ],
              )
            ],
          ),
        )
      ),
    );
    
  }

}