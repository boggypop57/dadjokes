import 'package:dad_frontend/joke_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class GallaryScreen extends StatefulWidget {
  const GallaryScreen({super.key});

  @override
  State<GallaryScreen> createState() => _GallaryScreenState();
}

class _GallaryScreenState extends State<GallaryScreen> {
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<List<String>> gallary = Provider.of<JokesGallaryProvider>
    (context, listen: false).jokes;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dad Jokes App    Gallary of jokes',
        ),
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context,'/',),
          icon: Icon(Icons.home, color: theme.secondaryHeaderColor,)
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        shadowColor: theme.shadowColor,
      ),
      body: Builder(
        builder: (context){
          if(gallary.isEmpty){
            return Center(child: Text('You have no saved jokes yet (0_0)'));
          }
          else{
            return Center(
              child: ListView.builder(
                itemCount: gallary.length,
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text(gallary[index][0]),
                    subtitle: Text(gallary[index][1]),
                  );
                }
              ),
            );
          }
        } 
      ),
    );
  }
}