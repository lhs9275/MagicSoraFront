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

class QuestionHistoryArchiveSummaryCard extends StatelessWidget {
  const QuestionHistoryArchiveSummaryCard({
    required this.totalCount,
    required this.filteredCount,
    required this.favoriteCount,
    required this.hasKeyword,
    super.key,
  });

  final int totalCount;
  final int filteredCount;
  final int favoriteCount;
  final bool hasKeyword;

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
            '질문 아카이브',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasKeyword ? '찾고 싶은 질문만 바로 보세요' : '다시 꺼내볼 질문을 모아뒀어요',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 28, height: 1.15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasKeyword
                          ? '검색 결과와 전체 기록 수를 같이 보여줘서 지금 얼마나 좁혀졌는지 바로 알 수 있습니다.'
                          : '질문 흐름을 한 번에 훑고, 필요한 문장만 빠르게 다시 찾을 수 있게 정리했습니다.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.55),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              _ArchiveAccentPill(
                label: '검색 결과',
                value: '${hasKeyword ? filteredCount : 0}개',
              ),
            ],
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

class QuestionHistoryArchiveSectionHeader extends StatelessWidget {
  const QuestionHistoryArchiveSectionHeader({
    required this.totalCount,
    required this.filteredCount,
    required this.hasKeyword,
    required this.selectedSortMode,
    required this.isSortAscending,
    required this.onSortChanged,
    required this.onSortDirectionToggle,
    super.key,
  });

  final int totalCount;
  final int filteredCount;
  final bool hasKeyword;
  final QuestionHistorySortMode selectedSortMode;
  final bool isSortAscending;
  final ValueChanged<QuestionHistorySortMode> onSortChanged;
  final VoidCallback onSortDirectionToggle;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasKeyword ? '검색 결과' : '전체 질문 목록',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          hasKeyword
              ? '총 $totalCount개 중 $filteredCount개가 일치합니다.'
              : '$totalCount개의 질문을 순서대로 다시 볼 수 있어요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    final sortControls = _QuestionSortControls(
      selectedMode: selectedSortMode,
      isAscending: isSortAscending,
      onChanged: onSortChanged,
      onDirectionToggle: onSortDirectionToggle,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 460;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: sortControls,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 12),
            sortControls,
          ],
        );
      },
    );
  }
}

class _ArchiveAccentPill extends StatelessWidget {
  const _ArchiveAccentPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 22, height: 1.1),
          ),
        ],
      ),
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

class _QuestionSortControls extends StatelessWidget {
  const _QuestionSortControls({
    required this.selectedMode,
    required this.isAscending,
    required this.onChanged,
    required this.onDirectionToggle,
  });

  final QuestionHistorySortMode selectedMode;
  final bool isAscending;
  final ValueChanged<QuestionHistorySortMode> onChanged;
  final VoidCallback onDirectionToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<QuestionHistorySortMode>(
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
            trailingIcon: Icons.keyboard_arrow_down_rounded,
          ),
        ),
        const SizedBox(width: 4),
        _SortDirectionButton(
          isAscending: isAscending,
          onPressed: onDirectionToggle,
        ),
      ],
    );
  }
}

class _SortDirectionButton extends StatelessWidget {
  const _SortDirectionButton({
    required this.isAscending,
    required this.onPressed,
  });

  final bool isAscending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            isAscending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: AppTheme.primaryDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SortControlButton extends StatelessWidget {
  const _SortControlButton({
    required this.icon,
    required this.label,
    this.trailingIcon,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowTint.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
          if (trailingIcon != null) ...[
            const SizedBox(width: 4),
            Icon(trailingIcon, size: 18, color: AppTheme.textSecondary),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
