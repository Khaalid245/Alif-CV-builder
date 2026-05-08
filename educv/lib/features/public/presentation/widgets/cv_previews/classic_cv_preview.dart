import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_colors.dart';

class ClassicCVPreview extends StatelessWidget {
  const ClassicCVPreview({super.key});

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
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2E4A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'AK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2E4A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(child: _buildMainContent()),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact section
          Row(
            children: [
              Icon(
                LucideIcons.mail,
                size: 8,
                color: const Color(0xFF1A2E4A),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E3E8),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                LucideIcons.phone,
                size: 8,
                color: const Color(0xFF1A2E4A),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E3E8),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Skills section
          Container(
            width: 30,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2E4A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 4),
          
          // Skill bars
          ...List.generate(4, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E3E8),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: [35, 28, 32, 25][index].toDouble(),
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 8),
          
          // Languages
          Container(
            width: 35,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2E4A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 45,
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E3E8),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 40,
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

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
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
            width: 120,
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E3E8),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Experience
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 6),
          
          // Experience entries
          ...List.generate(2, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1565C0),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: [70, 65][index].toDouble(),
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0A),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: Container(
                    width: [90, 85][index].toDouble(),
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E3E8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 8),
          
          // Education
          Container(
            width: 45,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 4),
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
    );
  }
}