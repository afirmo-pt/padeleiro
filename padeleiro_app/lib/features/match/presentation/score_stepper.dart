import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/match.dart';

/// Widget para introdução de sets de uma partida.
///
/// Apresenta uma linha de entrada por set, com campos de pontuação para
/// Team A e Team B. Suporta entre [minSets] e [maxSets] sets. Valida
/// valores inteiros não negativos inline e notifica o pai via [onChanged]
/// sempre que qualquer pontuação é alterada.
///
/// É um [StatefulWidget] puro — não depende de Riverpod.
class ScoreStepper extends StatefulWidget {
  const ScoreStepper({
    super.key,
    this.minSets = 1,
    this.maxSets = 3,
    required this.onChanged,
    this.initialScores,
  }) : assert(minSets >= 1, 'minSets must be >= 1'),
       assert(maxSets >= minSets, 'maxSets must be >= minSets');

  /// Número mínimo de sets. Por omissão: 1.
  final int minSets;

  /// Número máximo de sets. Por omissão: 3.
  final int maxSets;

  /// Callback invocado sempre que qualquer pontuação é alterada.
  /// Recebe a lista de [SetScore] com os valores actuais (apenas os sets
  /// com valores válidos são incluídos).
  final void Function(List<SetScore> scores) onChanged;

  /// Pontuações iniciais. Se `null`, começa com [minSets] sets a zero.
  final List<SetScore>? initialScores;

  @override
  State<ScoreStepper> createState() => _ScoreStepperState();
}

class _ScoreStepperState extends State<ScoreStepper> {
  /// Número de sets actualmente visíveis.
  late int _setCount;

  /// Controladores para os campos de Team A (índice = set index 0-based).
  late List<TextEditingController> _teamAControllers;

  /// Controladores para os campos de Team B (índice = set index 0-based).
  late List<TextEditingController> _teamBControllers;

  /// Chaves de formulário por linha de set.
  late List<GlobalKey<FormFieldState<String>>> _teamAKeys;
  late List<GlobalKey<FormFieldState<String>>> _teamBKeys;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialScores;
    _setCount = (initial != null && initial.isNotEmpty)
        ? initial.length.clamp(widget.minSets, widget.maxSets)
        : widget.minSets;

    _teamAControllers = List.generate(widget.maxSets, (i) {
      final score = (initial != null && i < initial.length)
          ? initial[i].teamAScore.toString()
          : '';
      return TextEditingController(text: score);
    });

    _teamBControllers = List.generate(widget.maxSets, (i) {
      final score = (initial != null && i < initial.length)
          ? initial[i].teamBScore.toString()
          : '';
      return TextEditingController(text: score);
    });

    _teamAKeys = List.generate(
      widget.maxSets,
      (_) => GlobalKey<FormFieldState<String>>(),
    );
    _teamBKeys = List.generate(
      widget.maxSets,
      (_) => GlobalKey<FormFieldState<String>>(),
    );

    // Adicionar listeners para notificar o pai em cada alteração.
    for (int i = 0; i < widget.maxSets; i++) {
      _teamAControllers[i].addListener(_notifyChanged);
      _teamBControllers[i].addListener(_notifyChanged);
    }
  }

  @override
  void dispose() {
    for (final c in _teamAControllers) {
      c.removeListener(_notifyChanged);
      c.dispose();
    }
    for (final c in _teamBControllers) {
      c.removeListener(_notifyChanged);
      c.dispose();
    }
    super.dispose();
  }

  /// Constrói a lista de [SetScore] com os valores actualmente válidos.
  /// Sets com campos vazios ou inválidos são incluídos com score 0.
  List<SetScore> _buildScores() {
    return List.generate(_setCount, (i) {
      final a = int.tryParse(_teamAControllers[i].text.trim()) ?? 0;
      final b = int.tryParse(_teamBControllers[i].text.trim()) ?? 0;
      return SetScore(
        setNumber: i + 1,
        teamAScore: a < 0 ? 0 : a,
        teamBScore: b < 0 ? 0 : b,
      );
    });
  }

  void _notifyChanged() {
    widget.onChanged(_buildScores());
  }

  void _addSet() {
    if (_setCount >= widget.maxSets) return;
    setState(() {
      _setCount++;
    });
    _notifyChanged();
  }

  void _removeSet() {
    if (_setCount <= widget.minSets) return;
    // Limpar os controladores do set removido.
    final idx = _setCount - 1;
    _teamAControllers[idx].text = '';
    _teamBControllers[idx].text = '';
    setState(() {
      _setCount--;
    });
    _notifyChanged();
  }

  /// Validador partilhado para campos de pontuação.
  String? _validateScore(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Obrigatório';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Número inteiro';
    }
    if (parsed < 0) {
      return 'Valor ≥ 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabeçalho com labels das colunas.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              // Espaço para o label "Set N"
              const SizedBox(width: 64),
              Expanded(
                child: Text(
                  'Equipa A',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'vs',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Equipa B',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Linhas de set.
        for (int i = 0; i < _setCount; i++)
          _SetRow(
            key: ValueKey('set_row_$i'),
            setNumber: i + 1,
            teamAController: _teamAControllers[i],
            teamBController: _teamBControllers[i],
            teamAFieldKey: _teamAKeys[i],
            teamBFieldKey: _teamBKeys[i],
            validator: _validateScore,
          ),

        const SizedBox(height: 12),

        // Botões "Adicionar Set" / "Remover Set".
        Row(
          children: [
            if (_setCount > widget.minSets)
              Expanded(
                child: _ActionButton(
                  label: 'Remover Set',
                  icon: Icons.remove_circle_outline,
                  onPressed: _removeSet,
                  color: colorScheme.error,
                ),
              ),
            if (_setCount > widget.minSets && _setCount < widget.maxSets)
              const SizedBox(width: 8),
            if (_setCount < widget.maxSets)
              Expanded(
                child: _ActionButton(
                  label: 'Adicionar Set',
                  icon: Icons.add_circle_outline,
                  onPressed: _addSet,
                  color: colorScheme.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Linha de set individual
// ---------------------------------------------------------------------------

class _SetRow extends StatelessWidget {
  const _SetRow({
    super.key,
    required this.setNumber,
    required this.teamAController,
    required this.teamBController,
    required this.teamAFieldKey,
    required this.teamBFieldKey,
    required this.validator,
  });

  final int setNumber;
  final TextEditingController teamAController;
  final TextEditingController teamBController;
  final GlobalKey<FormFieldState<String>> teamAFieldKey;
  final GlobalKey<FormFieldState<String>> teamBFieldKey;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label "Set N"
          SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Set $setNumber',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Campo Team A
          Expanded(
            child: _ScoreField(
              controller: teamAController,
              fieldKey: teamAFieldKey,
              label: 'Pontos A',
              validator: validator,
            ),
          ),

          // Separador "vs"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'vs',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // Campo Team B
          Expanded(
            child: _ScoreField(
              controller: teamBController,
              fieldKey: teamBFieldKey,
              label: 'Pontos B',
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Campo de pontuação individual
// ---------------------------------------------------------------------------

class _ScoreField extends StatelessWidget {
  const _ScoreField({
    required this.controller,
    required this.fieldKey,
    required this.label,
    required this.validator,
  });

  final TextEditingController controller;
  final GlobalKey<FormFieldState<String>> fieldKey;
  final String label;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        // Permite apenas dígitos (sem sinal negativo na entrada).
        FilteringTextInputFormatter.digitsOnly,
      ],
      textAlign: TextAlign.center,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      // Touch target mínimo de 48dp garantido pelo tema (MaterialTapTargetSize.padded)
      // e pela altura mínima do campo.
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        isDense: false,
        constraints: const BoxConstraints(minHeight: 48),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Botão de acção (Adicionar / Remover Set)
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
        ),
      ),
    );
  }
}
