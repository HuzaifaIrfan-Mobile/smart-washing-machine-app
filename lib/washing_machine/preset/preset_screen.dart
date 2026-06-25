import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../washing_machine.dart';

const _kPrefsKey = 'preset_task_sequence';

class _TaskDef {
  final String label;
  final int min;
  final int defaultVal;
  final int max;
  const _TaskDef(this.label, this.min, this.defaultVal, this.max);
}

const List<_TaskDef> kTasks = [
  _TaskDef('Waiting',    1,   5,    60),    // 0
  _TaskDef('Water Fill', 30,  300,   1200),  // 1
  _TaskDef('Spin',       30,  300,  600),   // 2
  _TaskDef('Soak',       60,  300,  1800),  // 3
  _TaskDef('Drain',      120, 300,  1200),  // 4
  _TaskDef('Dry',        60,  120,  300),   // 5
  _TaskDef('End',        20,  20,   30),    // 6
];

// Default wash program:
// [task, countdown, spin_time, wait_time]
// 0=Waiting, 1=Fill, 2=Spin, 3=Soak, 4=Drain, 6=End
final List<List<int>> kDefaultSequence = [
  [0, 1,   0, 0],  //  1 - Waiting
  [1, 300, 0, 0],  //  2 - Fill
  [2, 300, 5, 2],  //  3 - Wash (spin)
  [3, 300, 0, 0],  //  4 - Soak
  [4, 300, 0, 0],  //  5 - Drain
  [1, 300, 0, 0],  //  6 - Fill
  [2, 300, 5, 2],  //  7 - Wash (spin)
  [4, 300, 0, 0],  //  8 - Drain
  [2, 120, 0, 0],  //  9 - Spin (dry spin)
  [0, 1,   0, 0],  // 10 - Wait
  [0, 1,   0, 0],  // 11 - Wait
  [0, 1,   0, 0],  // 12 - Wait
  [0, 1,   0, 0],  // 13 - Wait
  [0, 1,   0, 0],  // 14 - Wait
  [0, 1,   0, 0],  // 15 - Wait
  [6, 20,  0, 0],  // 16 - End
];

class PresetScreen extends StatefulWidget {
  const PresetScreen({super.key});

  @override
  State<PresetScreen> createState() => _PresetScreenState();
}

class _PresetScreenState extends State<PresetScreen> {
  List<List<int>> _seq = kDefaultSequence.map((e) => List<int>.from(e)).toList();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {


    // Fall back to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefsKey);
      if (raw != null) {
        final decoded = (jsonDecode(raw) as List)
            .map<List<int>>((e) => List<int>.from(e))
            .toList();
        if (decoded.length == 16) {
          setState(() {
            _seq = decoded;
            _loading = false;
          });
          return;
        }
      }
    } catch (_) {}

    // Use built-in default
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsKey, jsonEncode(_seq));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preset saved'), duration: Duration(seconds: 2)),
      );
    }
  }

  void _onTaskChanged(int i, int? newTask) {
    if (newTask == null) return;
    final def = kTasks[newTask];
    setState(() {
      _seq[i][0] = newTask;
      _seq[i][1] = def.defaultVal;
      _seq[i][2] = newTask == 2 ? 5 : 0;
      _seq[i][3] = newTask == 2 ? 2 : 0;
    });
  }

  void _runPreset() {
    WashingMachine.instance.setTaskSequence(List.from(_seq));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sequence sent to machine')),
    );

     WashingMachine.instance.getTaskSequence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              itemCount: 16,
              itemBuilder: (_, i) => _StepCard(
                index: i,
                step: _seq[i],
                onTaskChanged: (v) => _onTaskChanged(i, v),
                onCountdownChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null) setState(() => _seq[i][1] = n);
                },
                onSpinTimeChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null) setState(() => _seq[i][2] = n);
                },
                onWaitTimeChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null) setState(() => _seq[i][3] = n);
                },
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _runPreset,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run Preset'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step card ─────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.step,
    required this.onTaskChanged,
    required this.onCountdownChanged,
    required this.onSpinTimeChanged,
    required this.onWaitTimeChanged,
  });

  final int index;
  final List<int> step;
  final ValueChanged<int?> onTaskChanged;
  final ValueChanged<String> onCountdownChanged;
  final ValueChanged<String> onSpinTimeChanged;
  final ValueChanged<String> onWaitTimeChanged;

  @override
  Widget build(BuildContext context) {
    final taskId = step[0];
    final def = kTasks[taskId];
    final isSpin = taskId == 2;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${index + 1}.',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: taskId,
                    decoration: const InputDecoration(
                      labelText: 'Task',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      kTasks.length,
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(kTasks[t].label),
                      ),
                    ),
                    onChanged: onTaskChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _NumField(
                    label: 'Countdown (s)',
                    hint: '${def.min}–${def.max}',
                    value: step[1],
                    onChanged: onCountdownChanged,
                  ),
                ),
                if (isSpin) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NumField(
                      label: 'Spin time (s)',
                      value: step[2],
                      onChanged: onSpinTimeChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NumField(
                      label: 'Wait time (s)',
                      value: step[3],
                      onChanged: onWaitTimeChanged,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable number field ─────────────────────────────────────────────────────

class _NumField extends StatelessWidget {
  const _NumField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final int value;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label$value'),
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}