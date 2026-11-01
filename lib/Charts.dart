import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'l10n/app_strings.dart';
/// Small hand-drawn chart widgets used by the Analytics / report pages.
/// No chart package is needed — everything is built from plain Flutter
/// widgets and one CustomPainter each, in the app's brown palette.

class ChartPoint {
  const ChartPoint(this.label, this.value);

  final String label;
  final int value;
}

class ChartSlice {
  const ChartSlice(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

/// White rounded card with a title, matching the other admin cards.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.brown[900],
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: const TextStyle(color: Colors.black45, fontSize: 11),
              ),
            ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class ChartEmptyNote extends StatelessWidget {
  const ChartEmptyNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black45, fontSize: 13),
      ),
    );
  }
}

/// One horizontal bar with a label on the left and a value on the right.
class BarRow extends StatelessWidget {
  const BarRow({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    this.labelWidth = 110,
    this.valueText,
  });

  final String label;
  final int value;
  final int max;
  final Color color;
  final double labelWidth;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    final fraction =
        max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 12,
                backgroundColor: Colors.brown[50],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              valueText ?? '$value',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical column chart (e.g. page views per day).
class VerticalBarChart extends StatelessWidget {
  const VerticalBarChart({
    super.key,
    required this.points,
    required this.color,
    this.height = 150,
  });

  final List<ChartPoint> points;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<int>(0, (m, p) => math.max(m, p.value));
    if (maxValue == 0) {
      return ChartEmptyNote(tr('c_no_data_period'));
    }

    return SizedBox(
      height: height + 26,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final p in points)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (p.value > 0)
                      Text(
                        '${p.value}',
                        style: const TextStyle(fontSize: 9),
                      ),
                    const SizedBox(height: 2),
                    Container(
                      height: math.max(2.0, p.value / maxValue * height * 0.8),
                      decoration: BoxDecoration(
                        color: p.value > 0 ? color : Colors.brown[100],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.label,
                      style: const TextStyle(fontSize: 9, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Line chart with dots and a light filled area (e.g. sign-ups per day).
class LineChart extends StatelessWidget {
  const LineChart({
    super.key,
    required this.points,
    required this.color,
    this.height = 130,
  });

  final List<ChartPoint> points;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<int>(0, (m, p) => math.max(m, p.value));
    if (maxValue == 0) {
      return ChartEmptyNote(tr('c_no_data_period'));
    }

    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _LinePainter(points: points, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final p in points)
              Expanded(
                child: Text(
                  p.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, color: Colors.black54),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.points, required this.color});

  final List<ChartPoint> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxValue =
        math.max(1, points.fold<int>(0, (m, p) => math.max(m, p.value)));
    const top = 10.0;
    final chartHeight = size.height - top;
    final step = size.width / points.length;

    final gridPaint = Paint()
      ..color = Colors.brown.withOpacity(0.10)
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = top + chartHeight * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final offsets = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = (i + 0.5) * step;
      final y = top + chartHeight - points[i].value / maxValue * chartHeight;
      offsets.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final o in offsets.skip(1)) {
      linePath.lineTo(o.dx, o.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(offsets.last.dx, top + chartHeight)
      ..lineTo(offsets.first.dx, top + chartHeight)
      ..close();
    canvas.drawPath(
      areaPath,
      Paint()
        ..color = color.withOpacity(0.14)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    final dotPaint = Paint()..color = color;
    final dotRing = Paint()..color = Colors.white;
    for (var i = 0; i < offsets.length; i++) {
      canvas.drawCircle(offsets[i], 4.5, dotRing);
      canvas.drawCircle(offsets[i], 3.2, dotPaint);

      if (points[i].value > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${points[i].value}',
            style: const TextStyle(fontSize: 9, color: Colors.black54),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(offsets[i].dx - tp.width / 2, offsets[i].dy - 16));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

/// Donut chart with the total in the middle and a legend on the side.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    this.centerLabel,
    this.size = 130,
  });

  final List<ChartSlice> slices;
  final String? centerLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (s, e) => s + e.value);

    return Row(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _DonutPainter(slices: slices, total: total),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[900],
                    ),
                  ),
                  if (centerLabel != null)
                    Text(
                      centerLabel!,
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in slices)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.label,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        total == 0
                            ? '${s.value}'
                            : '${s.value} (${(s.value * 100 / total).round()}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.total});

  final List<ChartSlice> slices;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 22.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.brown.withOpacity(0.10);
    canvas.drawArc(arcRect, 0, math.pi * 2, false, base);

    if (total <= 0) return;

    var start = -math.pi / 2;
    for (final s in slices) {
      if (s.value <= 0) continue;
      final sweep = s.value / total * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = s.color;
      canvas.drawArc(arcRect, start, math.max(0.0, sweep - 0.02), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.total != total;
}

/// Big number tile (same look as the admin dashboard tiles).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.note,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (note != null)
              Text(
                note!,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }
}