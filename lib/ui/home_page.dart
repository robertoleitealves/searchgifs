import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:searchgifs/ui/gif_page.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  int _offSet = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null) {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=FhbLRy1ICkfzeYvzTi1xA5tEUvoa1Slb&limit=20&rating=g'));
      return json.decode(response.body);
    } else {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=FhbLRy1ICkfzeYvzTi1xA5tEUvoa1Slb&q=$_search&limit=19&offset=$_offSet&rating=g&lang=en'));
      return json.decode(response.body);
    }
  }

  @override
  void initState() {
    super.initState();

    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Pesquisar',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                //Parâmetros para quando o Input está em FOCO
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                //Parâmetros para quando o Input está "fora" de FOCO
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                )),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
            //Fará a pesquisa após clicar enter no teclado
            onSubmitted: (text) {
              setState(() {
                _search = text;
                _offSet = 0;
              });
            },
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: _getGifs(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                default:
                  if (snapshot.hasError)
                    return Container();
                  else
                    return _createGifTable(context, snapshot);
              }
            },
          ),
        ),
      ]),
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data['data'].length) {
            return GestureDetector(
              //Acessando a imagem da internet através do Mapa do Json
              child: FadeInImage.memoryNetwork(
                image: snapshot.data['data'][index]['images']['fixed_height']
                    ['url'],
                placeholder: kTransparentImage,
                height: 300,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GifPage(
                      snapshot.data['data'][index],
                    ),
                  ),
                );
              },
              onLongPress: (() {
                Share.share(snapshot.data['data'][index]['images']
                    ['fixed_height']['url']);
              }),
            );
          } else {
            return Container(
                child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    'Carregar mais...',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offSet += 19;
                });
              },
            ));
          }
        });
  }
}
