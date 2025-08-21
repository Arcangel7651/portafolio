import 'package:flutter/material.dart';
import 'package:iguanosquad/screens/article_card_list.dart';
import 'package:iguanosquad/screens/event_card_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_event_screen.dart';
import 'edit_article_screen.dart';

class MyPublicationsScreen extends StatefulWidget {
  const MyPublicationsScreen({Key? key}) : super(key: key);

  @override
  State<MyPublicationsScreen> createState() => _MyPublicationsScreenState();
}

class _MyPublicationsScreenState extends State<MyPublicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return const Center(child: Text('No se ha iniciado sesión'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mis Publicaciones'),
            Text(
              'Gestiona tus eventos y artículos',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFE0F2E9),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.black54,
              tabs: const [
                Tab(text: 'Eventos'),
                Tab(text: 'Artículos'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                EventCardList(userId: userId),
                const ArticleCardList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
