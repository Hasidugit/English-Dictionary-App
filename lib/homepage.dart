import 'package:flutter/material.dart';
import 'package:flutter_application_dictionary_wordcollection/responsemodel.dart';
import 'package:flutter_application_dictionary_wordcollection/slidenav.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

import 'api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool inProgress = false;
  ResponseModel? responseModel;
  String noDataText = "Welcome, Start searching";
  List<String> savedWords = [];
  late TabController _tabController;
  final translator = GoogleTranslator();
  String translatedWord = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedWords();
    _loadSavedTranslations(); // Load saved translations
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedWords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedWords = prefs.getStringList('savedTranslations') ?? [];
      print("Loaded saved translations: $savedWords");
    });
  }

  Future<void> _saveWord(String word) async {
    final prefs = await SharedPreferences.getInstance();

    // Capitalize the first letter of the word
    String capitalizedWord = word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '';

    // Avoid adding duplicates
    if (!savedWords.contains(capitalizedWord)) {
      savedWords.add(capitalizedWord);
      await prefs.setStringList('savedWords', savedWords);

      // Update the list after saving
      setState(() {
        savedWords = prefs.getStringList('savedWords') ?? [];
      });

      Logger().f("Saved word: $capitalizedWord");
      print("Updated saved words list: $savedWords");
    } else {
      print("Word already in saved list: $capitalizedWord");
    }
  }

  Future<void> _deleteWord(String word) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove the word by exact match
    savedWords
        .removeWhere((item) => item.startsWith('$word :') || item == word);

    // Save updated list to SharedPreferences
    await prefs.setStringList('savedTranslations', savedWords);

    // Update UI
    setState(() {
      savedWords = prefs.getStringList('savedTranslations') ?? [];
      Logger().f("Deleted word: $word");
      Logger().f("Updated saved words list: $savedWords");
    });
  }

  Future<void> _saveTranslation(String word, String translation) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTranslations = prefs.getStringList('savedTranslations') ?? [];

    // Check if the word's translation is already saved
    final updatedTranslations =
        savedTranslations.where((item) => !item.startsWith('$word :')).toList();
    updatedTranslations.add('$word : $translation');
    await prefs.setStringList('savedTranslations', updatedTranslations);

    setState(() {
      savedWords = updatedTranslations;
    });
    Logger().f("Saved translation for $word: $translation");
  }

  Future<void> _loadSavedTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedWords = prefs.getStringList('savedTranslations') ?? [];
      print("Loaded saved translations: $savedWords");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Row(
                children: [
                  SizedBox(
                    width: 35,
                  ),
                  Text(
                    '    My Dictionary',
                    style: GoogleFonts.heptaSlab(
                      fontSize: 25, // Adjust font size as needed
                      fontWeight:
                          FontWeight.bold, // Adjust font weight as needed
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.settings,
                    size: 32,
                  ),
                ],
              ),
            ),
            backgroundColor: Colors
                .transparent, // Make background transparent to show gradient
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 126, 109, 220),
                    Color.fromARGB(255, 153, 102, 208)
                  ], // Gradient colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Color.fromARGB(
                  255, 40, 8, 172), // Color for selected tab text
              unselectedLabelColor: const Color.fromARGB(
                  255, 253, 253, 253), // Color for unselected tab text

              tabs: const [
                Tab(
                  child: Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 17, // Set your desired font size
                      fontFamily: 'Roboto', // Set your desired font family
                      fontWeight: FontWeight.bold, // Optional: Set font weight
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Saved Words',
                    style: TextStyle(
                      fontSize: 17, // Set your desired font size
                      fontFamily: 'Roboto', // Set your desired font family
                      fontWeight: FontWeight.bold, // Optional: Set font weight
                    ),
                  ),
                ),
              ],
            ),
          ),
          drawer: const Sidenav(),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildSearchTab(),
              _buildSavedWordsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchWidget(),
          const SizedBox(height: 2),
          if (inProgress)
            const LinearProgressIndicator()
          else if (responseModel != null)
            Expanded(child: _buildResponseWidget())
          else
            _noDataWidget(),
        ],
      ),
    );
  }

  Widget _buildSavedWordsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saved Words',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: savedWords.length,
              itemBuilder: (context, index) {
                final item = savedWords[index];
                return InkWell(
                  onTap: () {
                    // Extract the word part from the saved entry
                    String wordToSearch = item.split(' : ')[0];
                    // Fetch the meaning and show in the bottom sheet
                    _showMeaningBottomSheet(context, wordToSearch);
                  },
                  child: Card(
                    color: const Color.fromARGB(255, 159, 164,
                        221), // Change this to your desired color
                    child: ListTile(
                      title: Row(
                        children: [
                          Container(
                              width: 8.0, // Width of the color bar
                              height: 40, // Full height of the card
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 76, 90, 169),
                                  borderRadius: BorderRadius.circular(
                                      25)) // Color of the color bar
                              ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(item),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteWord(item.split(' : ')[0]);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMeaningBottomSheet(BuildContext context, String word) async {
    try {
      // Fetch the meaning from API
      final response = await API.fetchMeaning(word);
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  response.word!,
                  style: TextStyle(
                    color: Colors.purple.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
                Text(response.phonetic ?? ""),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: response.meanings!.length,
                    itemBuilder: (context, index) {
                      return _buildMeaningWidget2(response.meanings![index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch meaning for $word')),
      );
    }
  }

  Widget _buildMeaningWidget2(Meanings meanings) {
    String definitionList = "";
    meanings.definitions?.forEach(
      (element) {
        int index = meanings.definitions!.indexOf(element);
        definitionList += "\n${index + 1}. ${element.definition}\n";
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meanings.partOfSpeech!,
          style: TextStyle(
            color: Colors.orange.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Definitions : ",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(definitionList),
        _buildSet("Synonyms", meanings.synonyms),
        _buildSet("Antonyms", meanings.antonyms),
      ],
    );
  }

  Widget _buildResponseWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          responseModel!.word!,
          style: TextStyle(
            color: Colors.purple.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        Text(responseModel!.phonetic ?? ""),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Translation: $translatedWord',
              style: TextStyle(
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _saveWord(responseModel!.word!);
                _saveTranslation(
                    responseModel!.word!, translatedWord); // Save translation
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    const Color.fromARGB(255, 125, 114, 222), // Text color
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(25.0), // Button border radius
                ),
              ),
              child: const Text('Save Word'),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return _buildMeaningWidget(responseModel!.meanings![index]);
            },
            itemCount: responseModel!.meanings!.length,
          ),
        ),
      ],
    );
  }

  Widget _buildMeaningWidget(Meanings meanings) {
    String definitionList = "";
    meanings.definitions?.forEach(
      (element) {
        int index = meanings.definitions!.indexOf(element);
        definitionList += "\n${index + 1}. ${element.definition}\n";
      },
    );

    return InkWell(
      onTap: () {
        // Check if responseModel is available
        if (responseModel != null) {
          final wordToSearch = responseModel!.word;
          if (wordToSearch != null && wordToSearch.isNotEmpty) {
            print("InkWell tapped! Searching for word: $wordToSearch");
            _getMeaningFromApi(wordToSearch);
          } else {
            print("Word to search is null or empty.");
          }
        } else {
          print("responseModel is null.");
        }
      },
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meanings.partOfSpeech!,
                style: TextStyle(
                  color: Colors.orange.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Definitions : ",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(definitionList),
              _buildSet("Synonyms", meanings.synonyms),
              _buildSet("Antonyms", meanings.antonyms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSet(String title, List<String>? setList) {
    if (setList?.isNotEmpty ?? false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title : ",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(setList!
              .toSet()
              .toString()
              .replaceAll("{", "")
              .replaceAll("}", "")),
          const SizedBox(height: 10),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _noDataWidget() {
    return Column(
      children: [
        SizedBox(
          height: 100,
        ),
        SizedBox(
          height: 100,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search,
                    size: 70, color: Colors.grey), // Search icon
                const SizedBox(height: 5), // Spacing between icon and text
                Text(
                  noDataText,
                  style: const TextStyle(
                    fontSize: 16, // Reduced font size
                    color: Colors.grey, // Optional: change color if needed
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchWidget() {
    return Container(
      height: 50, // Adjust the height as needed
      child: TextField(
        decoration: InputDecoration(
          hoverColor: Colors.black12,
          fillColor: Colors.black12,
          suffixIcon: Icon(Icons.search),
          hintText: "Search word here",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 16, vertical: 10), // Adjust padding
        ),
        onSubmitted: (value) {
          _getMeaningFromApi(value);
        },
      ),
    );
  }

  Future<void> _getMeaningFromApi(String word) async {
    setState(() {
      inProgress = true;
    });
    try {
      responseModel = await API.fetchMeaning(word);
      if (responseModel != null && responseModel!.word != null) {
        final translation = await translator.translate(responseModel!.word!,
            from: 'en', to: 'si');
        setState(() {
          translatedWord = translation.text;
        });
      }
    } catch (e) {
      responseModel = null;
      noDataText = "Meaning cannot be fetched";
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
