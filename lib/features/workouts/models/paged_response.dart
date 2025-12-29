class PagedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int? lastPage;
  final int? total;

  const PagedResponse({
    required this.data,
    required this.currentPage,
    this.lastPage,
    this.total,
  });

  bool get hasMore {
    if (lastPage == null) return false;
    return currentPage < lastPage!;
  }
}
