#include <Arduino.h>
#include <WiFi.h>
#include <Wire.h>
#include <BME280I2C.h>
#include <Ticker.h>
#include <Firebase.h>
#include <ArduinoJson.h>

#include "credenciais.h"

//MQ1135
#define MQ135_DEFAULTPPM 392 //PPM padronizado de CO2 para a calibração do sensor
#define fatorDeEscalaCO2 116.6020682 //Fator de escaldo de CO2
#define exponencialCO2 -2.769034857 //CO2 gas value 


#define PI 3.14159265359
#define InfraVermelho 4

// Firebase
Firebase fb(url);
JsonDocument saidaDocumento;
String saida;

// BME280
bool status; // Status sensor BME280
BME280I2C bme;

/*  
  Rl -> Resistência no MQ135 (1KOhm = 1000 Ohm)
  R0 -> Valor determindado após 24h de estabilização R0 (R0 = 1.5 KOhm = 1500 Ohm)
*/

float temperatura, umidade, pressao, Vout, Vin = 5, Rl = 1000, preciptacao = 0, velocidadeVento = 0;
int pinoMQ135 = 34, contadorRs = 0, contadorAnemometro = 0, estadoAnteriorAnemometro = LOW, estadoAnteriorPluviometro = LOW, tempoTimer1 = 60, tempoTimer2 = 86400, pinoSensorAnemometro = 14, pinoSensorPluviometro = 18;
double ppmCO2 = 0, ppmCO = 0;
long R0 = 1500, Rs;

// Imã anemômetro
float distIma = 0.000017, umMinEmHora = 0.01666666666666666666666666666667;

// Imã pluviômetro
 


Ticker timer1, timer2;

bool realizarLeitura = false; // Flag para sinalizar a leitura

//Declaração função de enviar dados para o Realtime Database do Firebase
void enviaFirebase();

double getPpmCo2(long valorResistencia, long ro);

void setup() {
    pinMode(pinoMQ135, INPUT);
    pinMode(pinoSensorAnemometro, INPUT);
    pinMode(pinoSensorPluviometro, INPUT);
    pinMode(InfraVermelho, INPUT);

    Serial.begin(115200);
    WiFi.setHostname("Estacao_Meteorologica");
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
      Serial.println("Tentando conectar ao Wi-Fi...");
      delay(3000);
    }

    Serial.println("Wi-Fi conectado com sucesso!\n");

    Wire.begin();
    status = bme.begin();

    if (!status) {
        Serial.println("Sensor BME280 não conectado!\n");
    } else {
        Serial.println("Sensor BME280 conectado!\n");
    }

    estadoAnteriorPluviometro = digitalRead(pinoSensorPluviometro);

    timer1.attach(tempoTimer1, []() { realizarLeitura = true; });
    timer2.attach(tempoTimer2, []() {preciptacao = 0; });
}

void loop() {
    int estadoAtualAnemometro = digitalRead(pinoSensorAnemometro), estadoAtualPluviometro = digitalRead(pinoSensorPluviometro);
    if (estadoAtualAnemometro == LOW  && estadoAnteriorAnemometro == HIGH) {
        contadorAnemometro++;
        Serial.printf("Quantidade de passadas no sensor: %i\n\n", contadorAnemometro);
    }
    estadoAnteriorAnemometro = estadoAtualAnemometro;

    if(estadoAtualPluviometro == HIGH && estadoAnteriorPluviometro == LOW || estadoAtualPluviometro == HIGH && estadoAnteriorPluviometro == LOW) {
      preciptacao += 0.173;
    }
    estadoAnteriorPluviometro = estadoAtualPluviometro;

    if (realizarLeitura) {
        realizarLeitura = false; // Reseta a flag

        // Realiza as leituras dos sensores
        temperatura = bme.temp();
        pressao = bme.pres();
        umidade = bme.hum();

        Vout = (Vin/ 4095.0) * analogRead(pinoMQ135);
        Rs = (long)(Rl * ((Vin - Vout)/Vout));
        Serial.printf("Vout = %f\n", Vout);
        Serial.printf("Rs = %ld\n", Rs);

        ppmCO2 = getPpmCo2(Rs, R0);

        if(ppmCO2 > 10000) {
          ESP.restart();
        }


        // Exibe as leituras no Serial Monitor
        Serial.printf("Temperatura: %iºC\n", (int) round(temperatura));
        Serial.printf("Pressão: %f mbar\n", pressao);
        Serial.printf("Umidade: %.2f%%\n", umidade);
        Serial.printf("Valor de CO2 em PPM: %d\n", (int) (ppmCO2));
        Serial.printf("Contador anemômetro: %i\n", contadorAnemometro);
        Serial.printf("Preciptação: %f mm\n\n", preciptacao);

        enviaFirebase();

        contadorAnemometro = 0;
        yield(); // Cede controle para o watchdog 
    }
}

void enviaFirebase() {
  velocidadeVento = 2 * PI * distIma * (contadorAnemometro/umMinEmHora);
  Serial.printf("Velocidade do vento: %f Km/h\n", velocidadeVento);

  //Prepara o objeto JSON
    saidaDocumento["temperatura"] = (int) round(temperatura);
    saidaDocumento["pressao"] = pressao;
    saidaDocumento["umidade"] = umidade;
    saidaDocumento["ppmCO2"] = (int) round(ppmCO2);

    saidaDocumento["preciptacao"] = round(preciptacao * 100) / 100;
    saidaDocumento["velocidadeVento"] = velocidadeVento;

    serializeJson(saidaDocumento, saida);
    fb.pushJson("Estacao", saida);
}


//MQ135
//PPM CO2
double getPpmCo2(long valorResistencia, long ro) {
	return (double)fatorDeEscalaCO2 * pow((valorResistencia/ro), exponencialCO2);
}





