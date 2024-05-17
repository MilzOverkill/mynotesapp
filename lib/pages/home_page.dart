

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/services/firestore.dart';

class HomePage1 extends StatefulWidget {
  const HomePage1({super.key});

  @override
  State<HomePage1> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage1> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();

  //text controller
  final TextEditingController textcontroller = TextEditingController();

  // open a dialog box to add a note
  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textcontroller,
              ),
              actions: [
                //button to save
                ElevatedButton(
                  onPressed: () {

                    // add a new note
                    if(docID == null){
                      firestoreService.addNote(textcontroller.text);

                    }

                    //update an existing note
                    else{
                      firestoreService.updatenote(docID,textcontroller.text);
                    }
                    


                    //clear text controller
                    textcontroller.clear();

                    //close the box
                    Navigator.pop(context);
                  },
                  child: Text("Add"),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          //if we have data, get all the docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            //display as a list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
              // get each individual doc

              DocumentSnapshot document = notesList[index];
              String docID = document.id;

              //get note from each doc

              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String noteText = data['note'];

              //display as a list title
              return ListTile(
                title: Text(noteText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    //update button

                    IconButton(
                      onPressed: ()=> openNoteBox(docID:docID),
                      icon: const Icon(Icons.settings),
                    ),

                    //delete button
                    IconButton(
                      onPressed: ()=> firestoreService.deletenote(docID),
                      icon: const Icon(Icons.delete)
                ),




                ],)
                
                
              );
            });
          } else {
            //if there is no data return nothing
            return const Text("No notes...");
          }
        },
      ),
    );
  }
}
