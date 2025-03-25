import 'package:flutter/material.dart';

// import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  // New callback to handle sort tapping
  final VoidCallback? onSortTap;
  final String? currentSort;

  const FilterBar({
    super.key,
    this.onSortTap,
    this.currentSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Pass the onSortTap and current sort text down
            FilterDropdown(
              filterText: currentSort ?? 'Sort by',
              onTap: onSortTap,
            ),
          ],
        ),
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String filterText;
  final VoidCallback? onTap;

  const FilterDropdown({
    super.key,
    required this.filterText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // This triggers the bottom sheet
      child: Container(
        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Text(
              filterText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
