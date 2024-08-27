#include <Arduino.h>
#include <WiFi.h>
#include<SPI.h>
#include<BluetoothSerial.h>


void printEncryption(int type);

void setup() {
  Serial.begin(115200);
  WiFi.setHostname("Estacao_Meteorologica");
  // WiFi.begin("Mussa cel", "1234567890");
  // while(WiFi.status() != WL_CONNECTED) {
  //   Serial.println("Não conectado ainda");
  //   delay(3000);
  // }

  // Serial.println("Conectado!");

}

void loop() {
  char nomes[100][100];

  int numSSID = -1;
  numSSID = WiFi.scanNetworks();

  if(numSSID == -1) {
    Serial.println("Não há redes");
  } else {
    Serial.print("Numero de redes: ");
    Serial.println(numSSID);
    for(int i = 0; i < numSSID; i++) {
      Serial.print(i);
      Serial.print(": ");
      Serial.print(WiFi.SSID(i));
      Serial.print("\tSinal: ");
      Serial.print(WiFi.RSSI(i));
      Serial.println(" dBm");
      Serial.print("\tNumero criptografia: ");
      Serial.print(WiFi.encryptionType(i));
      Serial.print("\tEncryption: ");
      printEncryption(WiFi.encryptionType(i));
    }
    delay(5000);
    Serial.flush();
  }
}

void printEncryption(int type) {
  switch (type) {
    case 2:
      Serial.println("WPA");
      break;
    case 4:
      Serial.println("WPA2");
      break;
    case 5:
      Serial.println("WEP");
      break;
    case 7:
      Serial.println("Nenhum");
      break;
    case 8:
      Serial.println("Auto");
      break;
    default:
      Serial.println("Erro");
      break;
  }
}