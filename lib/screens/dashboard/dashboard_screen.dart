import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/feedback_data.dart';
import 'widgets/month_year_picker.dart';
import 'widgets/star_ratings_card.dart';
import 'widgets/feedback_table.dart';
import 'widgets/kpi_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime selectedDate = DateTime.now();
  
  Stream<QuerySnapshot> _getFeedbackStream() {
    return FirebaseFirestore.instance
        .collection('feedback')
        .doc(DateFormat('yyyy_MM').format(selectedDate))
        .collection('responses')
        .snapshots();
  }

  Map<String, double> _calculateAverageStarRatings(List<FeedbackData> feedbackList) {
    Map<String, List<int>> ratingsSums = {};
    Map<String, int> ratingsCount = {};

    for (var feedback in feedbackList) {
      feedback.starRatings.forEach((key, value) {
        ratingsSums.putIfAbsent(key, () => []);
        ratingsSums[key]!.add(value);
        ratingsCount[key] = (ratingsCount[key] ?? 0) + 1;
      });
    }

    return ratingsSums.map((key, values) {
      double average = values.reduce((a, b) => a + b) / ratingsCount[key]!;
      return MapEntry(key, average);
    });
  }

  double _calculateAverageNPS(List<FeedbackData> feedbackList) {
    if (feedbackList.isEmpty) return 0;
    return feedbackList.map((f) => f.npsRating).reduce((a, b) => a + b) /
        feedbackList.length;
  }

  Widget _buildPeriodSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Período selecionado: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return MonthYearPicker(
                      initialDate: selectedDate,
                      onDateSelected: (DateTime date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.calendar_today, size: 24),
              label: Text(
                DateFormat('MMMM/y', 'pt_BR').format(selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 100,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.asset(
                'assets/img/dash/logo.png',
                height: 90,
                fit: BoxFit.contain,
              ),
            ),
            const Expanded(
              child: Text(
                'Painel de Controle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 80),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFeedbackStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<FeedbackData> feedbackList = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return FeedbackData(
              npsRating: data['npsRating'],
              starRatings: Map<String, int>.from(data['starRatings']),
              cpf: data['cpf'],
              comment: data['comment'],
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList();

          Map<String, double> averageStarRatings = _calculateAverageStarRatings(feedbackList);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildPeriodSelector(),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  delegate: SliverChildListDelegate([
                    KpiCard(
                      title: 'Total de Avaliações',
                      value: feedbackList.length.toString(),
                      icon: Icons.assessment,
                      color: Colors.blue,
                    ),
                    KpiCard(
                      title: 'Média NPS',
                      value: _calculateAverageNPS(feedbackList).toStringAsFixed(1),
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                    KpiCard(
                      title: 'Comentários',
                      value: feedbackList.where((f) => f.comment?.isNotEmpty ?? false).length.toString(),
                      icon: Icons.comment,
                      color: Colors.green,
                    ),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StarRatingsCard(
                    averageRatings: averageStarRatings,
                    totalRatings: feedbackList.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FeedbackTable(feedbackList: feedbackList),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}