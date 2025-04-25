import 'package:flutter/material.dart';
import '../../colors.dart';
import '../text/primary_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final List<String> fieldNames;
  final Map<String, Map<String, WidgetBuilder>> navigationMap;
  final String? selectedField;
  final Map<String, String> selectedOptionsMap;
  final ValueChanged<String> onFieldSelected;
  final void Function(String field, String option) onOptionSelected;

  const CustomAppBar({
    Key? key,
    required this.backgroundColor,
    required this.fieldNames,
    required this.navigationMap,
    required this.selectedField,
    required this.selectedOptionsMap,
    required this.onFieldSelected,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: 60.0,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: fieldNames.map((fieldName) {
            final options = navigationMap[fieldName]?.keys.toList() ?? [];
            final selectedOption = selectedOptionsMap[fieldName];
            return Expanded(
              child: _OptionField(
                fieldName: fieldName,
                options: options,
                navigationMap: navigationMap[fieldName] ?? {},
                selectedField: selectedField,
                selectedOption: selectedOption,
                onFieldSelected: onFieldSelected,
                onOptionSelected: (option) =>
                    onOptionSelected(fieldName, option),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _OptionField extends StatefulWidget {
  final String fieldName;
  final List<String> options;
  final Map<String, WidgetBuilder> navigationMap;
  final String? selectedField;
  final String? selectedOption;
  final ValueChanged<String> onFieldSelected;
  final ValueChanged<String> onOptionSelected;

  const _OptionField({
    Key? key,
    required this.fieldName,
    required this.options,
    required this.navigationMap,
    required this.selectedField,
    required this.selectedOption,
    required this.onFieldSelected,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  State<_OptionField> createState() => _OptionFieldState();
}

class _OptionFieldState extends State<_OptionField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: Material(
            color: AppColors.appBar,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 300,
                minWidth: size.width,
                maxWidth: size.width,
              ),
              child: MouseRegion(
                onEnter: (_) => _setOverlayVisibility(true),
                onExit: (_) => _setOverlayVisibility(false),
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.options.map((option) {
                      return InkWell(
                        onTap: () {
                          widget.onOptionSelected(option);
                          final builder = widget.navigationMap[option];
                          if (builder != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: builder),
                            );
                          }
                          _removeOverlay();
                        },
                        child: _HoverableMenuItem(
                          label: option,
                          isSelected: option == widget.selectedOption,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOverlayVisible = false;
    });
  }

  void _setOverlayVisibility(bool isVisible) {
    setState(() {
      _isOverlayVisible = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSelectedField = widget.fieldName == widget.selectedField;

    return MouseRegion(
      onEnter: (_) {
        widget.onFieldSelected(widget.fieldName);
        _showOverlay(context);
      },
      onExit: (_) => Future.delayed(const Duration(milliseconds: 300), () {
        if (!_isOverlayVisible) {
          _removeOverlay();
        }
      }),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          decoration: BoxDecoration(
            color: isSelectedField ? AppColors.lightBlue : AppColors.appBar,
          ),
          child: Center(
            child: CustomText(
              text: widget.selectedOption ?? widget.fieldName,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverableMenuItem extends StatefulWidget {
  final String label;
  final bool isSelected;

  const _HoverableMenuItem({
    required this.label,
    required this.isSelected,
  });

  @override
  _HoverableMenuItemState createState() => _HoverableMenuItemState();
}

class _HoverableMenuItemState extends State<_HoverableMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: widget.isSelected
            ? AppColors.lightBlue
            : (isHovered ? AppColors.lightBlue : AppColors.appBar),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Center(
            child: CustomText(
              text: widget.label,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
