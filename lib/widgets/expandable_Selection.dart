import 'package:flutter/material.dart';

class ExpandableSelection<T> extends StatefulWidget {
  final List<T> items;
  final List<T>? selectedItems; // For multiple selection
  final T? selectedItem; // For single selection
  final bool isMultiple;
  final String Function(T) displayString;
  final Function(List<T>)? onSelectedMultiple;
  final Function(T)? onSelectedSingle;
  final String hintText;
  final String labelText;

  const ExpandableSelection({
    super.key,
    required this.items,
    this.selectedItems,
    this.selectedItem,
    this.isMultiple = false,
    required this.displayString,
    this.onSelectedMultiple,
    this.onSelectedSingle,
    this.hintText = '',
    this.labelText = '',
  });

  @override
  State<ExpandableSelection<T>> createState() => _ExpandableSelectionState<T>();
}

class _ExpandableSelectionState<T> extends State<ExpandableSelection<T>> {
  bool isExpanded = false;
  late List<T> filteredItems;
  late List<T> selectedItems;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(widget.items);
    selectedItems = widget.selectedItems ?? [];
    searchController = TextEditingController();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(widget.items);
      } else {
        filteredItems = widget.items
            .where((item) =>
            widget.displayString(item).toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
      if (!isExpanded) searchController.clear();
    });
  }

  void toggleSelection(T item) {
    if (widget.isMultiple) {
      setState(() {
        if (selectedItems.contains(item)) {
          selectedItems.remove(item);
        } else {
          selectedItems.add(item);
        }
      });
      widget.onSelectedMultiple?.call(selectedItems);
    } else {
      setState(() {
        selectedItems = [item];
      });
      widget.onSelectedSingle?.call(item);
      toggleExpansion();
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayText;
    if (widget.isMultiple) {
      displayText =
      selectedItems.isEmpty ? '' : '${selectedItems.length} selected';
    } else {
      displayText =
      selectedItems.isEmpty ? '' : widget.displayString(selectedItems.first);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          readOnly: true,
          onTap: toggleExpansion,
          controller: TextEditingController(text: displayText),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            suffixIcon: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.arrow_drop_down),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isExpanded ? null : 0,
          child: isExpanded
              ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterItems,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isSelected = selectedItems.contains(item);

                  return ListTile(
                    title: Text(widget.displayString(item)),
                    trailing: widget.isMultiple
                        ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => toggleSelection(item),
                    )
                        : null,
                    onTap: () => toggleSelection(item),
                  );
                },
              ),
            ],
          )
              : const SizedBox(),
        ),
      ],
    );
  }
}
