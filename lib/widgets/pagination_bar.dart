import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    if (provider.totalCount == 0 && !provider.isLoading) {
      return const SizedBox.shrink();
    }

    final currentPage = provider.currentPage;
    final totalPages = provider.totalPages;
    final pageSize = provider.pageSize;
    final totalCount = provider.totalCount;

    final fromItem = totalCount == 0 ? 0 : (currentPage - 1) * pageSize + 1;
    final toItem = (currentPage * pageSize).clamp(0, totalCount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant
                .withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing $fromItem-$toItem of $totalCount items',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Per page: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(
                          value: 6,
                          label: Text('6', style: TextStyle(fontSize: 11)),
                        ),
                        ButtonSegment<int>(
                          value: 7,
                          label: Text('7', style: TextStyle(fontSize: 11)),
                        ),
                        ButtonSegment<int>(
                          value: 8,
                          label: Text('8', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                      selected: {pageSize},
                      showSelectedIcon: false,
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onSelectionChanged: (Set<int> newSelection) {
                        provider.setPageSize(newSelection.first);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                IconButton.outlined(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  tooltip: 'Previous Page',
                  onPressed: provider.hasPreviousPage && !provider.isLoading
                      ? () => provider.previousPage()
                      : null,
                ),
                const SizedBox(width: 8),

                ...List.generate(totalPages, (index) {
                  final pageNumber = index + 1;
                  final isCurrent = pageNumber == currentPage;

                  if (totalPages > 6) {
                    if (pageNumber != 1 &&
                        pageNumber != totalPages &&
                        (pageNumber < currentPage - 1 ||
                            pageNumber > currentPage + 1)) {
                      if (pageNumber == currentPage - 2 ||
                          pageNumber == currentPage + 2) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text('..', style: TextStyle(fontSize: 12)),
                        );
                      }
                      return const SizedBox.shrink();
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: isCurrent || provider.isLoading
                          ? null
                          : () => provider.goToPage(pageNumber),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$pageNumber',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isCurrent
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(width: 8),

                IconButton.outlined(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  tooltip: 'Next Page',
                  onPressed: provider.hasNextPage && !provider.isLoading
                      ? () => provider.nextPage()
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
