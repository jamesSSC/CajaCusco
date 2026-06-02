import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SimuladorScreen extends StatefulWidget {
  const SimuladorScreen({super.key});

  @override
  State<SimuladorScreen> createState() => _SimuladorScreenState();
}

class _SimuladorScreenState extends State<SimuladorScreen> {
  double _monto = 5000;
  int _plazo = 12;
  double _tea = 36.0;

  late double _cuotaMensual;

  @override
  void initState() {
    super.initState();
    _calcular();
  }

  void _calcular() {
    final tasaMensual = _tea / 100 / 12;
    final factor = pow(1 + tasaMensual, _plazo).toDouble();
    final numerador = _monto * tasaMensual * factor;
    final denominador = factor - 1;
    _cuotaMensual = numerador / denominador;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Crédito')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monto: S/ ${_monto.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Slider(
                      value: _monto,
                      min: 1000,
                      max: 50000,
                      onChanged: (v) => setState(() {
                        _monto = v;
                        _calcular();
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text('Plazo: $_plazo meses',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Slider(
                      value: _plazo.toDouble(),
                      min: 6,
                      max: 36,
                      divisions: 30,
                      label: '$_plazo meses',
                      onChanged: (v) => setState(() {
                        _plazo = v.toInt();
                        _calcular();
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text('TEA: ${_tea.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Slider(
                      value: _tea,
                      min: 20,
                      max: 50,
                      onChanged: (v) => setState(() {
                        _tea = v;
                        _calcular();
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('Cuota Mensual',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('S/ ${_cuotaMensual.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(height: 16),
                  Text('Total a pagar: S/ ${(_cuotaMensual * _plazo).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
