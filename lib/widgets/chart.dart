import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_application_1/data/transaction_model.dart';
import 'package:intl/intl.dart';

class Chart extends StatelessWidget {
  final List<Transaction> filteredTransactions;
  final String period;
  final bool showExpenses;

  const Chart({
    Key? key,
    required this.filteredTransactions,
    required this.period,
    required this.showExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chartData = _generateChartData();

    return Container(
      width: double.infinity,
      height: 300,
      child: chartData.isEmpty
          ? const Center(
              child: Text(
                'Нет данных для отображения',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(fontSize: 12),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelFormat: '{value} ₽',
                majorGridLines: const MajorGridLines(width: 0.5),
              ),
              title: ChartTitle(
                text: showExpenses ? 'Расходы' : 'Доходы',
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <SplineSeries<SalesData, String>>[
                SplineSeries<SalesData, String>(
                  color: showExpenses
                      ? const Color.fromARGB(255, 200, 80, 80)
                      : const Color.fromARGB(255, 47, 125, 121),
                  width: 3,
                  dataSource: chartData,
                  xValueMapper: (SalesData sales, _) => sales.label,
                  yValueMapper: (SalesData sales, _) => sales.amount,
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
              ],
            ),
    );
  }

  List<SalesData> _generateChartData() {
    final Map<String, double> aggregatedData = {};
    final now = DateTime.now();
    DateTime startDate;

    // Определяем диапазон дат в зависимости от периода
    switch (period) {
      case 'День':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Неделя':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Месяц':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Год':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now;
    }

    // Список для хранения дат и меток для корректной сортировки
    final List<Map<String, dynamic>> dataWithDates = [];

    // Агрегация транзакций по датам
    for (var transaction in filteredTransactions) {
      final dateParts = transaction.time.split('.');
      if (dateParts.length != 3) {
        debugPrint('Invalid date format for transaction: ${transaction.time}');
        continue;
      }
      final transactionDate = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      // Проверяем, попадает ли транзакция в выбранный период
      if (transactionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          transactionDate.isBefore(now.add(const Duration(days: 1)))) {
        String label;
        int sortKey; // Для сортировки
        switch (period) {
          case 'День':
            label = DateFormat('HH:mm').format(transactionDate);
            sortKey = transactionDate.hour * 60 + transactionDate.minute;
            break;
          case 'Неделя':
            label = _getRussianDayName(transactionDate.weekday);
            sortKey = transactionDate.weekday;
            break;
          case 'Месяц':
            label = DateFormat('d MMM', 'ru').format(transactionDate);
            sortKey = transactionDate.day + transactionDate.month * 100; // Пример: 15 окт -> 1015
            break;
          case 'Год':
            label = DateFormat('MMM', 'ru').format(transactionDate);
            sortKey = transactionDate.month;
            break;
          default:
            label = transaction.time;
            sortKey = 0;
        }

        final amount = double.tryParse(transaction.fee) ?? 0;
        aggregatedData.update(label, (value) => value + amount, ifAbsent: () => amount);
        dataWithDates.add({'label': label, 'sortKey': sortKey, 'amount': amount});
      }
    }

    // Преобразуем в SalesData
    final chartData = aggregatedData.entries
        .map((entry) => SalesData(entry.value, entry.key))
        .toList();

    // Сортировка
    if (period == 'Неделя') {
      final dayOrder = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
      chartData.sort((a, b) => dayOrder.indexOf(a.label).compareTo(dayOrder.indexOf(b.label)));
    } else if (period == 'День') {
      chartData.sort((a, b) => a.label.compareTo(b.label));
    } else {
      // Для "Месяц" и "Год" сортируем по sortKey
      final labelToSortKey = Map.fromEntries(
        dataWithDates.map((e) => MapEntry(e['label'], e['sortKey'])),
      );
      chartData.sort((a, b) {
        final keyA = labelToSortKey[a.label] ?? 0;
        final keyB = labelToSortKey[b.label] ?? 0;
        return keyA.compareTo(keyB);
      });
    }

    debugPrint('Chart data for period $period: ${chartData.map((e) => '${e.label}: ${e.amount}').toList()}');
    return chartData;
  }

  String _getRussianDayName(int weekday) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[weekday - 1];
  }
}

class SalesData {
  SalesData(this.amount, this.label);
  final double amount;
  final String label;
}