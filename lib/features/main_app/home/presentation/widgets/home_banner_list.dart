import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solo1/features/main_app/home/domain/entities/home_banner.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

class HomeBannerList extends StatefulWidget {
  final List<HomeBanner> items;
  const HomeBannerList({super.key, required this.items});
  @override
  State<HomeBannerList> createState() => _HomeBannerListState();
}

class _HomeBannerListState extends State<HomeBannerList> {
  late final PageController _controller;
  int _current = 0;

  List<HomeBanner> _ensureMinBanners(List<HomeBanner> src) {
    if (src.length >= 2) return src;
    const seed1 = HomeBanner(id: 'seed1', title: 'Топ агенты получают +1%', imageUrl: '', active: true, priority: 1, linkUrl: '', type: 'banner', description: 'Продавайте больше всех!');
    const seed2 = HomeBanner(id: 'seed2', title: 'Акция: кешбэк', imageUrl: '', active: true, priority: 1, linkUrl: '', type: 'banner', description: 'Проверьте детали в новостях');
    const seed3 = HomeBanner(id: 'seed3', title: 'Обучение доступно', imageUrl: '', active: true, priority: 1, linkUrl: '', type: 'banner', description: 'Начните прямо сейчас');
    if (src.isEmpty) return [seed1, seed2, seed3];
    return [src.first, seed1, seed2];
  }
  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 4));
        if (!mounted) return false;
        final items = _ensureMinBanners(widget.items.where((b) => b.active).toList());
        if (items.length <= 1) return true;
        _current = (_current + 1) % items.length;
        _controller.animateToPage(_current, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        return true;
      });
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomeBannerList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final items = _ensureMinBanners(widget.items.where((b) => b.active).toList());
    if (_current >= items.length) {
      _current = 0;
    }
  }

  Future<void> _onTap(HomeBanner e) async {
    final url = e.linkUrl.trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showBannerModal(HomeBanner e) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.15),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    children: [
                      Expanded(child: Text(e.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                      IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (e.description.isNotEmpty) Text(e.description, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      if (e.linkUrl.isNotEmpty) ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); _onTap(e); }, child: const Text('Перейти')),
                    ],
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _ensureMinBanners(widget.items.where((b) => b.active).toList());
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final e = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: GestureDetector(
                  onTap: () => _onTap(e),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4A69FF), Color(0xFF00BFA5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        if (e.imageUrl.isNotEmpty)
                          Image.network(e.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [const Color(0xFF4A69FF).withValues(alpha: 0.35), const Color(0xFF00BFA5).withValues(alpha: 0.35)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: 70,
                          child: GestureDetector(
                            onTap: () => _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white30,
                              child: const Icon(Icons.chevron_left, color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 70,
                          child: GestureDetector(
                            onTap: () => _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white30,
                              child: const Icon(Icons.chevron_right, color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 16,
                          child: GestureDetector(
                            onTap: () => _showBannerModal(e),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white30,
                              child: const Icon(Icons.info_outline, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                              if (e.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(e.description, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                                ),
                              const SizedBox(height: 10),
                              Row(
                                children: List.generate(items.length, (i) {
                                  final active = i == _current;
                                  return Container(
                                    width: active ? 24 : 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: active ? Colors.white : Colors.white38,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 0),
      ],
    );
  }
}