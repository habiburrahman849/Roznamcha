import 'package:roznamcha/data/db/app_database.dart';

class InvoiceDetail {
  const InvoiceDetail({required this.invoice, required this.items});

  final Invoice invoice;
  final List<InvoiceItem> items;
}
