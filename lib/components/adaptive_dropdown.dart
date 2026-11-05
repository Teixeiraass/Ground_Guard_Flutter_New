import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveDropdownItem {
  final String value;
  final String label;

  const AdaptiveDropdownItem({required this.value, required this.label});
}

/// Seletor de valor único que usa o [DropdownButton] nativo do Material no
/// Android e um [CupertinoActionSheet] no iOS, em vez do menu estilo Android
/// que o DropdownButton sempre abre, independente de plataforma.
class AdaptiveDropdown extends StatelessWidget {
  final String? value;
  final List<AdaptiveDropdownItem> items;
  final ValueChanged<String?> onChanged;
  final String title;
  final Widget? hint;
  final bool isExpanded;
  final double? itemMaxWidth;
  final Icon? icon;
  final TextStyle? itemTextStyle;
  final EdgeInsetsGeometry padding;

  static const _defaultTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  const AdaptiveDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.title,
    this.hint,
    this.isExpanded = false,
    this.itemMaxWidth,
    this.icon,
    this.itemTextStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  AdaptiveDropdownItem? get _selected =>
      items.where((i) => i.value == value).firstOrNull;

  @override
  Widget build(BuildContext context) {
    // Estilo e padding explícitos e IDÊNTICOS nas duas plataformas: o
    // DropdownButton do Material e o Text puro do iOS têm, cada um, seu
    // próprio padding/estilo padrão (diferentes entre si), então não dá pra
    // confiar no default nativo de nenhum dos dois sem o select ficar
    // desalinhado com o resto da tela.
    final resolvedStyle = itemTextStyle ?? _defaultTextStyle;

    if (Platform.isIOS) {
      final label = _selected != null
          ? Text(
              _selected!.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: resolvedStyle,
            )
          : (hint ?? const SizedBox.shrink());

      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: items.isEmpty ? null : () => _showActionSheet(context),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              isExpanded
                  ? Expanded(child: label)
                  : ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: itemMaxWidth ?? 120,
                      ),
                      child: label,
                    ),
              const SizedBox(width: 4),
              icon ?? const Icon(CupertinoIcons.chevron_down, size: 18),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: isExpanded,
          hint: hint,
          icon: icon ?? const Icon(Icons.arrow_drop_down),
          style: resolvedStyle,
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i.value,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: itemMaxWidth ?? double.infinity,
                    ),
                    child: Text(
                      i.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: resolvedStyle,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(title),
        actions: items
            .map(
              (i) => CupertinoActionSheetAction(
                isDefaultAction: i.value == value,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  onChanged(i.value);
                },
                child: Text(i.label),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancelar'),
        ),
      ),
    );
  }
}
