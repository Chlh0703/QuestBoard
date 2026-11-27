import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:quest_board/services/hotkey_service.dart';

import '../controllers/overlay_controller.dart';
import '../services/configuration_service.dart';
import '../services/quest_service.dart';


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
  State<ConfigurationDialog> createState() => _ConfigurationDialogState();
}

class _ConfigurationDialogState extends State<ConfigurationDialog> {
  HotKeyModifier _savedModifier = HotkeyService.modifierKey;
  PhysicalKeyboardKey _savedKey = HotkeyService.mainKey;
  bool _savedAlwaysOnTop = OverlayController.alwaysOnTop;
  bool _savedNotifications = QuestService.notificationsEnabled;
  late HotKeyModifier selectedModifier = _savedModifier;
  late PhysicalKeyboardKey selectedKey = _savedKey;
  late bool isAlwaysOnTop = _savedAlwaysOnTop;
  late bool notificationsEnabled = _savedNotifications;

  final List<HotKeyModifier> modifiers = HotKeyModifier.values;
  final List<PhysicalKeyboardKey> keys = HotkeyService.supportedKeys;
  final ConfigurationService _configurationService = ConfigurationService();

  Future<void> saveConfiguration() async {
    if (_saving) return;
    setState(() => _saving = true);
    final modifier = selectedModifier;
    final key = selectedKey;
    final onTop = isAlwaysOnTop;
    final notifications = notificationsEnabled;
    try {
      if (modifier != _savedModifier || key != _savedKey) {
        await _configurationService.updateHotkey(modifier: modifier, key: key);
        _savedModifier = modifier;
        _savedKey = key;
      }
      if (onTop != _savedAlwaysOnTop) {
        await _configurationService.setOverlayAlwaysOnTop(onTop);
        _savedAlwaysOnTop = onTop;
      }
      if (notifications != _savedNotifications) {
        await _configurationService.setNotificationsEnabled(notifications);
        _savedNotifications = notifications;
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuration updated successfully'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  bool _saving = false;

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

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable notifications'),
              subtitle: const Text('Receive reminders for quests and tasks.'),
              value: notificationsEnabled,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  notificationsEnabled = value;
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
          onPressed: _saving ? null : saveConfiguration,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
