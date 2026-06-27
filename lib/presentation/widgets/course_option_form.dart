import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/schedule_controller.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/week_day.dart';
import 'day_selector.dart';
import 'time_input_field.dart';

class CourseOptionForm extends StatefulWidget {
  const CourseOptionForm({super.key});

  @override
  State<CourseOptionForm> createState() => _CourseOptionFormState();
}

class _CourseOptionFormState extends State<CourseOptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _professorController = TextEditingController();
  final _sectionController = TextEditingController();

  Set<WeekDay> _selectedDays = {WeekDay.monday};
  String _start = '07:00';
  String _end = '08:00';

  @override
  void dispose() {
    _subjectController.dispose();
    _professorController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agregar profesor/materia', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Materia',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa la materia' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _professorController,
                decoration: const InputDecoration(
                  labelText: 'Profesor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa el profesor' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sectionController,
                decoration: const InputDecoration(
                  labelText: 'Sección / grupo',
                  hintText: 'Ej. OO4',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Días'),
              const SizedBox(height: 6),
              DaySelector(
                selectedDays: _selectedDays,
                onChanged: (days) => setState(() => _selectedDays = days),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TimeInputField(
                      label: 'Inicio',
                      value: _start,
                      onChanged: (value) => setState(() => _start = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TimeInputField(
                      label: 'Fin',
                      value: _end,
                      onChanged: (value) => setState(() => _end = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Guardar opción'),
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: si una materia tiene horarios distintos por día, guarda una opción por bloque o ajusta el JSON seed.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      _showMessage('Selecciona al menos un día.');
      return;
    }

    if (!TimeUtils.isWithinBaseSchedule(_start, _end)) {
      _showMessage('Usa horas dentro de 07:00 a 21:00 y revisa que inicio sea menor que fin.');
      return;
    }

    await context.read<ScheduleController>().addOption(
          subject: _subjectController.text,
          professor: _professorController.text,
          section: _sectionController.text,
          days: _selectedDays.toList(),
          start: _start,
          end: _end,
        );

    _subjectController.clear();
    _professorController.clear();
    _sectionController.clear();
    setState(() {
      _selectedDays = {WeekDay.monday};
      _start = '07:00';
      _end = '08:00';
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
