import 'package:flutter/material.dart';
import 'package:solo1/features/contor%20/admin/domain/entities/moderation_request_entity.dart';

class AdminRequestItem extends StatefulWidget {
  final ModerationRequestEntity item;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onContact;
  const AdminRequestItem({super.key, required this.item, required this.onApprove, required this.onReject, required this.onContact});
  @override
  State<AdminRequestItem> createState() => _AdminRequestItemState();
}

class _AdminRequestItemState extends State<AdminRequestItem> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))..forward();
  }
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    return SlideTransition(
      position: slide,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x4D8B3EFF), width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x408B3EFF), blurRadius: 20),
            BoxShadow(color: Color(0x5E000000), blurRadius: 32, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [
              Chip(
                label: Text('Ожидает проверки', style: TextStyle(color: Colors.black)),
                backgroundColor: Color(0xFFFFB800),
                padding: EdgeInsets.symmetric(horizontal: 8),
              ),
              Spacer(),
              Icon(Icons.remove_red_eye_outlined, color: Colors.white),
              SizedBox(width: 6),
              Text('Детали', style: TextStyle(color: Colors.white)),
            ]),
            const SizedBox(height: 12),
            Text(widget.item.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Агент: ${widget.item.agentId}', style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 12),
            Row(children: [
              _GreenButton(text: 'Одобрить', onPressed: widget.onApprove),
              const SizedBox(width: 12),
              _RedOutlinedButton(text: 'Отклонить', onPressed: widget.onReject),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: widget.onContact, child: const Text('Связаться')),
            ]),
          ],
        ),
      ),
    );
  }
}

class _GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _GreenButton({required this.text, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(color: const Color(0xFF00D4B4), borderRadius: BorderRadius.circular(30)),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _RedOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _RedOutlinedButton({required this.text, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFFF3B6B), width: 2)),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(color: Color(0xFFFF3B6B), fontWeight: FontWeight.bold)),
      ),
    );
  }
}