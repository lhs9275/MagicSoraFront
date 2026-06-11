import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';

enum QuestionHistorySortMode {
  date('날짜순', Icons.calendar_month_rounded),
  favorite('즐겨찾기순', Icons.star_rounded),
  text('문자순', Icons.sort_by_alpha_rounded);

  const QuestionHistorySortMode(this.label, this.icon);

  final String label;
  final IconData icon;
}

class QuestionHistoryFavoriteStarButton extends StatelessWidget {
  const QuestionHistoryFavoriteStarButton({
    required this.isFavorite,
    required this.onPressed,
    super.key,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
      icon: Icon(
        isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
        color: isFavorite
            ? AppTheme.accentGold
            : AppTheme.textTertiary.withValues(alpha: 0.9),
      ),
    );
  }
}

class QuestionHistoryDeleteButton extends StatelessWidget {
  const QuestionHistoryDeleteButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: '질문 기록 삭제',
      icon: const Icon(Icons.delete_outline_rounded),
      color: AppTheme.coral,
    );
  }
}

class QuestionHistoryArchiveSummaryCard extends StatelessWidget {
  const QuestionHistoryArchiveSummaryCard({
    required this.totalCount,
    required this.filteredCount,
    required this.favoriteCount,
    required this.hasKeyword,
    required this.ownerNickname,
    super.key,
  });

  final int totalCount;
  final int filteredCount;
  final int favoriteCount;
  final bool hasKeyword;
  final String? ownerNickname;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(20),
      color: Colors.white.withValues(alpha: 0.8),
      borderColor: AppTheme.skyBlue.withValues(alpha: 0.24),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasKeyword
                ? '찾고 싶은 질문만 바로 보세요'
                : '${_companionName(ownerNickname)} 함께 나눈\n이야기들을 모아뒀어요',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 28, height: 1.15),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ArchiveMetricTile(
                  label: '총 질문 수',
                  value: '$totalCount개',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ArchiveMetricTile(
                  label: '즐겨찾기 수',
                  value: '$favoriteCount개',
                  icon: Icons.star_rounded,
                  iconColor: AppTheme.accentGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _companionName(String? ownerNickname) {
  final trimmed = ownerNickname?.trim() ?? '';
  if (trimmed.isEmpty) {
    return '소라와';
  }
  return '$trimmed 님과';
}

class QuestionHistoryArchiveSectionHeader extends StatelessWidget {
  const QuestionHistoryArchiveSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '전체 질문 목록',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
      ],
    );
  }
}

class _ArchiveMetricTile extends StatelessWidget {
  const _ArchiveMetricTile({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(icon, color: iconColor ?? AppTheme.primaryDark, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class QuestionHistorySortControls extends StatelessWidget {
  const QuestionHistorySortControls({
    required this.selectedMode,
    required this.onChanged,
    super.key,
  });

  final QuestionHistorySortMode selectedMode;
  final ValueChanged<QuestionHistorySortMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<QuestionHistorySortMode>(
      initialValue: selectedMode,
      tooltip: '정렬 기준 선택',
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final mode in QuestionHistorySortMode.values)
          PopupMenuItem<QuestionHistorySortMode>(
            value: mode,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(mode.icon, size: 18, color: AppTheme.primaryDark),
                const SizedBox(width: 8),
                Text(mode.label),
              ],
            ),
          ),
      ],
      child: _SortControlButton(
        icon: selectedMode.icon,
        label: selectedMode.label,
      ),
    );
  }
}

class _SortControlButton extends StatelessWidget {
  const _SortControlButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppTheme.primaryDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
