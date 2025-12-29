import 'package:flutter/material.dart';
import 'package:solo1/features/contor%20/moderator/domain/entities/moderator_request_entity.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

class ModeratorRequestItem extends StatelessWidget {
  final ModeratorRequestEntity item;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onContact;
  final VoidCallback? onCheck;
  const ModeratorRequestItem({super.key, required this.item, required this.onApprove, required this.onReject, required this.onContact, this.onCheck});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFA726).withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    item.status == 'pending' ? 'Ожидает проверки' : (item.status == 'approved' ? 'Одобрено' : 'Отклонено'),
                    style: TextStyle(color: item.status == 'pending' ? const Color(0xFFFFA726) : (item.status == 'approved' ? const Color(0xFF4CAF50) : const Color(0xFFE53935)), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                if (onCheck != null)
                  TextButton.icon(
                    onPressed: onCheck,
                    icon: const Icon(Icons.assignment_ind, color: Colors.white),
                    label: const Text('Проверить', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Агент: ${item.agentId}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Одобрить', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE53935),
                      side: const BorderSide(color: Color(0xFFE53935)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Отклонить', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(onPressed: onContact, icon: const Icon(Icons.call, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}