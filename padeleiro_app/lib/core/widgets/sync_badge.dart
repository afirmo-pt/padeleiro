import 'package:flutter/material.dart';
import 'package:padeleiro_app/core/theme/app_theme.dart';
import 'package:padeleiro_app/models/enums.dart';

/// Indicador visual compacto do estado de sincronização com o Firestore.
///
/// Apresenta um ícone + texto consoante o [SyncStatus]:
/// - [SyncStatus.pending] → spinner cinzento + "A guardar..."
/// - [SyncStatus.synced]  → checkmark verde + "Guardado"
/// - [SyncStatus.error]   → ícone de erro vermelho + "Erro ao guardar"
class SyncBadge extends StatelessWidget {
  const SyncBadge({super.key, required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        _buildIcon(),
        Text(
          _label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _color,
              ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    switch (status) {
      case SyncStatus.pending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        );
      case SyncStatus.synced:
        return Icon(Icons.check_circle_outline, size: 14, color: _color);
      case SyncStatus.error:
        return Icon(Icons.error_outline, size: 14, color: _color);
    }
  }

  String get _label {
    switch (status) {
      case SyncStatus.pending:
        return 'A guardar...';
      case SyncStatus.synced:
        return 'Guardado';
      case SyncStatus.error:
        return 'Erro ao guardar';
    }
  }

  Color get _color {
    switch (status) {
      case SyncStatus.pending:
        return Colors.grey;
      case SyncStatus.synced:
        return AppColors.success;
      case SyncStatus.error:
        return AppColors.error;
    }
  }
}
