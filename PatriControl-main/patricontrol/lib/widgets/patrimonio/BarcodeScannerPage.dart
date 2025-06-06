import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  // O controller do scanner precisa ser gerenciado no estado do widget
  late MobileScannerController scannerController;
  
  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      autoStart: true,
    );
  }

  @override
  void dispose() {
    scannerController.dispose(); // Importante descartar o controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ler Código de Barras'),
      contentPadding: const EdgeInsets.all(8.0), // Ajuste o padding se necessário
      content: SingleChildScrollView( // Garante que o conteúdo seja rolável se a tela for pequena
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço vertical
          children: [
            // Container para dar um tamanho fixo ao scanner dentro do diálogo
            Container(
              width: MediaQuery.of(context).size.width * 0.7, // 70% da largura da tela
              height: 200, // Altura fixa para o scanner
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ClipRRect( // Recorte as bordas do scanner para o borderRadius
                borderRadius: BorderRadius.circular(8.0),
                child: MobileScanner(
                  controller: scannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? barcodeValue = barcodes.first.rawValue;
                      if (barcodeValue != null) {
                        Navigator.of(context).pop(barcodeValue); // Retorna o valor e fecha o diálogo
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aponte a câmera para o código de barras.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fecha o diálogo sem retornar valor (null)
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}