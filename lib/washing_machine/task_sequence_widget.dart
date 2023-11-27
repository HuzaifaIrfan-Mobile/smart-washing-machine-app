import 'package:flutter/material.dart';

import 'labels.dart';

import 'washing_machine.dart';

Widget taskSequenceView() {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int x = 0; x < 8; x++) ...[
            Column(
              children: [
                washingMachineTasksIcons[WashingMachine.instance.taskSequence[x]
                    [0]],
                Text(washingMachineTasksLabel[
                    WashingMachine.instance.taskSequence[x][0]]),
              ],
            ),
          ],
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int x = 8; x < 16; x++) ...[
            Column(
              children: [
                washingMachineTasksIcons[WashingMachine.instance.taskSequence[x]
                    [0]],
                Text(washingMachineTasksLabel[
                    WashingMachine.instance.taskSequence[x][0]]),
              ],
            ),
          ],
        ],
      ),
    ],
  );
}
