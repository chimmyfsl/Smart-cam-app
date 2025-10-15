import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration matching the screenshot
    final List<Map<String, dynamic>> detections = [
      {
        'status': 'No stroke detected',
        'date': '2024-03-20',
        'time': '14:30',
        'confidence': '95.0%',
        'isStroke': false,
      },
      {
        'status': 'Potential stroke detected',
        'date': '2024-03-19',
        'time': '10:15',
        'confidence': '82.0%',
        'isStroke': true,
      },
      {
        'status': 'No stroke detected',
        'date': '2024-03-18',
        'time': '16:45',
        'confidence': '98.0%',
        'isStroke': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection History'),
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: detections.length,
        itemBuilder: (context, index) {
          final detection = detections[index];
          final bool isStroke = detection['isStroke'];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    isStroke ? Icons.warning_rounded : Icons.check_circle,
                    color: isStroke ? Colors.orange : Colors.green,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detection['status'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isStroke ? Colors.orange : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${detection['date']} ${detection['time']}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Confidence: ${detection['confidence']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isStroke ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 