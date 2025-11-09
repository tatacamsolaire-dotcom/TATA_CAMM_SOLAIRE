
import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settings;
  final VoidCallback onApplied;
  const SettingsScreen({super.key, required this.settings, required this.onApplied});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final pin = TextEditingController();
  bool dark = false;
  String lang = 'fr';
  final threshold = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    pin.text = (await widget.settings.getPin()) ?? '';
    dark = await widget.settings.getDarkMode();
    lang = await widget.settings.getLang();
    threshold.text = (await widget.settings.getThreshold()).toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Paramètres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        TextField(controller: pin, decoration: const InputDecoration(labelText: 'Code PIN (laisser vide pour désactiver)')),
        const SizedBox(height: 8),
        SwitchListTile(value: dark, onChanged: (v)=>setState(()=>dark=v), title: const Text('Mode sombre')),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: lang, items: const [
          DropdownMenuItem(value: 'fr', child: Text('Français')),
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'bm', child: Text('Bambara (simplifié)')),
        ], onChanged: (v)=>setState(()=>lang=v??'fr'), decoration: const InputDecoration(labelText: 'Langue')),
        const SizedBox(height: 8),
        TextField(controller: threshold, decoration: const InputDecoration(labelText: 'Seuil de stock faible'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            await widget.settings.setPin(pin.text.trim());
            await widget.settings.setDarkMode(dark);
            await widget.settings.setLang(lang);
            await widget.settings.setThreshold(int.tryParse(threshold.text) ?? 5);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paramètres enregistrés.')));
            widget.onApplied();
          },
          child: const Text('Enregistrer'),
        )
      ]),
    );
  }
}
