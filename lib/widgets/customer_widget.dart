import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerWidget extends StatelessWidget {
  final Customer customer;
  final VoidCallback onServe;

  const CustomerWidget({
    Key? key,
    required this.customer,
    required this.onServe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  customer.avatar,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.nameCn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            customer.requestedFood.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customer.requestedFood.nameCn,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!customer.isServed)
                  ElevatedButton(
                    onPressed: onServe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('上菜'),
                  )
                else
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 耐心值进度条
            if (!customer.isServed) ...[
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${customer.remainingTime}s',
                    style: TextStyle(
                      fontSize: 12,
                      color: customer.isAngry ? Colors.red : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: customer.patiencePercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        customer.patiencePercentage > 0.5
                            ? Colors.green
                            : customer.patiencePercentage > 0.25
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '💰${customer.requestedFood.price + customer.tip}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
