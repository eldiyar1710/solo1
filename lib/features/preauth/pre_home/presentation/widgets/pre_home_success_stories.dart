import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/l10n/l10n.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

class PreHomeSuccessStories extends StatelessWidget {
  const PreHomeSuccessStories({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stories = [
      {
        'name': 'Алия К.',
        'income': '500 000 ₸',
        'incomeValue': 500000,
        'color': Colors.amberAccent,
        'image': 'assets/foto/Алия К.jpg',
        'story': 'Начала с 3 подключений в кофейнях рядом с домом. Предлагала владельцам приложение для POS-терминалов и показала выгоды. Через 3 месяца расширила сеть до 12 подключений и вышла на стабильный доход.',
        'howTo': 'Зарегистрируйтесь, пройдите обучение, начните с ближайших кофеен и магазинов. Предложите приложение для POS-терминалов, покажите пользу и соберите первые подключения.',
        'points': 12,
        'avgCheck': 6500,
        'conversion': 0.28,
        'role': 'Домохозяйка',
        'tips': [
          'Начните с соседних кафе и знакомых владельцев',
          'Покажите выгоды приложения и примеры отчётов',
          'Соберите отзывы и масштабируйте сеть подключений',
        ],
      },
      {
        'name': 'Гульнара С.',
        'income': '1 200 000 ₸',
        'incomeValue': 1200000,
        'color': Colors.blueAccent,
        'image': 'assets/foto/Гульнара С.jpg',
        'story': 'Сконцентрировалась на ТЦ и маркетплейсах. Заключила 20+ договоров на подключение приложения для POS-терминалов, выстроила партнёрства и регулярную поддержку, что повысило лояльность.',
        'howTo': 'Ищите точки с высоким трафиком, предложите пилот на неделю для приложения, покажите рост показателей. Договоритесь о партнёрстве и регулярных отчётах, закрепите подключения контрактом.',
        'points': 24,
        'avgCheck': 8200,
        'conversion': 0.34,
        'role': 'Офисный сотрудник',
        'tips': [
          'Ищите точки с высоким трафиком в ТЦ',
          'Предложите недельный пилот и покажите рост показателей',
          'Закрепите подключения партнёрским соглашением',
        ],
      },
      {
        'name': 'Ерлан М.',
        'income': '750 000 ₸',
        'incomeValue': 750000,
        'color': Colors.purpleAccent,
        'image': 'assets/foto/Ерлан М.jpg',
        'story': 'Сделал ставку на сервис и скорость. Начал с малого бизнеса в районе, быстро подключал приложение для POS-терминалов и выстроил сопровождение через шаблоны и чек-листы.',
        'howTo': 'Выберите район, подготовьте сценарии презентации приложения, список выгод и шаблоны сопровождения. Держите высокий SLA и обратную связь, масштабируйте за счёт системности.',
        'points': 15,
        'avgCheck': 7000,
        'conversion': 0.31,
        'role': 'Студент',
        'tips': [
          'Выберите район и составьте маршрут презентаций',
          'Подготовьте шаблоны выгоды и сопровождения',
          'Держите высокий SLA и обратную связь',
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.people_alt, color: Colors.white70),
              const SizedBox(width: 8),
              Text(l10n.prehome_success_stories_title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: stories.length,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (context, index) {
              final story = stories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: InkWell(
                  onTap: () => _showStoryDetails(context, story),
                  child: _buildStoryCard(context, story),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCard(BuildContext context, Map<String, dynamic> story) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: [
          Hero(
            tag: 'bg-${story['name']}',
            child: Image.asset(
              story['image'] as String,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0xAA000000)],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: story['name'] as String,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage(story['image'] as String),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(story['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(story['role'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.white70),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    story['income'] as String,
                    style: TextStyle(
                      color: story['color'] as Color,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  Text('Подключений: ${story['points']}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStoryDetails(BuildContext context, Map<String, dynamic> story) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (ctx, controller) {
            double offset = 0;
            return StatefulBuilder(
              builder: (ctx, setState) => GlassContainer(
                blur: 20,
                opacity: 0.15,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: story['name'] as String,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: AssetImage(story['image'] as String),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story['name'] as String,
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: (story['incomeValue'] as int).toDouble()),
                                  duration: const Duration(milliseconds: 900),
                                  builder: (ctx, value, _) => Text(
                                    '${value.toInt()} ₸ ${l10n.prehome_story_period}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            setState(() {
                              offset = n.metrics.pixels;
                            });
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: controller,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Hero(
                                      tag: 'bg-${story['name']}',
                                      child: Transform.translate(
                                        offset: Offset(0, -offset * 0.12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.asset(
                                            story['image'] as String,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Color(0x00000000), Color(0xB3000000)],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text('История успеха', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(story['story'] as String, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GlassContainer(
                                        padding: const EdgeInsets.all(12),
                                        opacity: 0.12,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Точек', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                            Text('${story['points']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GlassContainer(
                                        padding: const EdgeInsets.all(12),
                                        opacity: 0.12,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Средний чек', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                            Text('${story['avgCheck']} ₸', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GlassContainer(
                                        padding: const EdgeInsets.all(12),
                                        opacity: 0.12,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Конверсия', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                            Text('${((story['conversion'] as double) * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                GlassContainer(
                                  padding: const EdgeInsets.all(12),
                                  opacity: 0.1,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: List.generate(6, (i) {
                                      final base = (story['points'] as int).toDouble();
                                      final factor = [0.4, 0.6, 0.75, 0.85, 0.95, 1.0][i];
                                      final double h = math.min(120.0, base * 2 * factor / 3);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Container(
                                          width: 14,
                                          height: h,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            gradient: const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text('Советы', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: (story['tips'] as List<String>).map((t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(t, style: const TextStyle(color: Colors.white70, fontSize: 14))),
                                      ],
                                    ),
                                  )).toList(),
                                ),
                                const SizedBox(height: 16),
                                Text('Доход по месяцам', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                GlassContainer(
                                  padding: const EdgeInsets.all(12),
                                  opacity: 0.1,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: ['Янв','Фев','Мар','Апр','Май','Июн'].map((m) => Expanded(
                                          child: Center(child: Text(m, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                                        )).toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: List.generate(6, (i) {
                                          final double total = (story['incomeValue'] as int).toDouble();
                                          final double base = total / 6;
                                          final List<double> factors = [0.6, 0.8, 1.0, 1.1, 1.2, 1.3];
                                          final double value = base * factors[i];
                                          final double h = math.min(120.0, value / (total / 3));
                                          return Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text('${value.toInt()} ₸', style: const TextStyle(color: Color(0xFFC78FFC), fontSize: 10)),
                                                const SizedBox(height: 4),
                                                Container(
                                                  height: h,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    gradient: const LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text('Как стать как ${story['name']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(story['howTo'] as String, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 16),
                                Text('Вы продаёте приложение для POS-терминалов кафе и магазинов. Агент получает оговорённый процент (например 10%) и пассивный доход в течение периода действия договорённости.', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => context.go(AppRoutes.register),
                                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                                  label: const Text('Зарегистрироваться', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9C27B0),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}