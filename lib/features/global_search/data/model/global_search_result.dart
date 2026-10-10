enum GlobalSearchResultType { client, product,  }

class GlobalSearchResult {
  final GlobalSearchResultType type;
  final String id;
  final String title;
  final String? subtitle;

 

  const GlobalSearchResult({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
   
  });
}
