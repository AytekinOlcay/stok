import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void showQrDialog(
  BuildContext context, {
  required String type,
  required String id,
  required String label,
  String? productName,
  String? addedAt,
  String? consumeBefore,
}) {
  final qrData = jsonEncode({'type': type, 'id': id});
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(label),
      content: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'shelf' ? 'Raf QR' : 'Paket QR',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (productName != null || addedAt != null || consumeBefore != null) ...[
              const Divider(height: 20),
              if (productName != null)
                _InfoRow(label: 'Ürün', value: productName),
              if (addedAt != null)
                _InfoRow(label: 'Eklendi', value: addedAt),
              if (consumeBefore != null)
                _InfoRow(
                  label: 'TETT',
                  value: consumeBefore,
                  bold: true,
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _InfoRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

