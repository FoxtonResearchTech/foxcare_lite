import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../colors.dart';
import '../text/primary_text.dart';

class LazyDataTable extends StatefulWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> tableData;
  final Map<int, TableColumnWidth> columnWidths;
  final Color headerBackgroundColor;
  final Color headerColor;
  final Color borderColor;
  final Color Function(Map<String, dynamic>)? rowColorResolver;
  final void Function(double scrollOffset)? onScroll;

  LazyDataTable({
    super.key,
    required this.headers,
    required this.tableData,
    this.columnWidths = const {},
    Color? headerBackgroundColor,
    this.borderColor = Colors.black,
    this.rowColorResolver,
    this.headerColor = Colors.white,
    this.onScroll,
  }) : headerBackgroundColor = headerBackgroundColor ?? AppColors.blue;

  @override
  State<LazyDataTable> createState() => _LazyDataTable();
}

class _LazyDataTable extends State<LazyDataTable>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;
  int itemsToShow = 25;
  bool isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final offset = _scrollController.position.pixels;

    // Call the scroll function
    if (widget.onScroll != null) {
      widget.onScroll!(offset);
    }

    // Lazy loading trigger
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoadingMore &&
        itemsToShow < widget.tableData.length) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    setState(() {
      isLoadingMore = true;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      itemsToShow = (itemsToShow + 25).clamp(0, widget.tableData.length);
      isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (widget.tableData.length <= 25) {
      // If data length <= 25, show full table without scrolling or lazy loading
      return Column(
        children: [
          Table(
            border: TableBorder.all(color: widget.borderColor),
            columnWidths: widget.columnWidths.isNotEmpty
                ? widget.columnWidths
                : {
                    for (int i = 0; i < widget.headers.length; i++)
                      i: const FlexColumnWidth()
                  },
            children: [
              TableRow(
                decoration: BoxDecoration(color: widget.headerBackgroundColor),
                children: widget.headers
                    .map((header) => Center(
                          child: CustomText(
                            maxLines: 5,
                            text: header,
                            color: widget.headerColor,
                          ),
                        ))
                    .toList(),
              ),
              // All rows rendered directly here
              ...widget.tableData.map((row) => TableRow(
                    decoration: BoxDecoration(
                        color: widget.rowColorResolver?.call(row) ??
                            Colors.transparent),
                    children: widget.headers.map((header) {
                      final cellData = row[header];
                      if (cellData is Widget) {
                        return Center(child: cellData);
                      } else {
                        return Center(
                          child: CustomText(
                            maxLines: 25,
                            text: cellData?.toString() ?? '',
                          ),
                        );
                      }
                    }).toList(),
                  )),
            ],
          ),
        ],
      );
    }

    // Else, use lazy loading with scrolling (existing logic)
    final dataToShow = widget.tableData.take(itemsToShow).toList();

    return Column(
      children: [
        Table(
          border: TableBorder.all(color: widget.borderColor),
          columnWidths: widget.columnWidths.isNotEmpty
              ? widget.columnWidths
              : {
                  for (int i = 0; i < widget.headers.length; i++)
                    i: const FlexColumnWidth()
                },
          children: [
            TableRow(
              decoration: BoxDecoration(color: widget.headerBackgroundColor),
              children: widget.headers
                  .map((header) => Center(
                        child: CustomText(
                          maxLines: 5,
                          text: header,
                          color: widget.headerColor,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        SizedBox(
          height: screenHeight * 0.594,
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.builder(
              key: PageStorageKey('lazyDataTableList'),
              controller: _scrollController,
              itemCount: dataToShow.length + (isLoadingMore ? 1 : 0),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              itemBuilder: (context, index) {
                if (index == dataToShow.length) {
                  // Show a single loading indicator at bottom
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.blue),
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: CustomText(
                            key: ValueKey(DateTime.now().second % 3),
                            text:
                                'Loading${'.' * ((DateTime.now().second % 3) + 1)}',
                            color: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final row = dataToShow[index];
                return LazyDataRow(
                  index: index,
                  row: row,
                  headers: widget.headers,
                  columnWidths: widget.columnWidths,
                  borderColor: widget.borderColor,
                  rowColor:
                      widget.rowColorResolver?.call(row) ?? Colors.transparent,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class LazyDataRow extends StatelessWidget {
  final int index;
  final Map<String, dynamic> row;
  final List<String> headers;
  final Map<int, TableColumnWidth> columnWidths;
  final Color borderColor;
  final Color rowColor;
  final double screenWidth;
  final double screenHeight;

  const LazyDataRow({
    Key? key,
    required this.index,
    required this.row,
    required this.headers,
    required this.columnWidths,
    required this.borderColor,
    required this.rowColor,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Table(
        border: TableBorder.all(color: borderColor),
        columnWidths: columnWidths.isNotEmpty
            ? columnWidths
            : {
                for (int i = 0; i < headers.length; i++)
                  i: const FlexColumnWidth()
              },
        children: [
          TableRow(
            decoration: BoxDecoration(color: rowColor),
            children: headers.map((header) {
              final cellData = row[header];

              if (cellData is Widget) {
                return Center(child: cellData);
              } else {
                return Center(
                  child: CustomText(
                    maxLines: 25,
                    text: cellData?.toString() ?? '',
                  ),
                );
              }
            }).toList(),
          ),
        ],
      ),
    );
  }
}
