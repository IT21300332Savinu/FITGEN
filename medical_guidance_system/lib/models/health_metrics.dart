import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HealthMetricCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final String status;
  final IconData? icon;
  final double? progress;
  final String? target;
  final String? description;
  final VoidCallback? onTap;

  const HealthMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    this.icon,
    this.progress,
    this.target,
    this.description,
    this.onTap,
  });

  @override
  State<HealthMetricCard> createState() => _HealthMetricCardState();
}

class _HealthMetricCardState extends State<HealthMetricCard> {
  bool isHovered = false;

  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform:
              isHovered
                  ? (Matrix4.identity()..scale(1.02))
                  : Matrix4.identity(),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1e1e1e), Color(0xFF252525)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color:
                  isHovered
                      ? Colors.orange.withOpacity(0.5)
                      : Colors.grey[800]!,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isHovered
                    ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ]
                    : [],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.description != null)
                        Tooltip(
                          message: widget.description!,
                          child: const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.status,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Value and Unit
              Row(
                children: [
                  if (widget.icon != null)
                    Icon(
                      widget.icon,
                      size: 30,
                      color: Colors.orange,
                    ).animate().rotate(begin: 0, end: isHovered ? 1 : 0),
                  const SizedBox(width: 8),
                  Text(
                    widget.value,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.unit,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // Progress Bar
              if (widget.progress != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: widget.progress! / 100,
                      backgroundColor: Colors.grey[800],
                      color: Colors.orange,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.progress!.toInt()}%',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (widget.target != null)
                          Text(
                            'Target: ${widget.target}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

              // Details Button
              if (widget.onTap != null)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Details',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                      ),
                      const Icon(Icons.arrow_right, color: Colors.orange),
                    ],
                  ).animate().moveX(begin: 0, end: isHovered ? 5 : 0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
