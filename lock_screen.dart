
import 'package:flutter/material.dart';

class LockScreen extends StatefulWidget {
  final String pin;
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.pin, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final ctrl = TextEditingController();
  String? err;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Entrez le code PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: ctrl, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder())),
            if (err != null) Padding(padding: const EdgeInsets.only(top:8), child: Text(err!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: (){
              if (ctrl.text == widget.pin) {
                widget.onUnlocked();
              } else {
                setState(()=>err='Code incorrect');
              }
            }, child: const Text('Déverrouiller'))
          ]),
        ),
      ),
    );
  }
}
