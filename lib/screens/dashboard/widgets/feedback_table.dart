import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/feedback_data.dart';
import '../../../utils/color_utils.dart';
import 'feedback_details_dialog.dart';

class FeedbackTable extends StatelessWidget {
  final List<FeedbackData> feedbackList;

  const FeedbackTable({
    super.key,
    required this.feedbackList,
  });

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
                columns: const [
                  DataColumn(label: Text('CPF')),
                  DataColumn(label: Text('Data')),
                  DataColumn(label: Text('NPS')),
                  DataColumn(label: Text('Comentário')),
                  DataColumn(label: Text('Ações')),
                ],
                rows: feedbackList.map((feedback) {
                  return DataRow(
                    cells: [
                      DataCell(Text(feedback.cpf?.isNotEmpty == true ? feedback.cpf! : 'Não Informado')),
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
                      DataCell(
                        Text(
                          feedback.comment?.isNotEmpty == true ? 'Sim' : 'Não',
                        ),
                      ),
                      DataCell(
                        TextButton.icon(
                          onPressed: () => _showFeedbackDetails(context, feedback),
                          icon: const Icon(Icons.visibility),
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