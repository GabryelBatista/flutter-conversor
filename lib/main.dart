import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final request = Uri.parse(
    "https://yfapi.net/v6/finance/quote?region=US&lang=en&symbols=BRL%3DX%2CEURBRL%3DX");
const key = "53h4G9xyXUrWvfgizCiw3UdIaStAyf5oD7Fuvcc0";

void main(List<String> args) async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
        hintStyle: TextStyle(color: Colors.amber),
      ),
    ),
  ));
}

Future<Map> getData() async {
  var response = await http.get(request, headers: {
    "Content-type": "application/json",
    "Accept": "application/json",
    "x-api-key": key
  });

  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
      double euro = double.parse(text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                    child: Text(
                  "Carregando Dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                    "Erro ao Carregar Dados :(",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  dolar = snapshot.data!["quoteResponse"]["result"][0]["bid"];
                  euro = snapshot.data!["quoteResponse"]["result"][1]["bid"];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            size: 150.0,
                            color: Colors.amber,
                          ),
                          const Divider(),
                          buildTextField("Reais", "R\$ ", realController,
                              _realChanged, _clearAll),
                          const Divider(),
                          buildTextField("Dolares", "U\$ ", dolarController,
                              _dolarChanged, _clearAll),
                          const Divider(),
                          buildTextField("Euros", "€ ", euroController,
                              _euroChanged, _clearAll),
                        ],
                      ),
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c,
    Function f, Function clear) {
  return TextField(
    controller: c,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.amber,
      ),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    onChanged: (t) => (t.isNotEmpty || t == "0") ? f(t) : clear(),
  );
}
