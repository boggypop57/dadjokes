import 'package:dad_frontend/joke_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GallaryScreen extends StatelessWidget {
  const GallaryScreen({super.key});

  void _deleteJoke(BuildContext context, id){
    Provider.of<JokesGallaryProvider>(context, listen: false).deleteJoke(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<JokesGallaryProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dad Jokes App    Gallary of jokes'),
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/'),
          icon: Icon(Icons.home, color: theme.secondaryHeaderColor),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        shadowColor: theme.shadowColor,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 700
          ),
          child: Builder(
            builder: (context) {
              if (provider.jokes.isEmpty) {
                return Center(
                  child: Text(
                    'You have no saved jokes yet (0_0)',
                    style: theme.textTheme.titleMedium,
                  ),
                );
              } else {
                return Center(
                  child: ListView.builder(
                    itemCount: provider.jokes.length,
                    itemBuilder: (context, index) {

                      debugPrint('ListTile index: $index');

                      final joke = provider.jokes[index];
                      
                      debugPrint('ListTile setup: ${joke.setup}');

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor: theme.colorScheme.onSecondaryFixedVariant,
                          title: Text(joke.setup),
                          subtitle: Text(joke.punchline),
                          trailing: IconButton(
                            onPressed: () => _deleteJoke(context, index), 
                            icon: Icon(
                              Icons.delete,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
