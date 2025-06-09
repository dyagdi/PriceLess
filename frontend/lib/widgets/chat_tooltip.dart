import 'package:flutter/material.dart';

enum ChatTooltipPosition { bottom, top }
enum ChatTooltipTail { right, middle, left }

class ChatTooltip extends StatelessWidget {
  final String message;
  final VoidCallback onNext;
  final bool isLast;
  final ChatTooltipPosition position;
  final String? nextLabel;
  final ChatTooltipTail tailPosition;

  const ChatTooltip({
    Key? key,
    required this.message,
    required this.onNext,
    this.isLast = false,
    this.position = ChatTooltipPosition.bottom,
    this.nextLabel,
    this.tailPosition = ChatTooltipTail.right,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: position == ChatTooltipPosition.bottom ? 100 : null,
      top: position == ChatTooltipPosition.top ? 100 : null,
      left: 20,
      right: 20,
      child: CustomPaint(
        painter: _ChatBubblePainter(
          color: Colors.green[800]!,
          position: position,
          tailPosition: tailPosition,
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onNext,
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      isLast ? 'Anladım' : (nextLabel ?? 'Next'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubblePainter extends CustomPainter {
  final Color color;
  final ChatTooltipPosition position;
  final ChatTooltipTail tailPosition;
  _ChatBubblePainter({required this.color, required this.position, required this.tailPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double tailBase;
    double tailTip;
    if (tailPosition == ChatTooltipTail.right) {
      tailBase = size.width - 40;
      tailTip = size.width - 32;
    } else if (tailPosition == ChatTooltipTail.middle) {
      tailBase = size.width / 2 - 8;
      tailTip = size.width / 2;
    } else {
      tailBase = 40;
      tailTip = 32;
    }

    if (position == ChatTooltipPosition.bottom) {
      final rrect = RRect.fromLTRBR(
        0,
        0,
        size.width,
        size.height - 16,
        const Radius.circular(24),
      );
      canvas.drawRRect(rrect, paint);
      final path = Path();
      path.moveTo(tailBase, size.height - 16);
      path.lineTo(tailBase + 16, size.height - 16);
      path.lineTo(tailTip, size.height + 8);
      path.close();
      canvas.drawPath(path, paint);
    } else {
      final rrect = RRect.fromLTRBR(
        0,
        16,
        size.width,
        size.height,
        const Radius.circular(24),
      );
      canvas.drawRRect(rrect, paint);
      final path = Path();
      path.moveTo(tailBase, 16);
      path.lineTo(tailBase + 16, 16);
      path.lineTo(tailTip, -8);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 