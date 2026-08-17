import 'package:flutter/material.dart';
import 'core.dart';
import 'merchant_store_v2.dart';

class BrandedStorePage extends StatelessWidget {
  final Store store;
  final String customerName;
  final String phone;
  final Repo repo;

  const BrandedStorePage({
    super.key,
    required this.store,
    required this.customerName,
    required this.phone,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return MerchantStoreV2Page(
      store: store,
      customerName: customerName,
      phone: phone,
      repo: repo,
    );
  }
}
