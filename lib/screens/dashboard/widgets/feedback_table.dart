import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/feedback_data.dart';
import '../../../utils/color_utils.dart';
import 'feedback_details_dialog.dart';

class FeedbackTable extends StatefulWidget {
  final List<FeedbackData> feedbackList;

  const FeedbackTable({
    super.key,
    required this.feedbackList,
  });

  @override
  State<FeedbackTable> createState() => _FeedbackTableState();
}

class _FeedbackTableState extends State<FeedbackTable> {
  bool _dateAscending = true;
  bool _npsAscending = true;
  List<FeedbackData> _sortedList = [];

  @override
  void initState() {
    super.initState();
    _sortedList = List.from(widget.feedbackList);
    _sortByDate();
  }

  void _sortByDate() {
    setState(() {
      _sortedList.sort((a, b) => _dateAscending
          ? a.timestamp.compareTo(b.timestamp)
          : b.timestamp.compareTo(a.timestamp));
      _dateAscending = !_dateAscending;
    });
  }

  void _sortByNPS() {
    setState(() {
      _sortedList.sort((a, b) => _npsAscending
          ? a.npsRating.compareTo(b.npsRating)
          : b.npsRating.compareTo(a.npsRating));
      _npsAscending = !_npsAscending;
    });
  }

  void _showFeedbackDetails(BuildContext context, FeedbackData feedback) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDetailsDialog(feedback: feedback),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avaliações Recentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('CPF')),
                  DataColumn(
                    label: Row(
                      children: [
                        const Text('Data'),
                        IconButton(
                          icon: Icon(
                            _dateAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                          ),
                          onPressed: _sortByDate,
                        ),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        const Text('NPS'),
                        IconButton(
                          icon: Icon(
                            _npsAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                          ),
                          onPressed: _sortByNPS,
                        ),
                      ],
                    ),
                  ),
                  const DataColumn(label: Text('Comentário')),
                  const DataColumn(label: Text('Ações')),
                ],
                rows: _sortedList.map((feedback) {
                  return DataRow(
                    cells: [
                      DataCell(Text(feedback.cpf?.isNotEmpty == true ? feedback.cpf! : 'CPF não informado')),
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(feedback.timestamp))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ColorUtils.getNPSColor(feedback.npsRating),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            feedback.npsRating.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      DataCell(Text(feedback.comment?.isNotEmpty == true ? 'Sim' : 'Não')),
                      DataCell(
                        TextButton.icon(
                          onPressed: () => _showFeedbackDetails(context, feedback),
                          icon: const Icon(Icons.visibility , color: Colors.green),                          
                          label: const Text('Ver detalhes'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}