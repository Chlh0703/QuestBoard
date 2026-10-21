import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:quest_board/services/hotkey_service.dart';

import '../services/overlay_service.dart';


void showConfigurationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const ConfigurationDialog();
    },
  );
}

class ConfigurationDialog extends StatefulWidget {
  const ConfigurationDialog({super.key});

  @override
  State<ConfigurationDialog> createState() => _ConfigurationDialogState();}

class _ConfigurationDialogState extends State<ConfigurationDialog> {
  static const HotKeyModifier defaultModifier = HotKeyModifier.control;
  static const PhysicalKeyboardKey defaultKey = PhysicalKeyboardKey.keyS;

  late HotKeyModifier selectedModifier = defaultModifier;
  late PhysicalKeyboardKey selectedKey = defaultKey;

  bool isAlwaysOnTop = true;

  final List<HotKeyModifier> modifiers = [
    HotKeyModifier.control,
    HotKeyModifier.alt,
    HotKeyModifier.shift,
    HotKeyModifier.meta,
  ];

  final List<PhysicalKeyboardKey> keys = [
    PhysicalKeyboardKey.keyA,
    PhysicalKeyboardKey.keyB,
    PhysicalKeyboardKey.keyD,
    PhysicalKeyboardKey.keyE,
    PhysicalKeyboardKey.keyF,
    PhysicalKeyboardKey.keyG,
    PhysicalKeyboardKey.keyH,
    PhysicalKeyboardKey.keyK,
    PhysicalKeyboardKey.keyL,
    PhysicalKeyboardKey.keyM,
    PhysicalKeyboardKey.keyP,
    PhysicalKeyboardKey.keyQ,
    PhysicalKeyboardKey.keyR,
    PhysicalKeyboardKey.keyS,
    PhysicalKeyboardKey.keyT,
    PhysicalKeyboardKey.keyW,
    PhysicalKeyboardKey.keyX,
    PhysicalKeyboardKey.keyY,
    PhysicalKeyboardKey.keyZ,
  ];

  @override
  void initState() {
    super.initState();
    selectedModifier = HotkeyService.modifierKey;
    selectedKey = HotkeyService.mainKey;
    isAlwaysOnTop = OverlayService.isAlwaysOnTop;
  }
  Future<void> saveConfiguration() async {
    try {
      await HotkeyService.updateHotkey(
        modifier: selectedModifier,
        key: selectedKey,
      );

      if (!mounted) return;

      await OverlayService.setAlwaysOnTop(isAlwaysOnTop);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuration updated successfully'),
        ),
      );

    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$error'),
        ),
      );
    }


  }

  @override

  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configuration'),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overlay shortcut',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Choose the keyboard combination used to show QuestBoard.',
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<HotKeyModifier>(
                    initialValue: selectedModifier,
                    decoration: const InputDecoration(
                      labelText: 'Modifier key',
                      border: OutlineInputBorder(),
                    ),

                    items: modifiers.map((modifier) {
                      return DropdownMenuItem(
                        value: modifier,
                        child: Text(modifier.name[0].toUpperCase() + modifier.name.substring(1),),
                      );
                    }).toList(),

                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedModifier = value;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: DropdownButtonFormField<PhysicalKeyboardKey>(
                    initialValue: selectedKey,
                    decoration: const InputDecoration(
                      labelText: 'Main key',
                      border: OutlineInputBorder(),
                    ),

                    items: keys.map((key) {
                      return DropdownMenuItem(
                        value: key,
                        child: Text(key.keyLabel.isNotEmpty ? key.keyLabel.toUpperCase() : key.debugName ?? key.toString(),),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedKey = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Current selection: '
                  '${selectedModifier.name[0].toUpperCase()}'
                  '${selectedModifier.name.substring(1)} + '
                  '${selectedKey.keyLabel.isNotEmpty
                  ? selectedKey.keyLabel.toUpperCase()
                  : selectedKey.debugName ?? selectedKey.toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Always on top'),
              subtitle: const Text(
                'Keep the overlay above other windows.',
              ),
              value: isAlwaysOnTop,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  isAlwaysOnTop = value;
                });
              },
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),

        FilledButton(
          onPressed: saveConfiguration,
          child: const Text('Save'),
        ),
      ],
    );
  }
}