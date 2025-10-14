import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
/// The `AcademicCalendarScreen` class in Dart represents a screen for displaying academic calendar
/// events based on user type and name.
class AcademicCalendarScreen extends StatefulWidget {
  final String userType;
  final String userName;

  const AcademicCalendarScreen({
    Key? key,
    required this.userType,
    required this.userName,
  }) : super(key: key);

  @override
  _AcademicCalendarScreenState createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  late Map<DateTime, List<AcademicEvent>> _events;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _events = _generateAcademicEvents();
    // Inicializar datos de localización para español de forma asíncrona
    _initializeLocalization();
  }

  Future<void> _initializeLocalization() async {
    await initializeDateFormatting('es_ES', null);
    if (mounted) {
      setState(() {});
    }
  }

  Map<DateTime, List<AcademicEvent>> _generateAcademicEvents() {
    final events = <DateTime, List<AcademicEvent>>{};
    final now = DateTime.now();
    final currentYear = now.year;

    // Eventos académicos generales
    final academicEvents = [
      // Inicio de semestre
      AcademicEvent(
        date: DateTime(currentYear, 2, 5),
        title: 'Inicio del Semestre Académico',
        description: 'Comienzo oficial del semestre académico',
        type: EventType.academic,
        color: Colors.blue,
      ),
      AcademicEvent(
        date: DateTime(currentYear, 8, 5),
        title: 'Inicio del Segundo Semestre',
        description: 'Comienzo del segundo semestre académico',
        type: EventType.academic,
        color: Colors.blue,
      ),

      // Períodos de exámenes
      AcademicEvent(
        date: DateTime(currentYear, 6, 15),
        title: 'Inicio Período de Exámenes',
        description: 'Comienzo de exámenes finales del primer semestre',
        type: EventType.exam,
        color: Colors.red,
      ),
      AcademicEvent(
        date: DateTime(currentYear, 12, 15),
        title: 'Inicio Período de Exámenes',
        description: 'Comienzo de exámenes finales del segundo semestre',
        type: EventType.exam,
        color: Colors.red,
      ),

      // Vacaciones
      AcademicEvent(
        date: DateTime(currentYear, 7, 1),
        title: 'Vacaciones de Invierno',
        description: 'Inicio de vacaciones de invierno',
        type: EventType.holiday,
        color: Colors.green,
      ),
      AcademicEvent(
        date: DateTime(currentYear, 1, 15),
        title: 'Vacaciones de Verano',
        description: 'Inicio de vacaciones de verano',
        type: EventType.holiday,
        color: Colors.green,
      ),

      // Eventos específicos de belleza
      AcademicEvent(
        date: DateTime(currentYear, 3, 15),
        title: 'Concurso de Peinados',
        description: 'Concurso anual de técnicas de peinado',
        type: EventType.competition,
        color: Colors.purple,
      ),
      AcademicEvent(
        date: DateTime(currentYear, 5, 20),
        title: 'Exposición de Maquillaje',
        description: 'Exposición de trabajos de maquillaje artístico',
        type: EventType.exhibition,
        color: Colors.orange,
      ),
      AcademicEvent(
        date: DateTime(currentYear, 9, 10),
        title: 'Workshop de Coloración',
        description: 'Taller intensivo de técnicas de coloración',
        type: EventType.workshop,
        color: Colors.teal,
      ),
      AcademicEvent(
        date: DateTime(currentYear, 11, 25),
        title: 'Certificación Profesional',
        description: 'Ceremonia de certificación profesional',
        type: EventType.certification,
        color: Colors.indigo,
      ),
    ];

    // Agregar eventos al mapa
    for (final event in academicEvents) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(event);
    }

    // Agregar eventos específicos según el tipo de usuario
    if (widget.userType == 'docente') {
      _addTeacherEvents(events, currentYear);
    } else {
      _addStudentEvents(events, currentYear);
    }

    return events;
  }

  void _addTeacherEvents(Map<DateTime, List<AcademicEvent>> events, int year) {
    final teacherEvents = [
      AcademicEvent(
        date: DateTime(year, 2, 10),
        title: 'Reunión de Docentes',
        description: 'Reunión mensual del cuerpo docente',
        type: EventType.meeting,
        color: Colors.brown,
      ),
      AcademicEvent(
        date: DateTime(year, 4, 15),
        title: 'Capacitación Docente',
        description: 'Capacitación en nuevas técnicas de enseñanza',
        type: EventType.training,
        color: Colors.cyan,
      ),
      AcademicEvent(
        date: DateTime(year, 6, 5),
        title: 'Evaluación de Cursos',
        description: 'Período de evaluación de cursos del primer semestre',
        type: EventType.evaluation,
        color: Colors.deepOrange,
      ),
    ];

    for (final event in teacherEvents) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(event);
    }
  }

  void _addStudentEvents(Map<DateTime, List<AcademicEvent>> events, int year) {
    final studentEvents = [
      AcademicEvent(
        date: DateTime(year, 2, 15),
        title: 'Inscripción de Cursos',
        description: 'Período de inscripción para nuevos cursos',
        type: EventType.registration,
        color: Colors.lime,
      ),
      AcademicEvent(
        date: DateTime(year, 4, 20),
        title: 'Feria de Empleo',
        description: 'Feria de empleo para estudiantes de belleza',
        type: EventType.career,
        color: Colors.amber,
      ),
      AcademicEvent(
        date: DateTime(year, 6, 10),
        title: 'Entrega de Proyectos',
        description: 'Fecha límite para entrega de proyectos finales',
        type: EventType.deadline,
        color: Colors.red,
      ),
    ];

    for (final event in studentEvents) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(event);
    }
  }

  List<AcademicEvent> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B1A7F),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Calendario Académico',
          style: TextStyle(
            color: Color(0xFF2B1A7F),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2B1A7F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Calendario
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TableCalendar<AcademicEvent>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              locale: 'es_ES', // Configuración para español
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: _onFormatChanged,
              onPageChanged: _onPageChanged,
              eventLoader: _getEventsForDay,
              // Configuración adicional para localización
              startingDayOfWeek: StartingDayOfWeek.monday, // Semana empieza en lunes
              // Configuración específica para mostrar texto en español
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mes',
                CalendarFormat.twoWeeks: '2 Semanas',
                CalendarFormat.week: 'Semana',
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red),
                holidayTextStyle: TextStyle(color: Colors.red),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF2B1A7F),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Color(0xFF2B1A7F),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: TextStyle(color: Colors.white),
                titleTextStyle: TextStyle(
                  color: Color(0xFF2B1A7F),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                // Configuración para mostrar días de la semana en español
                leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF2B1A7F)),
                rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF2B1A7F)),
              ),
              // Configuración de días de la semana
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Color(0xFF2B1A7F),
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Eventos del día seleccionado
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Eventos del ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B1A7F),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _getEventsForDay(_selectedDay).isEmpty
                        ? Center(
                            child: Text(
                              'No hay eventos programados para este día',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _getEventsForDay(_selectedDay).length,
                            itemBuilder: (context, index) {
                              final event = _getEventsForDay(_selectedDay)[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: event.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  title: Text(
                                    event.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B1A7F),
                                    ),
                                  ),
                                  subtitle: Text(
                                    event.description,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  trailing: _getEventIcon(event.type),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getEventIcon(EventType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case EventType.academic:
        iconData = Icons.school;
        iconColor = Colors.blue;
        break;
      case EventType.exam:
        iconData = Icons.assignment;
        iconColor = Colors.red;
        break;
      case EventType.holiday:
        iconData = Icons.beach_access;
        iconColor = Colors.green;
        break;
      case EventType.competition:
        iconData = Icons.emoji_events;
        iconColor = Colors.purple;
        break;
      case EventType.exhibition:
        iconData = Icons.photo_camera;
        iconColor = Colors.orange;
        break;
      case EventType.workshop:
        iconData = Icons.work;
        iconColor = Colors.teal;
        break;
      case EventType.certification:
        iconData = Icons.verified;
        iconColor = Colors.indigo;
        break;
      case EventType.meeting:
        iconData = Icons.meeting_room;
        iconColor = Colors.brown;
        break;
      case EventType.training:
        iconData = Icons.school;
        iconColor = Colors.cyan;
        break;
      case EventType.evaluation:
        iconData = Icons.assessment;
        iconColor = Colors.deepOrange;
        break;
      case EventType.registration:
        iconData = Icons.app_registration;
        iconColor = Colors.lime;
        break;
      case EventType.career:
        iconData = Icons.work;
        iconColor = Colors.amber;
        break;
      case EventType.deadline:
        iconData = Icons.schedule;
        iconColor = Colors.red;
        break;
    }

    return Icon(iconData, color: iconColor);
  }
}

class AcademicEvent {
  final DateTime date;
  final String title;
  final String description;
  final EventType type;
  final Color color;

  AcademicEvent({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    required this.color,
  });
}

enum EventType {
  academic,
  exam,
  holiday,
  competition,
  exhibition,
  workshop,
  certification,
  meeting,
  training,
  evaluation,
  registration,
  career,
  deadline,
}
