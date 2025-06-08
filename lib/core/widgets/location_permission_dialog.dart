import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konum İzni Gerekli'),
      content: const Text(
        'Namaz vakitlerini doğru hesaplayabilmek için konumunuza ihtiyacımız var. '
        'Konum izni vermezseniz, varsayılan konum olarak Ankara kullanılacaktır.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('İzin Verme'),
        ),
        FilledButton(
          onPressed: () async {
            final permission = await Geolocator.requestPermission();
            Navigator.of(context).pop(
              permission == LocationPermission.always ||
                  permission == LocationPermission.whileInUse,
            );
          },
          child: const Text('İzin Ver'),
        ),
      ],
    );
  }

  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const LocationPermissionDialog(),
        ) ??
        false;
  }
} 