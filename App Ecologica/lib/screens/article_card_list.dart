// lib/widgets/article_card_list.dart

import 'package:flutter/material.dart';
import 'package:iguanosquad/services/articulo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../widgets/article_card.dart';
import '../screens/edit_article_screen.dart';

class ArticleCardList extends StatefulWidget {
  const ArticleCardList({Key? key}) : super(key: key);

  @override
  _ArticleCardListState createState() => _ArticleCardListState();
}

class _ArticleCardListState extends State<ArticleCardList> {
  late final ArticuloService _service;
  late Future<List<Product>> _futureProducts;
  late final String _userId;

  @override
  void initState() {
    super.initState();
    _service = ArticuloService();
    _userId = Supabase.instance.client.auth.currentUser!.id;
    _futureProducts = _service.getProductsByUser(_userId);
  }

  bool _isFirstBuild = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isFirstBuild) {
      setState(() {
        _futureProducts = _service.getProductsByUser(_userId);
      });
    }
    _isFirstBuild = false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        }
        final articles = snapshot.data!;
        if (articles.isEmpty) {
          return const Center(child: Text('No tienes artículos aún'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return ArticleCard(
              article: article,
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditArticleScreen(articulo: article),
                  ),
                ).then((_) {
                  setState(() {
                    _futureProducts = _service.getProductsByUser(_userId);
                  });
                });
              },
              onDelete: () {
                // Este callback se ejecutará justo después de borrar el artículo
                setState(() {
                  _futureProducts = _service.getProductsByUser(_userId);
                });
              },
            );
          },
        );
      },
    );
  }
}
