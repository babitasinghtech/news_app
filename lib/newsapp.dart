import 'dart:convert';

import 'package:flutter/material.dart';
import 'news_model.dart';
import 'package:http/http.dart' as http;

class NewsApp extends StatefulWidget {
  const NewsApp({super.key});

  @override
  State<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  Future<newsModel> fetchNews() async {
    const url =
        "https://newsapi.org/v2/everything?q=tesla&from=2024-10-27&sortBy=publishedAt&apiKey=cd55a24efbde4cb0a6f1d8ed808dc5fb";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return newsModel.fromJson(result);
      } else {
        throw Exception("Failed to load news. Status code: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Failed to load news. Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News App"),
        centerTitle: true,
      ),
      body: FutureBuilder<newsModel>(
        future: fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "An error occurred: ${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.articles != null) {
            return ListView.builder(
              itemCount: snapshot.data!.articles!.length,
              itemBuilder: (context, index) {
                final article = snapshot.data!.articles![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(article.urlToImage ?? ""),
                    onBackgroundImageError: (_, __) => const Icon(Icons.error),
                  ),
                  title: Text(article.title ?? "No Title"),
                  subtitle: Text(article.description ?? "No Description"),
                );
              },
            );
          } else {
            return const Center(
              child: Text("No articles available."),
            );
          }
        },
      ),
    );
  }
}
