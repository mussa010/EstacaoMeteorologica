import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'LineChartWidget.dart';

class MenuDisplayWeb extends StatefulWidget {
  const MenuDisplayWeb({super.key});

  @override
  State<MenuDisplayWeb> createState() => _MenuDisplayWeb();
}

class _MenuDisplayWeb extends State<MenuDisplayWeb> {
  double temperatura = 0,
      pressao = 0,
      umidade = 0,
      velocidadeVento = 0,
      ppmCO2 = 0,
      preciptacao = 0;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<double> ppmCO2Data = [];
  List<double> pressaoData = [];
  List<double> temperaturaData = [];
  List<double> umidadeData = [];
  List<double> velocidadeVentoData = [];
  List<double> preciptacaoData = [];

  void _fetchData() {
    _database.child('Estacao').limitToLast(86400).onValue.listen((event) {
      final dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        final estacaoMap = Map<String, dynamic>.from(dataSnapshot.value as Map);

        temperatura = estacaoMap.values.last["temperatura"];
        pressao = estacaoMap.values.last["pressao"];
        umidade = estacaoMap.values.last["umidade"];
        ppmCO2 = estacaoMap.values.last["ppmCO2"];
        velocidadeVento = estacaoMap.values.last["velocidadeVento"];
        preciptacao = estacaoMap.values.last["preciptacao"];

        // Limpar as listas antes de adicionar novos dados
        ppmCO2Data.clear();
        pressaoData.clear();
        temperaturaData.clear();
        umidadeData.clear();
        velocidadeVentoData.clear();
        preciptacaoData.clear();

        // Listas temporárias para armazenar somas de cada hora
        double somaPPMCO2 = 0.0,
            somaPressao = 0.0,
            somaTemperatura = 0.0,
            somaUmidade = 0.0,
            somaVelocidadeVento = 0.0,
            somaPreciptacao = 0.0;
        int count = 0;

        estacaoMap.forEach((key, value) {
          final dados = Map<String, dynamic>.from(value as Map);

          somaPPMCO2 += dados['ppmCO2']?.toDouble() ?? 0.0;
          somaPressao += dados['pressao']?.toDouble() ?? 0.0;
          somaTemperatura += dados['temperatura']?.toDouble() ?? 0.0;
          somaUmidade += dados['umidade']?.toDouble() ?? 0.0;
          somaVelocidadeVento += dados['velocidadeVento']?.toDouble() ?? 0.0;
          somaPreciptacao += dados['preciptacao']?.toDouble() ?? 0.0;
          count++;

          // Calcular a média a cada 60 minutos (1 hora)
          if (count == 60) {
            ppmCO2Data.add(somaPPMCO2 / 60);
            pressaoData.add(somaPressao / 60);
            temperaturaData.add(somaTemperatura / 60);
            umidadeData.add(somaUmidade / 60);
            velocidadeVentoData.add(somaVelocidadeVento / 60);
            preciptacaoData.add(somaPreciptacao / 60);

            // Resetar as somas e o contador para a próxima hora
            somaPPMCO2 = 0.0;
            somaPressao = 0.0;
            somaTemperatura = 0.0;
            somaUmidade = 0.0;
            somaVelocidadeVento = 0.0;
            somaPreciptacao = 0.0;
            count = 0;
          }
        });

        // Garantir que a lista contenha apenas as últimas 24 horas (24 pontos)
        if (ppmCO2Data.length > 24) {
          ppmCO2Data = ppmCO2Data.sublist(ppmCO2Data.length - 24);
        }
        if (pressaoData.length > 24) {
          pressaoData = pressaoData.sublist(pressaoData.length - 24);
        }
        if (temperaturaData.length > 24) {
          temperaturaData =
              temperaturaData.sublist(temperaturaData.length - 24);
        }
        if (umidadeData.length > 24) {
          umidadeData = umidadeData.sublist(umidadeData.length - 24);
        }
        if (velocidadeVentoData.length > 24) {
          velocidadeVentoData =
              velocidadeVentoData.sublist(velocidadeVentoData.length - 24);
        }
        if (preciptacaoData.length > 24) {
          preciptacaoData =
              preciptacaoData.sublist(preciptacaoData.length - 24);
        }
      }

      // Atualizar a interface
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(234, 37, 36, 39),
        title: const Text(
          "Estação meteorológica",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: PopScope(
          canPop: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Text(
                    "Dados recentes",
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadiusDirectional.circular(10),
                              color: const Color.fromARGB(255, 43, 41, 41),
                              boxShadow: const [BoxShadow(blurRadius: 20)]),
                          width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            children: [
                              Text(
                                "$temperatura °C",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Temperatura",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 100),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadiusDirectional.circular(10),
                              color: const Color.fromARGB(255, 43, 41, 41),
                              boxShadow: const [BoxShadow(blurRadius: 20)]),
                          width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            children: [
                              Text(
                                "${pressao.toStringAsFixed(2).replaceAll(".", ",")} mbar",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Pressão",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 100),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadiusDirectional.circular(10),
                              color: const Color.fromARGB(255, 43, 41, 41),
                              boxShadow: const [BoxShadow(blurRadius: 20)]),
                          width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            children: [
                              Text(
                                "${umidade.toStringAsPrecision(2)} %",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Umidade",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadiusDirectional.circular(10),
                              color: const Color.fromARGB(255, 43, 41, 41),
                              boxShadow: const [BoxShadow(blurRadius: 20)]),
                          width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            children: [
                              Text(
                                "$ppmCO2 PPM",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Quantidade de CO2",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 100),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadiusDirectional.circular(10),
                              color: const Color.fromARGB(255, 43, 41, 41),
                              boxShadow: const [BoxShadow(blurRadius: 20)]),
                          width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            children: [
                              Text(
                                "${velocidadeVento.toStringAsFixed(2).replaceAll(".", ",")} Km/h",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Velocidade do vento",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 100),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadiusDirectional.circular(10),
                              color: const Color.fromARGB(255, 43, 41, 41),
                              boxShadow: const [BoxShadow(blurRadius: 20)]),
                          width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            children: [
                              Text(
                                "${preciptacao.toStringAsFixed(2).replaceAll(".", ",")} mm",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Preciptação",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 60,),
                const Text(
                    "Histórico de dados",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Column(
                    children: [
                      // Linha com gráficos de Temperatura e Pressão lado a lado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gráfico de Temperatura
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [BoxShadow(blurRadius: 10)],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Temperatura (ºC)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  LineChartWidget(data: temperaturaData),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Gráfico de Pressão
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [BoxShadow(blurRadius: 10)],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Pressão (mbar)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  LineChartWidget(data: pressaoData),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Gráfico de Umidade abaixo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gráfico de Temperatura
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [BoxShadow(blurRadius: 10)],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Umidade (%)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  LineChartWidget(data: umidadeData),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Gráfico de Pressão
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [BoxShadow(blurRadius: 10)],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Quantidade de CO2 (PPM)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  LineChartWidget(data: ppmCO2Data),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gráfico de Temperatura
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [BoxShadow(blurRadius: 10)],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Velocidade do vento (Km/h)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  LineChartWidget(data: velocidadeVentoData),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Gráfico de Pressão
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [BoxShadow(blurRadius: 10)],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Precipitação (mm)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  LineChartWidget(data: preciptacaoData),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          )),
      backgroundColor: const Color.fromARGB(255, 50, 55, 59),
    );
  }
}
