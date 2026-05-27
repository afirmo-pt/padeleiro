import 'package:flutter/material.dart';

/// Card com gestos de swipe para acções de aprovação/rejeição.
///
/// Swipe para a direita (startToEnd) chama [onSwipeRight] — tipicamente
/// "Aprovar". Swipe para a esquerda (endToStart) chama [onSwipeLeft] —
/// tipicamente "Rejeitar". O card não é removido da lista: o `confirmDismiss`
/// devolve sempre `false` para que o widget [Dismissible] reverta a animação
/// e o card permaneça visível.
///
/// Usa [cardKey] como chave do [Dismissible] para que o Flutter identifique
/// correctamente cada item numa lista.
class SwipeActionCard extends StatelessWidget {
  const SwipeActionCard({
    super.key,
    required this.cardKey,
    required this.child,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.rightColor = const Color(0xFF00C853),
    this.leftColor = Colors.red,
  });

  /// Chave passada ao [Dismissible] — deve ser única por item na lista.
  final Key cardKey;

  /// Conteúdo principal do card.
  final Widget child;

  /// Callback invocado quando o utilizador faz swipe para a direita (Aprovar).
  final VoidCallback? onSwipeRight;

  /// Callback invocado quando o utilizador faz swipe para a esquerda (Rejeitar).
  final VoidCallback? onSwipeLeft;

  /// Cor de fundo da acção de swipe direita. Por omissão `#00C853` (verde).
  final Color rightColor;

  /// Cor de fundo da acção de swipe esquerda. Por omissão vermelho.
  final Color leftColor;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: cardKey,
      // Fundo visível ao fazer swipe para a direita (Aprovar)
      background: _SwipeBackground(
        color: rightColor,
        icon: Icons.check,
        label: 'Aprovar',
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
      ),
      // Fundo visível ao fazer swipe para a esquerda (Rejeitar)
      secondaryBackground: _SwipeBackground(
        color: leftColor,
        icon: Icons.close,
        label: 'Rejeitar',
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
      ),
      // Impede a remoção efectiva do card — apenas dispara o callback.
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onSwipeRight?.call();
        } else if (direction == DismissDirection.endToStart) {
          onSwipeLeft?.call();
        }
        // Devolver false mantém o card na lista.
        return false;
      },
      child: child,
    );
  }
}

/// Widget interno que renderiza o fundo colorido com ícone e label.
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
    required this.padding,
  });

  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
