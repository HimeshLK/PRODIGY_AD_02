import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SQL_Helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Task list on active
  List<Widget> onActive = [];
  List<Widget> completed = [];
  int indexNo = 0;
  @override
  late BuildContext context;

  TextEditingController editControllers = TextEditingController();

  // List of completed and incomplete list state
  void showBottomSheetMake(String details, int indexNumber) {
    editControllers.text = details;
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              width: double.infinity,
              //COLOUR : Edit delete Bg
              color: Color.fromARGB(255, 248, 230, 204),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Heading
                  const Padding(
                      padding: EdgeInsets.all(25),
                      child: Text(
                        "Edit or Remove Your task !",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      )),
                  // Content values over here
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 25),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      controller: editControllers,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Update button
                        ElevatedButton.icon(
                          onPressed: () async {
                            await SqlHelper.updateDetails(
                                indexNumber, editControllers.text);
                            Navigator.of(context).pop();
                            updateTaskList();
                          },
                          icon: const Icon(Icons.update),
                          label: const Text("Update"),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      Color.fromARGB(255, 86, 245, 86))),
                        ),

                        // Delete Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            await SqlHelper.deleteRecord(indexNumber);
                            Navigator.of(context).pop();
                            updateTaskList();
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text("Delete"),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      Color.fromARGB(255, 241, 85, 74))),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  // Add Widgets
  void addActive(int indexNumber, {String? date, String? details}) {
    // Get current data and time
    onActive.add(InkWell(
      onLongPress: () async {
        List<Map<String, Object?>>? results =
            await SqlHelper.getOne(indexNumber);
        Map map = results![0];
        showBottomSheetMake(map['details'].toString(), indexNumber);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Main Content in here
          Row(
            children: [
              Checkbox(
                  value: false,
                  onChanged: (value) {
                    // when click on the click icon
                    SqlHelper.changeState(1, indexNumber);
                    updateTaskList();
                  }),
              Expanded(
                  child: Text(
                details!,
                style: const TextStyle(
                    fontSize: 20, color: Color.fromARGB(255, 0, 0, 0)),
              ))
            ],
          ),

          // Date created ant time
          Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                date!,
                style: const TextStyle(
                    fontSize: 15, color: Color.fromARGB(255, 0, 0, 0)),
              ))
        ]),
      ),
    ));
  }

  void addCompleted(int indexNumber, {String? date, String? details}) {
    // Add Completed Widgets
    completed.add(InkWell(
      onLongPress: () async {
        List<Map<String, Object?>>? results =
            await SqlHelper.getOne(indexNumber);
        Map map = results![0];
        showBottomSheetMake(map['details'].toString(), indexNumber);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(158, 51, 51, 51),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Main Content in here
          Row(
            children: [
              Checkbox(
                  value: true,
                  onChanged: (value) {
                    // when click on the click icon
                    SqlHelper.changeState(0, indexNumber);
                    updateTaskList();
                  }),
              Expanded(
                  child: Text(
                details!,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    decoration: TextDecoration.lineThrough),
              ))
            ],
          ),

          // Date created ant time
          Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                date!,
                style: const TextStyle(
                    fontSize: 15, color: Color.fromARGB(255, 0, 0, 0)),
              ))
        ]),
      ),
    ));
  }

// Update function
  Future<void> updateTaskList() async {
    print('Inside update task list');
    onActive.clear();
    completed.clear();
    List<Map<String, dynamic>> taskList = await SqlHelper.getAllData();
    setState(() {
      for (final task in taskList) {
        // Checking for maxvalue of the index
        if (indexNo <= task['indexId']) {
          indexNo = task['indexId'] + 1;
        }
        if (task['completed'] == 0) {
          addActive(task['indexId'],
              date: task['dateTime'], details: task['details']);
        } else {
          addCompleted(task['indexId'],
              date: task['dateTime'], details: task['details']);
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    updateTaskList();
    super.initState();
  }

  TextEditingController taskController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  backgroundColor: Color.fromARGB(255, 246, 247, 190),
                  title: const Text(
                    "Add New Task",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Input textField of task details
                      TextField(
                        controller: taskController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: "Enter Your Task Here",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.black87, width: 15)),
                        ),
                      ),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  if (taskController.text.isNotEmpty) {
                                    // Fetch system date
                                    DateTime dateTime = DateTime.now();
                                    String dateTimeStr = dateTime.toString();
                                    if (await SqlHelper.insertTasks(
                                        ++indexNo,
                                        taskController.text,
                                        dateTimeStr.substring(
                                            0, dateTimeStr.length - 7))) {
                                      Navigator.of(context).pop();
                                      taskController.text = "";
                                      updateTaskList();
                                    }
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateColor.resolveWith((states) =>
                                          const Color.fromARGB(255, 1, 255, 9)),
                                ),
                                child: const SizedBox(
                                    width: 50,
                                    child: Center(child: Text("Add")))),

                            //Pop up box in adding new task
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                taskController.text = "";
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith(
                                    (states) =>
                                        const Color.fromARGB(255, 255, 17, 0)),
                              ),
                              child: const SizedBox(
                                  width: 50,
                                  child: Center(child: Text("Cancel"))),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              });
          // addActive(indexNo++);
        },
        //Add button det
        backgroundColor: Color.fromRGBO(37, 255, 48, 1),
        child: const Icon(
          Icons.add_task_rounded,
          size: 30,
        ),
      ),

      //Full BG
      backgroundColor: Color.fromARGB(255, 0, 70, 73),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Heading topic

          Container(
              width: double.infinity,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 50, bottom: 5),
              child: const Text(
                "Hello!",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              )),
          Container(
              width: double.infinity,
              color: Color.fromARGB(50, 0, 0, 0),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(
                  top: 20, bottom: 5, left: 10, right: 10),
              child: const Text(
                "This world of dew is a world of dew, and yet, and yet.",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 20),
                textAlign: TextAlign.center,
              )),
          Container(
              width: double.infinity,
              alignment: Alignment.topCenter,
              color: Color.fromARGB(50, 0, 0, 0),
              padding: const EdgeInsets.only(top: 10, bottom: 20, left: 10),
              child: const Text(
                "- Kobayashi Issa | Haiku By Kobayashi",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w100,
                    fontSize: 15),
                textAlign: TextAlign.center,
              )),
          Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 30, bottom: 25),
              child: const Text(
                "Today's Tasks",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 32),
              )),

          //
          Expanded(
              child: SingleChildScrollView(
            child: Column(children: [
              // On active column
              Column(
                children: onActive,
              ),
              Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 1, bottom: 1),
                  child: const Text(
                    "Tap and hold to Update or Remove the task ",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 12),
                  )),
              const Padding(
                  padding: EdgeInsets.all(10),
                  child: Divider(
                    color: Color.fromARGB(153, 182, 255, 255),
                    thickness: 3,
                  )),
              Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 1, bottom: 1),
                  child: const Text(
                    "Cheers! You have completed,",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 12),
                  )),

              // Completed column
              Column(
                children: completed,
              )
            ]),
          ))
        ],
      ),
    );
  }
}
