import 'package:flutter/material.dart';
import 'package:qeyafa/features/measurement/data/measurement_result.dart';

/// شاشة عرض نتائج القياسات
class MeasurementResultScreen extends StatelessWidget {
  final MeasurementResult result;

  const MeasurementResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'نتائج القياس',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              _buildHeaderCard(context),
              
              const SizedBox(height: 24),
              
              // Total Height Card
              _buildTotalHeightCard(),
              
              const SizedBox(height: 24),
              
              // Measurements Grid
              _buildMeasurementsGrid(),
              
              const SizedBox(height: 32),
              
              // Done Button
              _buildDoneButton(context),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'قياساتك جاهزة',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تم الحساب باستخدام ${result.calibrationType == CalibrationType.manualHeight ? "المعايرة اليدوية" : "البطاقة المرجعية"}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalHeightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.height,
              size: 32,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الطول الكلي',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.totalHeight.toStringAsFixed(1)} سم',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsGrid() {
    final measurements = [
      _MeasurementItem(
        icon: Icons.straighten,
        label: 'عرض الكتفين',
        value: result.shoulderWidth,
        color: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF388E3C),
      ),
      _MeasurementItem(
        icon: Icons.fitness_center,
        label: 'محيط الصدر',
        value: result.chestCircumference,
        color: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFE65100),
      ),
      _MeasurementItem(
        icon: Icons.accessibility_new,
        label: 'محيط الخصر',
        value: result.waistCircumference,
        color: const Color(0xFFF3E5F5),
        iconColor: const Color(0xFF7B1FA2),
      ),
      _MeasurementItem(
        icon: Icons.person_outline,
        label: 'محيط الوركين',
        value: result.hipCircumference,
        color: const Color(0xFFE1F5FE),
        iconColor: const Color(0xFF0277BD),
      ),
      _MeasurementItem(
        icon: Icons.back_hand,
        label: 'طول الذراع',
        value: result.armLength,
        color: const Color(0xFFFCE4EC),
        iconColor: const Color(0xFFC2185B),
      ),
      _MeasurementItem(
        icon: Icons.swap_vert,
        label: 'المسافة الداخلية',
        value: result.inseam,
        color: const Color(0xFFF1F8E9),
        iconColor: const Color(0xFF689F38),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: measurements.length,
      itemBuilder: (context, index) {
        final item = measurements[index];
        return _buildMeasurementCard(item);
      },
    );
  }

  Widget _buildMeasurementCard(_MeasurementItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              size: 28,
              color: item.iconColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${item.value.toStringAsFixed(1)} سم',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check, size: 24),
          SizedBox(width: 8),
          Text(
            'تم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementItem {
  final IconData icon;
  final String label;
  final double value;
  final Color color;
  final Color iconColor;

  _MeasurementItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconColor,
  });
}
