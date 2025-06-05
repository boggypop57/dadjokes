import 'package:dad_frontend/joke_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class JokeScreen extends StatefulWidget {
  const JokeScreen({super.key});

  @override
  State<JokeScreen> createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> {
  //bool _showPunchline = false;

  @override
  void initState() {
    super.initState();
    _loadNewJoke();
  }

  void _loadNewJoke() {
    Provider.of<JokeProvider>(context, listen: false).fetchJoke(http.Client());
  }

  void _saveJoke() {
    Provider.of<JokesGallaryProvider>(context, listen: false).addJoke(
      Provider.of<JokeProvider>(context, listen: false).setup ?? "Empty setup",
      Provider.of<JokeProvider>(context, listen: false).punchline ??
          "Empty punchline",
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dad Jokes App'),
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/gallary'),
          icon: Icon(Icons.storage, color: theme.secondaryHeaderColor),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        shadowColor: theme.shadowColor,
      ),
      body: SafeArea(
        child: Consumer<JokeProvider>(
          builder: (context, jokeProvider, child) {
            if (jokeProvider.error != null) {
              return Center(child: Text(jokeProvider.error!));
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(
                    builder: (context) {
                      if (jokeProvider.isLoading) {
                        return Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: theme.primaryColorDark,
                                backgroundColor: theme.scaffoldBackgroundColor,
                              ),
                              SizedBox(height: 65,)
                            ],
                          ) 
                        );
                      }
                      return Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                jokeProvider.setup ?? 'No joke loaded',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                jokeProvider.punchline ?? 'Wait for it...',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _saveJoke(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Save',
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 50),
                      ElevatedButton(
                        onPressed: () => _loadNewJoke(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Next',
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
