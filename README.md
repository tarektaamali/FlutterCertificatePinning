```markdown
# Démo de Flutter Certificate Pinning

## Aperçu du Projet
Ce projet Flutter montre comment implémenter le "certificate pinning" et utiliser un proxy avec le client HTTP Dio. Le "certificate pinning" est une mesure de sécurité qui aide à prévenir les attaques de type "man-in-the-middle" en s'assurant que le client ne fait confiance qu'à des certificats serveur spécifiques.

## Fonctionnalités
- **Certificate Pinning** : Fixer un certificat CA personnalisé pour renforcer la sécurité.
- **Client HTTP Dio** : Faire des requêtes API en utilisant la bibliothèque Dio, qui permet de configurer des clients HTTP personnalisés, des proxys et des intercepteurs de journalisation.
- **Configuration de Proxy** : Router les requêtes via un proxy à des fins de débogage.

## Démarrage

### Prérequis
- Flutter SDK 2.18.0 ou version ultérieure
- Connexion Internet pour récupérer les données de l'API JSONPlaceholder

### Installation
1. Clonez le dépôt :
   ```bash
   git clone <votre-url-repo>
   ```
2. Naviguez vers le répertoire du projet :
   ```bash
   cd <répertoire-projet>
   ```
3. Installez les dépendances :
   ```bash
   flutter pub get
   ```

### Exécution de l'Application
1. Connectez un appareil physique ou un émulateur.
2. Exécutez l'application avec :
   ```bash
   flutter run
   ```

## Structure du Répertoire
- `lib/main.dart` : Point d'entrée de l'application Flutter.
- `lib/services/api_service.dart` : Gère la configuration de Dio avec le "certificate pinning" et les paramètres de proxy.
- `assets/certificates` : Dossier contenant les certificats CA utilisés pour le pinning.

## Détails de l'Implémentation

### Configuration de Dio et Certificate Pinning
L'application utilise la bibliothèque Dio pour les requêtes HTTP. La classe `ApiService` configure Dio pour :

- **Utiliser un Certificat SSL Personnalisé** : Cela garantit que seuls les certificats de confiance sont utilisés par l'application. Le certificat JMeter personnalisé est chargé depuis le dossier `assets/certificates` et ajouté au `SecurityContext`.
- **Configurer un Proxy** : Un proxy peut être configuré à des fins de développement.
- **Intercepteurs de Requêtes** : Des intercepteurs de journalisation sont ajoutés pour aider au débogage.

### Extraits de Code Clés

#### ApiService (`lib/services/api_service.dart`)
```dart
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/adapter.dart';

class ApiService {
  static final ApiService instance = ApiService._privateConstructor();
  late final Dio dio;

  Future<void> initialize() async {
    try {
      final sslCert = await rootBundle.load('assets/certificates/jmeter_cert.crt');
      SecurityContext securityContext = SecurityContext(withTrustedRoots: true);
      securityContext.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());
      HttpClient httpClient = HttpClient(context: securityContext);
      httpClient.findProxy = (Uri uri) {
        return "PROXY 10.1.15.221:8080;";
      };
      dio = Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        return httpClient;
      };
      dio.options.baseUrl = 'https://jsonplaceholder.typicode.com';
      dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    } catch (e) {
      throw Exception("Impossible d'initialiser Dio : $e");
    }
  }
}
```

### Configuration de la Sécurité Réseau (Android)
Pour faire confiance au certificat CA JMeter personnalisé, ajoutez la configuration suivante dans `android/app/src/main/res/xml/network_security_config.xml` :
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config>
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
            <certificates src="@raw/jmeter_cert" />
        </trust-anchors>
    </base-config>
</network-security-config>
```