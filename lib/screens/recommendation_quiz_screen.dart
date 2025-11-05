import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cocktail_provider.dart';
import 'recommendation_results_screen.dart';

class RecommendationQuizScreen extends StatefulWidget {
  const RecommendationQuizScreen({super.key});

  @override
  State<RecommendationQuizScreen> createState() => _RecommendationQuizScreenState();
}

class _RecommendationQuizScreenState extends State<RecommendationQuizScreen> {
  int _currentQuestion = 0;
  String? _selectedMood;
  String? _selectedFlavor;
  String? _selectedSkill;
  String? _selectedStrength;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What\'s your mood?',
      'options': ['Party', 'Relaxing', 'Dinner', 'Brunch'],
      'values': ['party', 'relaxing', 'dinner', 'brunch'],
    },
    {
      'question': 'What flavor do you prefer?',
      'options': ['Sweet', 'Fruity', 'Bitter', 'Tart'],
      'values': ['sweet', 'fruity', 'bitter', 'tart'],
    },
    {
      'question': 'Your skill level?',
      'options': ['Easy (Beginner)', 'Moderate (Intermediate)', 'Challenging (Expert)'],
      'values': ['beginner', 'intermediate', 'expert'],
    },
    {
      'question': 'Preferred strength?',
      'options': ['Non-Alcoholic', 'Light', 'Medium', 'Strong'],
      'values': ['non-alcoholic', 'light', 'medium', 'strong'],
    },
  ];

  void _selectAnswer(String value) {
    setState(() {
      switch (_currentQuestion) {
        case 0:
          _selectedMood = value;
          break;
        case 1:
          _selectedFlavor = value;
          break;
        case 2:
          _selectedSkill = value;
          break;
        case 3:
          _selectedStrength = value;
          break;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      _showResults();
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
    }
  }

  bool get _canProceed {
    switch (_currentQuestion) {
      case 0:
        return _selectedMood != null;
      case 1:
        return _selectedFlavor != null;
      case 2:
        return _selectedSkill != null;
      case 3:
        return _selectedStrength != null;
      default:
        return false;
    }
  }

  String? get _currentSelection {
    switch (_currentQuestion) {
      case 0:
        return _selectedMood;
      case 1:
        return _selectedFlavor;
      case 2:
        return _selectedSkill;
      case 3:
        return _selectedStrength;
      default:
        return null;
    }
  }

  void _showResults() {
    final cocktailProvider = context.read<CocktailProvider>();
    final allCocktails = cocktailProvider.cocktails;

    // Score each cocktail based on preferences
    final scored = allCocktails.map((cocktail) {
      int score = 0;

      // Mood match (can have multiple moods)
      if (_selectedMood != null && (cocktail['mood'] as List).contains(_selectedMood)) {
        score += 3;
      }

      // Flavor/type match
      if (_selectedFlavor != null && cocktail['type'] == _selectedFlavor) {
        score += 3;
      }

      // Skill match
      if (_selectedSkill != null && cocktail['skill'] == _selectedSkill) {
        score += 2;
      }

      // Strength match
      if (_selectedStrength != null && cocktail['potency'] == _selectedStrength) {
        score += 2;
      }

      return {'cocktail': cocktail, 'score': score};
    }).toList();

    // Sort by score descending
    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    // Take top 3
    final top3 = scored.take(3).map((s) => s['cocktail'] as Map<String, dynamic>).toList();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RecommendationResultsScreen(
          recommendations: top3,
          preferences: {
            'mood': _selectedMood,
            'flavor': _selectedFlavor,
            'skill': _selectedSkill,
            'strength': _selectedStrength,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final options = question['options'] as List<String>;
    final values = question['values'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find My Drink'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _questions.length,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${_currentQuestion + 1} of ${_questions.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),

            // Question
            Text(
              question['question'] as String,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final value = values[index];
                  final isSelected = _currentSelection == value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _selectAnswer(value),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimaryContainer
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.onPrimaryContainer
                                            : Theme.of(context).colorScheme.onSurface,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Row(
              children: [
                if (_currentQuestion > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ),
                if (_currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _canProceed ? _nextQuestion : null,
                    child: Text(_currentQuestion < _questions.length - 1 ? 'Next' : 'Get Recommendations'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
