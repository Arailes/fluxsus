/// Modelo para eventos de telemetria do FluxSUS
/// Rastreia cada decisão clínica que economiza recursos

part of 'telemetry_service.dart';

class TelemetryEvent {
  final String id;
  final DateTime timestamp;
  final String calculatorType; // 'wells', 'cardio', 'lab'
  final String outcome; // 'exam_avoided', 'optimized', etc
  final String procedureType; // 'ANGIO_TC', 'SINVASTATINA_40', etc
  final double costSaved; // Em R$
  final Map<String, dynamic> metadata; // Dados adicionais

  TelemetryEvent({
    required this.id,
    required this.timestamp,
    required this.calculatorType,
    required this.outcome,
    required this.procedureType,
    required this.costSaved,
    this.metadata = const {},
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'calculator_type': calculatorType,
    'outcome': outcome,
    'procedure_type': procedureType,
    'cost_saved': costSaved,
    'metadata': metadata,
  };

  /// Cria a partir de JSON
  factory TelemetryEvent.fromJson(Map<String, dynamic> json) => TelemetryEvent(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    calculatorType: json['calculator_type'] as String,
    outcome: json['outcome'] as String,
    procedureType: json['procedure_type'] as String,
    costSaved: (json['cost_saved'] as num).toDouble(),
    metadata: json['metadata'] as Map<String, dynamic>? ?? {},
  );

  /// Descrição legível
  String get description {
    return '$calculatorType: $outcome ($procedureType) - R\$ ${costSaved.toStringAsFixed(2)}';
  }
}
