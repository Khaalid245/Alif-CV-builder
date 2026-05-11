import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_colors.dart';

class ModernCVPreview extends StatelessWidget {
  const ModernCVPreview({super.key});

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
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 90,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                LucideIcons.mail,
                size: 10,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.phone,
                size: 10,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Container(
                width: 50,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary section with left border
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0A),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E3E8),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 140,
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
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Experience section with timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0A),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Experience entries with timeline dots
                    ...List.generate(
                        2,
                        (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1565C0),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      if (index == 0)
                                        Container(
                                          width: 1,
                                          height: 20,
                                          color: const Color(0xFFE0E3E8),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: [80, 75][index].toDouble(),
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0A0A0A),
                                            borderRadius:
                                                BorderRadius.circular(1),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: [100, 95][index].toDouble(),
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0E3E8),
                                            borderRadius:
                                                BorderRadius.circular(1),
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Container(
                                          width: [85, 80][index].toDouble(),
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0E3E8),
                                            borderRadius:
                                                BorderRadius.circular(1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Skills section with chips
          Container(
            width: 35,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _buildSkillChip('Flutter', 40),
              _buildSkillChip('React', 35),
              _buildSkillChip('Python', 38),
              _buildSkillChip('Node.js', 42),
              _buildSkillChip('AWS', 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label, double width) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Container(
          width: width - 8,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
