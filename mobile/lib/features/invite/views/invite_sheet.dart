import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/invite_controller.dart';

class InviteSheet extends GetView<InviteController> {
  const InviteSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              children: [
                const Text(
                  'Üye Davet Et',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: Get.back,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Body
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final t = controller.token.value;
                if (t == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            'Davet oluşturulamadı',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                                controller.errorMessage.value ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              )),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: controller.refreshToken,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final expires = controller.expiresAt.value;
                final expiryText = expires != null
                    ? DateFormat('dd.MM.yyyy HH:mm').format(expires)
                    : '';

                return Column(
                  children: [
                    // QR Code
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: QrImageView(
                        data: controller.qrPayload,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'ya da kod ile paylaş',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 12),

                    // Token display
                    GestureDetector(
                      onTap: controller.copyToClipboard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                color: Colors.blue.shade700,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.copy, color: Colors.blue.shade400),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (expiryText.isNotEmpty)
                      Text(
                        'Son kullanım: $expiryText',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                    const SizedBox(height: 32),

                    // Instruction
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nasıl kullanılır?',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
                          Text(
                            '1. Karşı kişi uygulamayı indirir / açar.\n'
                            '2. Giriş yaptıktan sonra "Davete Katıl" seçeneğine basar.\n'
                            '3. Bu kodu girer — veya QR kodu okuttur.',
                            style: TextStyle(fontSize: 13, height: 1.6),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Refresh button
                    OutlinedButton.icon(
                      onPressed: controller.refreshToken,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Yeni Kod Oluştur'),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
