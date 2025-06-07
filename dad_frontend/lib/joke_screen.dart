import 'package:dad_frontend/joke_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class JokeScreen extends StatefulWidget {
  const JokeScreen({super.key});

  @override
  State<JokeScreen> createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> {
  Joke? _fromHistory;

  String get currentSetup {
    if(_fromHistory != null) return _fromHistory!.setup;
    return Provider.of<JokeProvider>(context, listen: false).setup ?? 'No setup';
  }

  String get currentPunchline {
    if(_fromHistory != null) return _fromHistory!.punchline;
    return Provider.of<JokeProvider>(context, listen: false).punchline ?? 'No setup';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNewJoke();
    });
  }

  void _loadNewJoke() {
    Provider.of<JokeProvider>(context, listen: false).fetchJoke(http.Client());
  }

  void _onTapNext(String setup, String punchline) {
    Provider.of<PreviousJokesProvider>(context, listen: false).scrollJokes(setup, punchline);
    _loadNewJoke();
    if (_fromHistory != null) _fromHistory = null;
  }

  void _saveJoke() {
    Provider.of<JokesGallaryProvider>(context, listen: false).addJoke(
      _fromHistory?.setup ?? Provider.of<JokeProvider>(context, listen: false).setup ?? "Empty setup",
      _fromHistory?.punchline ?? Provider.of<JokeProvider>(context, listen: false).punchline ??
          "Empty punchline",
    );
  }

  void _goToGallary(String setup, String punchline){
    Provider.of<PreviousJokesProvider>(context, listen: false).scrollJokes(setup, punchline);
    if (_fromHistory != null) _fromHistory = null;
    Navigator.pushNamed(context, '/gallary');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dad Jokes App'),
        leading: IconButton(
          onPressed: () => _goToGallary(currentSetup, currentPunchline),
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
            final jokesPrev = Provider.of<PreviousJokesProvider>(context).jokes;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150,
                    width: 400,
                    child: ListView.builder(
                      shrinkWrap: false,
                      reverse: true,
                      itemCount: min(3, jokesPrev.length),
                      padding: EdgeInsets.all(5),
                      itemBuilder: (context, index){
                        return Opacity(
                          opacity: 0.6 - index * 0.2,
                          child: InkWell(
                            onTap: () =>
                              setState(() =>
                                _fromHistory = Joke(
                                  jokesPrev[index].setup, 
                                  jokesPrev[index].punchline
                                )
                              ),
                              
                            child: Card(
                              key: ValueKey([index].hashCode),
                              child: Column(
                                children: [
                                  Text(
                                    jokesPrev[index].setup,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(height: 2,),
                                  Text(
                                    jokesPrev[index].punchline,
                                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          )
                        );
                      }
                    ),
                  ),

                  SizedBox(height: 14,),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      border: Border.all(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.outlineVariant, // Цвет границ
                        width: 3.0,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    height: 170,
                    width: 500,
                    child: Builder(
                      builder: (context) {
                        if (jokeProvider.isLoading) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  backgroundColor:
                                      theme.scaffoldBackgroundColor,
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  "Loading...",
                                  style: theme.textTheme.displaySmall,
                                ),
                              ],
                            ),
                          );
                        }
                       
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  currentSetup,
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
                                  currentPunchline,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

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
                        onPressed: () => jokeProvider.isLoading ? {} :
                           _onTapNext(currentSetup, currentPunchline),
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
