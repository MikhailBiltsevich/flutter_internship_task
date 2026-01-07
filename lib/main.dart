import 'package:app/storage_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      //home: const StartScreen(),
      home: FutureBuilder<String?>(
        future: StorageService.getSubscription(),
        builder: (context, snapshot) {
          // Пока ждем данные из SharedPreferences
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)));
          }

          // Если подписка есть — открываем экран контента
          if (snapshot.hasData && snapshot.data != null) {
            return ContentScreen(subscriptionType: snapshot.data!);
          }

          // Если подписки нет — показываем стартовый экран
          return const StartScreen();
        },
      ),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Добро пожаловать в наше приложение',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple[900]),
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56), // Кнопка на всю ширину
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
            );
          },
          child: const Text('Продолжить', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выберите подписку'), automaticallyImplyLeading: false,),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Выберите подходящий план:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            
            // Месячная подписка
            _buildSubscriptionCard(
              context: context,
              type: 'Подписка на месяц',
              typeKey: 'monthly',
              priceMain: '500 ₽',
              priceSubtitle: 'Доступ ко всем функциям на 30 дней',
              isPopular: false,
            ),
            
            const SizedBox(height: 16),
            
            // Годовая подписка
            _buildSubscriptionCard(
              context: context,
              type: 'Подписка на год',
              typeKey: 'yearly',
              priceMain: '4 800 ₽', // Цена за год
              priceSubtitle: '400 ₽ в месяц (экономия 20%)', // Указываем выгоду
              isPopular: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required BuildContext context,
    required String type,
    required String typeKey,
    required String priceMain,
    required String priceSubtitle,
    bool isPopular = false,
  }) {
    final Color primaryColor = Colors.deepPurple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPopular ? primaryColor.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular ? primaryColor : Colors.grey.shade300,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPopular ? primaryColor : Colors.black87,
                ),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ВЫГОДНО',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            priceMain,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            priceSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async  {
                await StorageService.saveSubscription(typeKey);
                Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContentScreen(subscriptionType: typeKey,)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Продолжить'),
            ),
          ),
        ],
      ),
    );
  }
}

class ContentScreen extends StatelessWidget {
  final String subscriptionType;
  const ContentScreen({super.key, required this.subscriptionType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              Text(
                subscriptionType == 'yearly' 
                    ? 'Вам доступен полный безлимит на год!' 
                    : 'Ваш доступ ограничен одним месяцем.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}