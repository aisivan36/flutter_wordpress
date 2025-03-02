import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/Article.dart';
import 'package:flutter_wordpress_app/pages/comments.dart';
import 'package:flutter_wordpress_app/widgets/article_box.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

class SingleArticle extends StatefulWidget {
  final Article article;
  final String heroId;

  const SingleArticle(this.article, this.heroId, {Key? key}) : super(key: key);

  @override
  _SingleArticleState createState() => _SingleArticleState();
}

class _SingleArticleState extends State<SingleArticle> {
  List<dynamic> relatedArticles = [];
  Future<List<dynamic>>? _futureRelatedArticles;

  @override
  void initState() {
    super.initState();

    _futureRelatedArticles = fetchRelatedArticles();
  }

  Future<List<dynamic>> fetchRelatedArticles() async {
    try {
      int? postId = widget.article.id;
      int? catId = widget.article.catId;
      var response = await http.get(Uri.parse(
          "$wordpressUrl/wp-json/wp/v2/posts?exclude=$postId&categories[]=$catId&per_page=3"));

      if (mounted) {
        if (response.statusCode == 200) {
          setState(() {
            relatedArticles = json
                .decode(response.body)
                .map((m) => Article.fromJson(m))
                .toList();
          });

          return relatedArticles;
        }
      }
    } on SocketException {
      throw 'No Internet connection';
    }
    return relatedArticles;
  }

  @override
  void dispose() {
    super.dispose();
    relatedArticles = [];
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final heroId = widget.heroId;
    final articleVideo = widget.article.video;
    String youtubeUrl = "";
    String dailymotionUrl = "";
    if (articleVideo!.contains("youtube")) {
      youtubeUrl = articleVideo.split('?v=')[1];
    }
    if (articleVideo.contains("dailymotion")) {
      dailymotionUrl = articleVideo.split("/video/")[1];
    }

    print(article.avatar);

    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(color: Colors.white70),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    SizedBox(
                      child: Hero(
                        tag: heroId,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(60.0)),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.overlay),
                            child: articleVideo != ""
                                ? articleVideo.contains("youtube")
                                    ? Container(
                                        padding: EdgeInsets.fromLTRB(
                                            0,
                                            MediaQuery.of(context).padding.top,
                                            0,
                                            0),
                                        decoration: const BoxDecoration(
                                            color: Colors.black),
                                        child: HtmlWidget(
                                          """
                                      <iframe src="https://www.youtube.com/embed/$youtubeUrl" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                                      """,
                                          webView: true,
                                        ),
                                      )
                                    : articleVideo.contains("dailymotion")
                                        ? Container(
                                            padding: EdgeInsets.fromLTRB(
                                                0,
                                                MediaQuery.of(context)
                                                    .padding
                                                    .top,
                                                0,
                                                0),
                                            decoration: const BoxDecoration(
                                                color: Colors.black),
                                            child: HtmlWidget(
                                              """
                                      <iframe frameborder="0"
                                      src="https://www.dailymotion.com/embed/video/$dailymotionUrl?autoplay=1&mute=1"
                                      allowfullscreen allow="autoplay">
                                      </iframe>
                                      """,
                                              webView: true,
                                            ),
                                          )
                                        : Container(
                                            padding: EdgeInsets.fromLTRB(
                                                0,
                                                MediaQuery.of(context)
                                                    .padding
                                                    .top,
                                                0,
                                                0),
                                            decoration: const BoxDecoration(
                                                color: Colors.black),
                                            child: HtmlWidget(
                                              """
                                      <video autoplay="" playsinline="" controls>
                                      <source type="video/mp4" src="$articleVideo">
                                      </video>
                                      """,
                                              webView: true,
                                            ),
                                          )
                                : Image.network(
                                    article.image ??
                                        'https://toppng.com/uploads/preview/fancy-line-png-11552252746xsn7aqxrgj.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Html(data: "<h2>" + article.title! + "</h2>", style: {
                        "h2": Style(
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.w500,
                            fontSize: FontSize.em(1.6),
                            padding: const EdgeInsets.all(4)),
                      }),
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFFE3E3E3),
                            borderRadius: BorderRadius.circular(3)),
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        margin: const EdgeInsets.all(16),
                        child: Text(
                          article.category ?? 'empty',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 11),
                        ),
                      ),
                      SizedBox(
                        height: 45,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(article.avatar ??
                                'https://toppng.com/uploads/preview/fancy-line-png-11552252746xsn7aqxrgj.png'),
                          ),
                          title: Text(
                            "By " + article.author!,
                            style: const TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            article.date!,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 36, 16, 50),
                        child: HtmlWidget(
                          article.content!,
                          webView: true,
                          textStyle: Theme.of(context).textTheme.bodyText1 ??
                              const TextStyle(),
                        ),
                      ),
                    ],
                  ),
                ),
                relatedPosts(_futureRelatedArticles as Future<List<dynamic>>)
              ],
            ),
          )),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white10),
          height: 50,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(
                    Icons.comment,
                    color: Colors.blue,
                    size: 24.0,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Comments(article.id!),
                          fullscreenDialog: true,
                        ));
                  },
                ),
              ),
              SizedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(
                    Icons.share,
                    color: Colors.green,
                    size: 24.0,
                  ),
                  onPressed: () {
                    Share.share('Share the news: ' + article.link!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget relatedPosts(Future<List<dynamic>> latestArticles) {
    return FutureBuilder<List<dynamic>>(
      future: latestArticles,
      builder: (context, articleSnapshot) {
        if (articleSnapshot.hasData) {
          if (articleSnapshot.data!.isEmpty) return Container();
          return Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  "Related Posts",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins"),
                ),
              ),
              Column(
                children: articleSnapshot.data!.map((item) {
                  final heroId = item.id.toString() + "-related";
                  return InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SingleArticle(item, heroId),
                        ),
                      );
                    },
                    child: articleBox(context, item, heroId),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 24,
              )
            ],
          );
        } else if (articleSnapshot.hasError) {
          return Container(
              height: 500,
              alignment: Alignment.center,
              child: Text("${articleSnapshot.error}"));
        }
        return Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: 150);
      },
    );
  }
}
