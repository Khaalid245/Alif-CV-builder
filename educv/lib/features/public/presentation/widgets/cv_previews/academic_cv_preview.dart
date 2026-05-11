import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class AcademicCVPreview extends StatelessWidget {
  const AcademicCVPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildDivider(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 35,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 45,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 2,
      color: const Color(0xFF2C2C2C),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Education (most prominent)
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 140,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 120,
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E3E8),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 100,
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E3E8),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          const SizedBox(height: 16),

          // Research Experience
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 6),

          ...List.generate(
              2,
              (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: [110, 105][index].toDouble(),
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0A0A),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: [130, 125][index].toDouble(),
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E3E8),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Container(
                          width: [95, 90][index].toDouble(),
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E3E8),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  )),

          const SizedBox(height: 12),

          // Publications
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 6),

          // Publication entries (italic style)
          ...List.generate(
              2,
              (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: [150, 145][index].toDouble(),
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A4A4A),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: [120, 115][index].toDouble(),
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A4A4A),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  )),

          const SizedBox(height: 12),

          // Awards
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 110,
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E3E8),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 95,
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E3E8),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
