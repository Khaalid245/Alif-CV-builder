import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/models/template_model.dart';

class TemplateBrandingWidget extends StatefulWidget {
  final TemplateModel template;

  const TemplateBrandingWidget({
    super.key,
    required this.template,
  });

  @override
  State<TemplateBrandingWidget> createState() => _TemplateBrandingWidgetState();
}

class _TemplateBrandingWidgetState extends State<TemplateBrandingWidget> {
  // Color customization
  Color _primaryColor = const Color(0xFF2563eb);
  Color _secondaryColor = const Color(0xFF64748b);
  Color _accentColor = const Color(0xFF0ea5e9);
  
  // Typography
  String _fontFamily = 'Inter';
  double _fontSize = 14.0;
  
  // Layout
  double _marginTop = 20.0;
  double _marginBottom = 20.0;
  double _sectionSpacing = 15.0;

  final List<String> _availableFonts = [
    'Inter',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Source Sans Pro',
    'Poppins',
    'Nunito',
  ];

  final List<Color> _presetColors = [
    const Color(0xFF2563eb), // Blue
    const Color(0xFF059669), // Green
    const Color(0xFFdc2626), // Red
    const Color(0xFF7c3aed), // Purple
    const Color(0xFFea580c), // Orange
    const Color(0xFF0891b2), // Cyan
    const Color(0xFFbe123c), // Rose
    const Color(0xFF4338ca), // Indigo
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color customization
          _buildColorCustomization(),
          const SizedBox(height: 24),
          
          // Typography
          _buildTypographyCustomization(),
          const SizedBox(height: 24),
          
          // Layout spacing
          _buildLayoutCustomization(),
          const SizedBox(height: 24),
          
          // Preview and apply
          _buildPreviewSection(),
        ],
      ),
    );
  }

  Widget _buildColorCustomization() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.palette, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Color Scheme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Color presets
            Text(
              'Quick Presets',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetColors.map((color) => GestureDetector(
                onTap: () => setState(() => _primaryColor = color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _primaryColor == color ? Colors.black : Colors.grey[300]!,
                      width: _primaryColor == color ? 3 : 1,
                    ),
                  ),
                  child: _primaryColor == color
                      ? const Icon(LucideIcons.check, color: Colors.white, size: 20)
                      : null,
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            
            // Custom colors
            Text(
              'Custom Colors',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            
            _buildColorPicker(
              label: 'Primary Color',
              color: _primaryColor,
              onChanged: (color) => setState(() => _primaryColor = color),
            ),
            const SizedBox(height: 12),
            
            _buildColorPicker(
              label: 'Secondary Color',
              color: _secondaryColor,
              onChanged: (color) => setState(() => _secondaryColor = color),
            ),
            const SizedBox(height: 12),
            
            _buildColorPicker(
              label: 'Accent Color',
              color: _accentColor,
              onChanged: (color) => setState(() => _accentColor = color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypographyCustomization() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.type, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Typography',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Font family
            Text(
              'Font Family',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            
            DropdownButtonFormField<String>(
              value: _fontFamily,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _availableFonts.map((font) => DropdownMenuItem(
                value: font,
                child: Text(
                  font,
                  style: TextStyle(fontFamily: font),
                ),
              )).toList(),
              onChanged: (value) => setState(() => _fontFamily = value!),
            ),
            const SizedBox(height: 16),
            
            // Font size
            Text(
              'Base Font Size: ${_fontSize.toInt()}px',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            
            Slider(
              value: _fontSize,
              min: 10,
              max: 18,
              divisions: 8,
              onChanged: (value) => setState(() => _fontSize = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutCustomization() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.layout, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Layout Spacing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Margin top
            Text(
              'Top Margin: ${_marginTop.toInt()}px',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            
            Slider(
              value: _marginTop,
              min: 0,
              max: 50,
              divisions: 10,
              onChanged: (value) => setState(() => _marginTop = value),
            ),
            const SizedBox(height: 16),
            
            // Margin bottom
            Text(
              'Bottom Margin: ${_marginBottom.toInt()}px',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            
            Slider(
              value: _marginBottom,
              min: 0,
              max: 50,
              divisions: 10,
              onChanged: (value) => setState(() => _marginBottom = value),
            ),
            const SizedBox(height: 16),
            
            // Section spacing
            Text(
              'Section Spacing: ${_sectionSpacing.toInt()}px',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            
            Slider(
              value: _sectionSpacing,
              min: 5,
              max: 30,
              divisions: 5,
              onChanged: (value) => setState(() => _sectionSpacing = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.eye, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Preview Customization',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Preview container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(_marginTop),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sample header
                  Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: _fontSize + 10,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  SizedBox(height: _sectionSpacing / 2),
                  
                  Text(
                    'Software Engineer',
                    style: TextStyle(
                      fontSize: _fontSize + 2,
                      color: _secondaryColor,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  SizedBox(height: _sectionSpacing),
                  
                  // Sample section
                  Container(
                    width: 40,
                    height: 2,
                    color: _accentColor,
                  ),
                  SizedBox(height: _sectionSpacing / 2),
                  
                  Text(
                    'Professional Summary',
                    style: TextStyle(
                      fontSize: _fontSize + 2,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  SizedBox(height: _sectionSpacing / 2),
                  
                  Text(
                    'This is a sample text to demonstrate how your customization will look in the final CV.',
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: Colors.grey[700],
                      fontFamily: _fontFamily,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: _marginBottom),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetToDefaults,
                    child: const Text('Reset to Defaults'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyCustomization,
                    child: const Text('Apply Customization'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker({
    required String label,
    required Color color,
    required Function(Color) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        GestureDetector(
          onTap: () => _showColorPicker(color, onChanged),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(Color currentColor, Function(Color) onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetColors.map((color) => GestureDetector(
              onTap: () {
                onChanged(color);
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: currentColor == color ? Colors.black : Colors.grey[300]!,
                    width: currentColor == color ? 3 : 1,
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _primaryColor = const Color(0xFF2563eb);
      _secondaryColor = const Color(0xFF64748b);
      _accentColor = const Color(0xFF0ea5e9);
      _fontFamily = 'Inter';
      _fontSize = 14.0;
      _marginTop = 20.0;
      _marginBottom = 20.0;
      _sectionSpacing = 15.0;
    });
  }

  void _applyCustomization() {
    final customBranding = {
      'primary_color': '#${_primaryColor.value.toRadixString(16).substring(2)}',
      'secondary_color': '#${_secondaryColor.value.toRadixString(16).substring(2)}',
      'accent_color': '#${_accentColor.value.toRadixString(16).substring(2)}',
      'font_family': _fontFamily,
      'font_size_base': _fontSize.toInt(),
      'margin_top': _marginTop.toInt(),
      'margin_bottom': _marginBottom.toInt(),
      'section_spacing': _sectionSpacing.toInt(),
    };

    // Apply customization (this would typically update the provider)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Customization applied successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}