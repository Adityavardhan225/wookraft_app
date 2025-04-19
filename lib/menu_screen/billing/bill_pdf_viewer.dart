import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config.dart';
import '../../http_client.dart';

/// Shows bill PDF from server
class BillPdfViewer {
  /// Shows a dialog with bill PDF link
  static Future<void> showBillPdf(BuildContext context, String orderId) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Generating Bill'),
          content: LinearProgressIndicator(),
        ),
      );

      // Get auth token
      final token = await HttpClient.getToken();
      
      // Build URL - make sure the path matches your backend API endpoint
      final url = '${Config.baseUrl}/billing_template/generate-bill-pdf/$orderId?token=$token';
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show success dialog with copyable URL
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bill Generated'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text('Your bill has been generated successfully!'),
              const SizedBox(height: 8),
              const Text(
                'To view or download the PDF:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Copy the URL below:'),
                    const SizedBox(height: 4),
                    SelectableText(
                      url,
                      style: TextStyle(color: Colors.blue[800], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text('2. Open it in your browser'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.content_copy),
              label: const Text('Copy URL'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[700],
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied to clipboard')),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error loading bill: $e');
      
      // Close loading dialog if it's still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bill: $e')),
      );
    }
  }
  
  /// Opens a dialog with a download button for the bill
  static Future<void> showBillDownloadDialog(BuildContext context, String orderId) async {
    try {
      // Get auth token
      final token = await HttpClient.getToken();
      
      // Build URL
      final url = '${Config.baseUrl}/billing_template/generate-bill-pdf/$orderId?token=$token';
      
      // Show dialog with download button
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Download Bill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Click the button below to download your bill as a PDF.'),
              const SizedBox(height: 16),
              const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Bill #${orderId.substring(orderId.length > 6 ? orderId.length - 6 : 0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                
                // Copy URL to clipboard
                Clipboard.setData(ClipboardData(text: url));
                
                // Show info dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Download Ready'),
                    content: const Text(
                      'The URL has been copied to your clipboard. Paste it in your browser to download the bill.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error preparing bill download: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error preparing bill download: $e')),
      );
    }
  }
}