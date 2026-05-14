import 'package:flutter/material.dart';

void main() {
  runApp(const CGPAApp());
}


class Subject {
  final TextEditingController nameCtrl;
  String grade;
  int credits;

  Subject() : nameCtrl = TextEditingController(), grade = 'O', credits = 3;

  String get name => nameCtrl.text.isEmpty ? 'Unnamed' : nameCtrl.text;

  double get gradePoint {
    switch (grade) {
      case 'O':
        return 10.0;
      case 'A+':
        return 9.0;
      case 'A':
        return 8.0;
      case 'B+':
        return 7.0;
      case 'B':
        return 6.0;
      case 'C':
        return 5.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  void dispose() {
    nameCtrl.dispose();
  }
}


class CGPAApp extends StatelessWidget {
  const CGPAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          surface: Color(0xFF1A1A2E),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Subject> _subjects = [];

  static const List<String> _grades = ['O', 'A+', 'A', 'B+', 'B', 'C', 'F'];

  double get _cgpa {
    final totalCredits = _subjects.fold(0, (s, e) => s + e.credits);
    if (totalCredits == 0) return 0;
    final weighted = _subjects.fold(
      0.0,
      (s, e) => s + e.gradePoint * e.credits,
    );
    return weighted / totalCredits;
  }

  int get _totalCredits => _subjects.fold(0, (s, e) => s + e.credits);

  String _performanceLabel(double cgpa) {
    if (cgpa >= 9.0) return 'Outstanding 🏆';
    if (cgpa >= 8.0) return 'Excellent 🌟';
    if (cgpa >= 7.0) return 'Very Good 👍';
    if (cgpa >= 6.0) return 'Good ✅';
    if (cgpa >= 5.0) return 'Average 📘';
    if (cgpa > 0) return 'Needs Improvement 💪';
    return '';
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'O':
        return const Color(0xFF00E676);
      case 'A+':
        return const Color(0xFF69F0AE);
      case 'A':
        return const Color(0xFF40C4FF);
      case 'B+':
        return const Color(0xFFFFD740);
      case 'B':
        return const Color(0xFFFFAB40);
      case 'C':
        return const Color(0xFFFF6D00);
      default:
        return const Color(0xFFFF1744);
    }
  }

  void _addSubject() => setState(() => _subjects.add(Subject()));

  void _removeSubject(int i) {
    setState(() {
      _subjects[i].dispose();
      _subjects.removeAt(i);
    });
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Clear All?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Remove all subjects?',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                for (var s in _subjects) s.dispose();
                _subjects.clear();
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CGPA Calculator',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Grade & Credit Weighted',
              style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_subjects.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Color(0xFFFF6B6B),
              ),
              onPressed: _clearAll,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
        children: [
          if (_subjects.isNotEmpty) _buildResultCard(),
          if (_subjects.isEmpty) _buildEmptyState(),
          ..._subjects.asMap().entries.map(
            (e) => _buildSubjectCard(e.key, e.value),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSubject,
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Subject',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }


  Widget _buildResultCard() {
    final cgpa = _cgpa;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.25),
            const Color(0xFF00BCD4).withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
      ),
      child: Column(
        children: [
          if (_performanceLabel(cgpa).isNotEmpty)
            Text(
              _performanceLabel(cgpa),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          const SizedBox(height: 6),
          Text(
            cgpa.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const Text(
            'CGPA  (out of 10)',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat(
                'Subjects',
                '${_subjects.length}',
                const Color(0xFFFFD740),
              ),
              Container(width: 1, height: 36, color: Colors.white12),
              _miniStat(
                'Total Credits',
                '$_totalCredits',
                const Color(0xFF40C4FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    ],
  );

  Widget _buildSubjectCard(int i, Subject s) {
    final color = _gradeColor(s.grade);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: color.withOpacity(0.15),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    s.grade,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeSubject(i),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFF6B6B),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Subject Name ──
            TextField(
              controller: s.nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Subject Name',
                labelStyle: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                ),
                filled: true,
                fillColor: const Color(0xFF0F0F1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // ── Grade Selector ──
            const Text(
              'Select Grade',
              style: TextStyle(color: Color(0xFF888888), fontSize: 11),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _grades.map((g) {
                final isSelected = s.grade == g;
                final gc = _gradeColor(g);
                return GestureDetector(
                  onTap: () => setState(() => s.grade = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? gc.withOpacity(0.2)
                          : const Color(0xFF0F0F1A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? gc : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      g,
                      style: TextStyle(
                        color: isSelected ? gc : Colors.white54,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            const Text(
              'Credits',
              style: TextStyle(color: Color(0xFF888888), fontSize: 11),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (s.credits > 1) setState(() => s.credits--);
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    '${s.credits}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (s.credits < 10) setState(() => s.credits++);
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(width: 12),
                // GP chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'GP: ',
                          style: TextStyle(
                            color: color.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                        TextSpan(
                          text: s.gradePoint.toStringAsFixed(1),
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD740).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Weighted: ',
                          style: TextStyle(
                            color: Color(0xFFFFD740),
                            fontSize: 11,
                          ),
                        ),
                        TextSpan(
                          text: (s.gradePoint * s.credits).toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFFFFD740),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school_outlined,
            size: 60,
            color: Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No subjects yet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap "Add Subject" to get started.\nSelect a grade and set credit hours.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 28),
        _buildGradeTable(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGradeTable() {
    final rows = [
      ['O', '10.0', 'Outstanding'],
      ['A+', '9.0', 'Excellent'],
      ['A', '8.0', 'Very Good'],
      ['B+', '7.0', 'Good'],
      ['B', '6.0', 'Above Average'],
      ['C', '5.0', 'Average'],
      ['F', '0.0', 'Fail'],
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Grading Scale',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Grade',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
              Expanded(
                child: Text(
                  'GP',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Description',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _gradeColor(r[0]).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r[0],
                        style: TextStyle(
                          color: _gradeColor(r[0]),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r[1],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      r[2],
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
