import 'package:flutter/material.dart';

class MonthYearPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const MonthYearPicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late DateTime selectedDate;
  late int currentYear;
  final int startYear = 2020;
  final List<String> months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril',
    'Maio', 'Junho', 'Julho', 'Agosto',
    'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    currentYear = selectedDate.year;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione o Período'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    if (currentYear > startYear) {
                      currentYear--;
                    }
                  });
                },
              ),
              Text(
                currentYear.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () {
                  setState(() {
                    if (currentYear < DateTime.now().year) {
                      currentYear++;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(12, (index) {
              bool isSelected = selectedDate.year == currentYear &&
                  selectedDate.month == index + 1;
              bool isFuture = currentYear > DateTime.now().year ||
                  (currentYear == DateTime.now().year &&
                      index + 1 > DateTime.now().month);

              return ChoiceChip(
                label: Text(months[index].substring(0, 3)),
                selected: isSelected,
                onSelected: isFuture
                    ? null
                    : (bool selected) {
                        if (selected) {
                          setState(() {
                            selectedDate = DateTime(currentYear, index + 1);
                          });
                          widget.onDateSelected(selectedDate);
                          Navigator.pop(context);
                        }
                      },
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}