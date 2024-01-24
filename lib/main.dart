import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//       Class: Mobile Application Development
//        Name: Dat Tran
//        Date: Jan 24, 2024
//    Homework: Week 3
//      Points: 100 pts
//         Due: Feb 1, 2024

//    Estimate Completion time: 4 Hours
//     Actual Completion time: 5 Hours

const maxWordPairHistory = 20;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var wordPairHistories = <WordPairExtended>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removePair(WordPair pair) {
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    }
    notifyListeners();
  }

  void addWordPairToHistories(WordPair pair) {
    if (wordPairHistories.length > maxWordPairHistory) {
      var leftOver = wordPairHistories.length - maxWordPairHistory;
      wordPairHistories.removeRange(0, leftOver);
    }

    bool liked = (favorites.contains(pair)) ? true : false;
    WordPairExtended pairExtended =
        WordPairExtended(pair.first, pair.second, liked);

    wordPairHistories.add(pairExtended);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page = getPageBySelectedIndex(selectedIndex);

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          body: Row(
        children: [
          SafeArea(
              child: NavigationRail(
            extended: constraints.maxWidth >= 600,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text('Home')),
              NavigationRailDestination(
                  icon: Icon(Icons.favorite), label: Text('Favorites'))
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          )),
          Expanded(
              child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page))
        ],
      ));
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var visited = appState.wordPairHistories;

    ScrollController scrollController = ScrollController();

    IconData icon = (appState.favorites.contains(pair))
        ? Icons.favorite
        : Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
                child: WordPairHistoryListView(
                    scrollController: scrollController, visited: visited),
              )),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                BigCard(pair: pair),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                        icon: Icon(icon),
                        onPressed: () {
                          appState.toggleFavorite();
                        },
                        label: Text('Like')),
                    SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          appState.getNext();
                          appState.addWordPairToHistories(pair);

                          //when add new item, scroll the visited listview down to show the latest item
                          if (scrollController.hasClients) {
                            final position =
                                scrollController.position.maxScrollExtent;
                            scrollController.jumpTo(position);
                          }
                        },
                        child: Text('Next')),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class WordPairHistoryListView extends StatelessWidget {
  const WordPairHistoryListView({
    super.key,
    required this.scrollController,
    required this.visited,
  });

  final ScrollController scrollController;
  final List<WordPairExtended> visited;

  @override
  Widget build(BuildContext context) {
    return ListView(controller: scrollController, children: [
      ...visited.map<Widget>((v) => Row(children: [
            Icon(v.like ? Icons.favorite : Icons.favorite_border_outlined),
            Text('${v.first}${v.second}')
          ]))
    ]);
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      elevation: 2,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            pair.first,
            style: style,
            semanticsLabel: "${pair.first} ${pair.second}",
          ),
          Text(pair.second,
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('No favorites yet'));
    }

    return ListView(children: [
      Padding(
          padding: const EdgeInsets.all(20),
          child: Text("You have ${appState.favorites.length} favorites")),
      for (var pair in appState.favorites)
        ListTile(
          leading: IconButton(
            onPressed: () {
              appState.removePair(pair);
            },
            icon: Icon(Icons.delete),
          ),
          title: Text(pair.asLowerCase),
        ),
    ]);
  }
}

class WordPairExtended extends WordPair {
  bool like = false;
  WordPairExtended(super.first, super.second, this.like);
}

Widget getPageBySelectedIndex(int selectedIndex) {
  switch (selectedIndex) {
    case 0:
      return GeneratorPage();
    case 1:
      return FavoritesPage();
    default:
      throw UnimplementedError("no widget for $selectedIndex");
  }
}
