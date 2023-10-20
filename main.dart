import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

final red1 = Color.fromARGB(255, 255, 0, 0);
final green1 = Color.fromARGB(255, 31, 172, 31);
final blue1 = Color(0x826FBDDE);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true, // Enable local cache
  );
  runApp(FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  FigmaToCodeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Data has been loaded, now render the app
          return MaterialApp(
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
            ),
            home: Scaffold(
              body: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            Iphone14ProMax34(searchResults),
                            // Add more widgets here if needed
                          ],
                        ),
                      ),
                      HomeBarWidget(),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // Handle errors
          return Center(child: Text('Error loading data: ${snapshot.error}'));
        } else {
          // Data is still loading
          return CircularProgressIndicator();
        }
      },
    );
  }

  List<DocumentSnapshot> searchResults = [];

  Future<void> fetchData() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('medicine').get();

      if (querySnapshot.docs.isNotEmpty) {
        // Use querySnapshot.docs to populate searchResults or perform other operations
        searchResults = querySnapshot.docs;
      } else {
        // Handle the case where no data was found
        searchResults = [];
      }
    } catch (e) {
      print('Error loading data: $e');
      // Instead of throwing the error, you can choose to handle it or rethrow it here
      // throw e; // Rethrow the error if needed
    }
  }
}

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> searchResults = [];

  Future<void> searchName(String name) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('medicine')
          .where('name', isEqualTo: name.toLowerCase())
          .get();
      setState(() {
        searchResults = querySnapshot.docs;
      });
    } catch (e) {
      print('Error searching: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        child: Align(
          child: Container(
            width: 400,
            padding: EdgeInsets.all(60),
            decoration: ShapeDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Enter name to search',
                    labelStyle: TextStyle(color: Colors.blue),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    String nameToSearch = _searchController.text;
                    if (nameToSearch.isNotEmpty) {
                      searchName(nameToSearch.toLowerCase());
                    }
                  },
                  child: Text('Search'),
                ),
                SizedBox(height: 16),
                if (searchResults.isNotEmpty)
                  Column(
                    children: searchResults
                        .map(
                          (result) => Container(
                            padding: EdgeInsets.all(20),
                            margin: EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Image.network(
                                  result[
                                      'image'], // Use the 'imageUrl' field from Firestore
                                  width: 60, // Adjust width as needed
                                  height: 70, // Adjust height as needed
                                  fit: BoxFit.cover, // Adjust fit as needed
                                ),
                                ListTile(
                                  title: Text(
                                    result['name'],
                                    style: TextStyle(
                                      color: red1, // Change the text color here
                                      fontSize:
                                          18, // Adjust the font size as needed
                                    ),
                                  ),
                                  subtitle: Text(
                                    result['desc'],
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0,
                                          0), // Change the text color here
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Capture user input data from the interface
                                    String medName = _searchController.text
                                        .toLowerCase(); // Assuming this is the medicine name

                                    // Create a reference to the document with the name "1" in the "patient" collection
                                    DocumentReference patientDocument =
                                        FirebaseFirestore.instance
                                            .collection('patient')
                                            .doc('1');

                                    try {
                                      // Update the document with the new medicine name
                                      await patientDocument
                                          .update({'med_name': medName});
                                      // Data updated successfully
                                      print(
                                          'Medicine name updated successfully.');
                                    } catch (error) {
                                      // Handle any errors that occur during the process
                                      print(
                                          'Error updating medicine name: $error');
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.hovered)) {
                                          // Color when hovered
                                          return red1;
                                        }
                                        // Default color
                                        return Colors.blue;
                                      },
                                    ),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      shape: BoxShape
                                          .circle, // Make the button circular
                                      color: Colors.blue, // Default color
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                          10.0), // Adjust padding as needed
                                      child: Icon(
                                        Icons
                                            .add, // Replace with your desired icon
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  )
                else if (_searchController.text.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        "\nMedicine not found, Would you like to add it?\n",
                        style: TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String nameToSearch = _searchController.text;
                          if (nameToSearch.isNotEmpty) {
                            searchName(nameToSearch);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home),
            color: Color(0xFF4282A5),
            onPressed: () {
              // Handle home button tap
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            color: Color(0xFF4282A5),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SearchWidget();
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.message),
            color: Color(0xFF4282A5),
            onPressed: () {
              // Handle favorite button tap
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            color: Color(0xFF4282A5),
            onPressed: () {
              // Handle profile button tap
            },
          ),
        ],
      ),
    );
  }
}

class Iphone14ProMax34 extends StatelessWidget {
  final List<DocumentSnapshot> searchResults;

  Iphone14ProMax34(this.searchResults);

  // Define styles for text widgets
  final TextStyle medNameStyle = TextStyle(
    fontSize: 18,
    color: red1,
  );

  final TextStyle medInfoStyle = TextStyle(
    fontSize: 12,
    color: green1,
  );

  // Define box shadow for the container
  final List<BoxShadow> containerBoxShadow = [
    BoxShadow(
      color: Colors.grey.withOpacity(0.5),
      spreadRadius: 2,
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('patient').doc('1').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        String medName = snapshot.data!['med_name'] ?? '';
        String medImage = '';
        String medStart = '';
        String medEnd = '';
        String medDesc = '';

        if (medName.isNotEmpty) {
          for (var result in searchResults) {
            if (result['name'] == medName) {
              medImage = result['image'] ?? '';
              medStart = result['start'] ?? '';
              medEnd = result['end'] ?? '';
              medDesc = result['desc'] ?? '';
              break;
            }
          }
        }

        return Column(
          children: [
            Container(
              width: 430,
              height: 932,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  // ... (previous children)

                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 430,
                      height: 932,
                      decoration: BoxDecoration(color: Color(0xB22A91C0)),
                    ),
                  ),
                  Positioned(
                    left: -67,
                    top: 82,
                    child: Container(
                      width: 564,
                      height: 1001,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("Assets/back.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: -2,
                    child: Container(
                      width: 430,
                      height: 93,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255)), //HEADER
                    ),
                  ),
                  Positioned(
                    left: 125,
                    top: 24,
                    child: Text(
                      'shahds’s \nCurrent Medicines',
                      style: TextStyle(
                        color: Color.fromARGB(204, 127, 78, 78),
                        fontSize: 20,
                        fontFamily: 'JejuGothic',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 48,
                    top: 10,
                    child: Container(
                      width: 72,
                      height: 70,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: AssetImage("Assets/Ellipse 2.png"),
                          fit: BoxFit.cover,
                        ),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 253.82,
                    top: 878.62,
                    child: Container(
                      width: 24,
                      height: 24,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        // Use box shadow defined earlier
                        boxShadow: containerBoxShadow,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 13,
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("Assets/doctor__circle_2 5.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: -5,
                    top: 200,
                    child: Container(
                      width: 271,
                      height: 27,
                      decoration: BoxDecoration(color: blue1),
                    ),
                  ),
                  Positioned(
                    left: 45,
                    top: 125,
                    child: Visibility(
                      visible: medName.isNotEmpty,
                      child: Container(
                        width: 280,
                        height: 250,
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          // Use box shadow defined earlier
                          boxShadow: containerBoxShadow,
                        ),
                        child: Column(
                          children: [
                            if (medImage.isNotEmpty)
                              Image.network(
                                medImage,
                                width: 60,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            Text(
                              '\nMedicine Name: $medName\n',
                              style: medNameStyle,
                            ),
                            if (medStart.isNotEmpty)
                              Text(
                                'Start Date: $medStart',
                                style: medInfoStyle,
                              ),
                            if (medEnd.isNotEmpty)
                              Text(
                                'End Date: $medEnd \n',
                                style: medInfoStyle,
                              ),
                            if (medDesc.isNotEmpty)
                              Text(
                                'Description: $medDesc',
                                style: medInfoStyle,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
