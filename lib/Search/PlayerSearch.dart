
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PlayerSearch extends SearchDelegate<String>{

  DatabaseReference teamPlayerDb = FirebaseDatabase.instance.reference().child("teams");



  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return null;
  }


}

