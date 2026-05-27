import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/app_user.dart';

/// Chip seleccionável que representa um jogador.
///
/// Apresenta as iniciais do jogador num avatar circular e o nome completo
/// como label. Quando [isSelected] é `true`, o chip é apresentado com fundo
/// na cor primária e um ícone de checkmark. O touch target mínimo é 48×48dp.
class PlayerChip extends StatelessWidget {
  const PlayerChip({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onTap,
  });

  final AppUser player;
  final bool isSelected;
  final VoidCallback onTap;

  /// Extrai as iniciais do nome completo (máximo 2 caracteres).
  String get _initials {
    final parts = player.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor =
        isSelected ? AppColors.primary : colorScheme.surfaceContainerHighest;
    final foregroundColor = isSelected ? AppColors.onPrimary : colorScheme.onSurface;
    final avatarBackground =
        isSelected ? AppColors.onPrimary.withValues(alpha: 0.2) : AppColors.primary;
    final avatarForeground = isSelected ? AppColors.onPrimary : AppColors.onPrimary;

    return Semantics(
      label: '${player.fullName}${isSelected ? ', seleccionado' : ''}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          // Garante touch target mínimo de 48×48dp
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar com iniciais
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: avatarBackground,
                    child: Text(
                      _initials,
                      style: TextStyle(
                        color: avatarForeground,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Nome do jogador
                  Text(
                    player.fullName,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  // Checkmark quando seleccionado
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: foregroundColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
