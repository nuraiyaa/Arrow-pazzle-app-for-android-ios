import '../../shared/widgets/neo_icon.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final NeoIconType icon;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.icon,
  });

  static const List<Achievement> allAchievements = [
    Achievement(
      id: 'first_win',
      title: 'First Escape',
      description: 'Clear your very first puzzle stage',
      rewardCoins: 50,
      icon: NeoIconType.star,
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Lightning Speed',
      description: 'Clear a level in under 20 seconds',
      rewardCoins: 100,
      icon: NeoIconType.stopwatch,
    ),
    Achievement(
      id: 'combo_master',
      title: 'Combo Prodigy',
      description: 'Achieve a 5x escape combo in Timed Rush',
      rewardCoins: 150,
      icon: NeoIconType.trophy,
    ),
    Achievement(
      id: 'skin_collector',
      title: 'Style Icon',
      description: 'Unlock and equip a custom arrow skin',
      rewardCoins: 100,
      icon: NeoIconType.gift,
    ),
    Achievement(
      id: 'stage_10',
      title: 'Grid Veteran',
      description: 'Reach and conquer Stage 10',
      rewardCoins: 200,
      icon: NeoIconType.star,
    ),
  ];

  static Achievement getById(String id) {
    return allAchievements.firstWhere(
      (a) => a.id == id,
      orElse: () => allAchievements.first,
    );
  }
}
