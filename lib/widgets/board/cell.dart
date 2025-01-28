import 'package:flutter/material.dart';

class GameCell extends StatelessWidget {
  final int row;
  final int col;
  final dynamic value;
  final bool isSelected;
  final VoidCallback onTap;
  final Set<int> validNumbers;

  const GameCell({
    super.key,
    required this.row,
    required this.col,
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.validNumbers,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(decoration: BoxDecoration(color: _getCellColor()), child: Center(child: _buildCellContent())),
    );
  }

  Color _getCellColor() {
    if (isSelected) {
      return Colors.blue.withOpacity(0.3);
    }

    // 3x3 박스의 배경색 구분
    if ((row ~/ 3 + col ~/ 3) % 2 == 0) {
      return Colors.grey.withOpacity(0.1);
    }

    return Colors.transparent;
  }

  Widget _buildCellContent() {
    // 체스 기물인 경우
    if (value is String) {
      return Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
    }

    // 숫자인 경우
    if (value is int) {
      return Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500));
    }

    // 빈 셀이면서 힌트가 있는 경우
    if (validNumbers.isNotEmpty) {
      return _buildHints();
    }

    return const SizedBox.shrink();
  }

  Widget _buildHints() {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(2),
      children: List.generate(9, (index) {
        final number = index + 1;
        if (validNumbers.contains(number)) {
          return Center(child: Text(number.toString(), style: const TextStyle(fontSize: 8, color: Colors.grey)));
        }
        return const SizedBox.shrink();
      }),
    );
  }
}

/// 숫자 입력 패드 위젯
class NumberInputPad extends StatelessWidget {
  final Function(int) onNumberSelected;
  final VoidCallback onErase;
  final Set<int>? availableNumbers;

  const NumberInputPad({super.key, required this.onNumberSelected, required this.onErase, this.availableNumbers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 숫자 버튼들 (1-9)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(9, (index) {
              final number = index + 1;
              final isAvailable = availableNumbers?.contains(number) ?? true;

              return SizedBox(
                width: 48,
                height: 48,
                child: ElevatedButton(
                  onPressed: isAvailable ? () => onNumberSelected(number) : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: isAvailable ? Colors.blue : Colors.grey.shade300,
                  ),
                  child: Text(
                    number.toString(),
                    style: TextStyle(fontSize: 20, color: isAvailable ? Colors.white : Colors.grey.shade700),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          // 지우기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onErase,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Erase', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
