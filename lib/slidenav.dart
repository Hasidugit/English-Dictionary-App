import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_dictionary_wordcollection/homepage.dart';

class Sidenav extends StatefulWidget {
  const Sidenav({super.key});

  @override
  State<Sidenav> createState() => _SidenavState();
}

class _SidenavState extends State<Sidenav> {
  // int currentIndex = Random().nextInt(GetMotivations().getMotivations().length);
  late Timer timer;
  late DateTime lastDate;

  @override
  // void initState() {
  //   super.initState();
  //   lastDate = DateTime.now();
  //   updateIndex();
  //   timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     updateIndex();
  //   });
  // }

  // void updateIndex() {
  //   final now = DateTime.now();
  //   if (now.day != lastDate.day) {
  //     setState(() {
  //       currentIndex =
  //           (currentIndex + 1) % GetMotivations().getMotivations().length;
  //       lastDate = now;
  //     });
  //   }
  // }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    "https://th.bing.com/th/id/OIP.BNn7Npv3oD3QU_5sjYpFYAHaE7?w=2000&h=1333&rs=1&pid=ImgDetMain"),
              ),
            ),
          ),
          const Divider(
            color: Color.fromARGB(255, 181, 160, 76),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: RichText(
          //     text: TextSpan(
          //       text: 'Hello ',
          //       style: DefaultTextStyle.of(context).style,
          //       children: <TextSpan>[
          //         TextSpan(
          //             text:
          //                 "\" ${GetMotivations().getMotivations()[currentIndex].talk} \" \t \t \n",
          //             style: const TextStyle(
          //                 fontWeight: FontWeight.bold, fontSize: 18)),
          //         TextSpan(
          //             text: GetMotivations()
          //                         .getMotivations()[currentIndex]
          //                         .talk ==
          //                     "Unkown"
          //                 ? "  "
          //                 : "  -${(GetMotivations().getMotivations()[currentIndex].said)}",
          //             style: const TextStyle(fontSize: 18)),
          //       ],
          //     ),
          //   ),
          // ),
          const Divider(
            color: Color.fromARGB(255, 181, 160, 76),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Center(
                      child: Text(
                        "Rate us",
                        style: TextStyle(color: Colors.red, fontSize: 30),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Please rate our app on the store!",
                          style: TextStyle(fontSize: 20),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => const Icon(
                                Icons.star,
                                color: Color.fromARGB(255, 215, 203, 71),
                                size: 35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Add logic to redirect to store for rating
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("Rate now"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const ListTile(
              title: Text("Rate us!"),
              leading: Icon(Icons.star_rate_sharp),
            ),
          ),

          GestureDetector(
            onDoubleTap: () {},
            child: const ListTile(
              title: Text(" More Apps"),
              leading: Icon(Icons.add),
            ),
          ),
          GestureDetector(
            onDoubleTap: () {},
            child: const ListTile(
              title: Text(" Share"),
              leading: Icon(Icons.share),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.10,
          ),
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                )),
            onDoubleTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: const Text(
                      "Do you Want to Exit  ",
                      style: TextStyle(color: Colors.red, fontSize: 25),
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () {
                          if (Platform.isAndroid) {
                            SystemNavigator.pop();
                          } else if (Platform.isIOS) {
                            exit(0);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              const Color.fromARGB(255, 236, 236,
                                  236)), // Change to your desired color
                          foregroundColor: WidgetStateProperty.all(
                              const Color.fromARGB(255, 1, 1,
                                  1)), // Change text color (optional)
                        ),
                        child: const Text("yes"),
                      ),
                      FilledButton(
                          autofocus: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                const Color.fromARGB(255, 206, 174,
                                    174)), // Change to your desired color
                            foregroundColor: WidgetStateProperty.all(
                                const Color.fromARGB(255, 1, 1,
                                    1)), // Change text color (optional)
                          ),
                          child: const Text("No"))
                    ],
                  );
                },
              );
            },
            child: const Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CircleAvatar(
                    child: Icon(Icons.close),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
