import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

import 'model/board.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Community Board',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

      ),
      home:  MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Board>boardMessages=[];
  late Board board;
  late DatabaseReference  databaseReference;
  final FirebaseDatabase database= FirebaseDatabase.instance;
  late final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    board= Board("","");
    databaseReference=database.ref().child("community_board");
    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildChanged.listen(_onEntryChanged);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text("Board"),
      ),
      body: Column(

        children: [


             Container(
                color: Colors.black26,
                padding: EdgeInsets.all(8.0),
                child:  Form(
                  key: formKey,

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children:<Widget> [
                      ListTile(
                        leading: Icon(Icons.subject),
                        title: TextFormField(
                          initialValue: "",
                          onSaved: (val)=>board.subject=val,
                          validator: (val)=>val=="" ? val:null,
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.message),
                        title: TextFormField(
                          initialValue: "",
                          onSaved: (val)=>board.body=val,
                          validator: (val)=>val==""?val:null,
                        ),
                      ),

                      Container(
                          padding: EdgeInsets.only(left:0.0,top:8.0,right:0.0,bottom: 8.0),
                          child: TextButton(style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed:() {
                                _handleSubmit();
                              }, child: Text("Post",style: TextStyle(color: Colors.white70),))
                      )
                    ],

                  ),
                )
            ),


          Flexible(
            child: FirebaseAnimatedList(
              query: databaseReference,
              itemBuilder: (context, DataSnapshot snapshot, Animation<double> animation, int index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.red),
                    title: Text(snapshot.child("subject").value.toString()),
                    subtitle: Text(snapshot.child("body").value.toString()),
                  ),
                );
              },
            ),
          )


        ],

      )

    );
  }

  void _onEntryAdded(DatabaseEvent event) {
    setState(() {
      boardMessages.add(Board.fromSnapshot(event.snapshot));
    });
  }

  void _handleSubmit() async{
    final form =formKey.currentState;
    if(form!.validate()){
      form.save();
      form.reset();
      await databaseReference.push().set(board.toJson());
    }

  }

  void _onEntryChanged(DatabaseEvent event) {
    var oldEntry=boardMessages.singleWhere((entry){
      return entry.key==event.snapshot.key;

    });
    setState(() {
      boardMessages[boardMessages.indexOf(oldEntry)]=Board.fromSnapshot(event.snapshot);

    });
  }
}
