import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class CourseDetailMinimalScreen extends StatelessWidget {
  final Map<String, dynamic> courseInfo;
  final String userType;

  const CourseDetailMinimalScreen({
    Key? key,
    required this.courseInfo,
    required this.userType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const brand = Color(0xFF2B1A7F);
    final info = courseInfo;

    double _toDouble(dynamic v) {
      if (v == null) return double.nan;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v.replaceAll('%', '').trim());
        return parsed ?? double.nan;
      }
      return double.nan;
    }

    final title = (info['nombre'] ?? info['title'] ?? 'Curso').toString();
    final description =
        (info['descripcion'] ?? info['temario'] ?? '').toString();
    final modules =
        (info['modulesData'] as List?)?.cast<Map<String, dynamic>>() ??
            const [];
    final totalModules = modules.length;
    final completedModules =
        modules.where((m) => (m['completed'] == true)).length;
    final progress =
        totalModules == 0 ? 0.0 : completedModules / totalModules;
    final grades =
        (info['gradesData'] as List?)?.cast<Map<String, dynamic>>() ??
            const [];

    // Calcular promedio como tasa de aprobación (%): Aprobado / Total * 100
    final Set<String> approvedIds = {};
    final Set<String> approvedNames = {};
    final Set<String> distinctIds = {};
    final Set<String> distinctNames = {};
    for (final g in grades) {
      final status = (g['status'] ?? '').toString().toLowerCase().trim();
      final mid = (g['moduleId'] ?? g['idModulo'] ?? g['id_modulo'] ?? g['id'])?.toString() ?? '';
      final rawName = (g['module'] ?? g['modulo'] ?? g['nombre'])?.toString() ?? '';
      final mname = rawName.toLowerCase().trim();
      if (mid.isNotEmpty) distinctIds.add(mid);
      if (mname.isNotEmpty) distinctNames.add(mname);
      final isApproved = status.contains('aprob');
      if (isApproved) {
        if (mid.isNotEmpty) approvedIds.add(mid);
        if (mname.isNotEmpty) approvedNames.add(mname);
      }
    }

    int numerator = 0;
    int denominator = 0;
    if (totalModules > 0) {
      for (final m in modules) {
        final id = (m['id'] ?? m['idModulo'] ?? m['id_modulo'])?.toString() ?? '';
        final name = (m['title'] ?? m['nombre'] ?? m['nombreModulo'] ?? m['nombre_modulo'])?.toString().toLowerCase().trim() ?? '';
        if ((id.isNotEmpty && approvedIds.contains(id)) || (name.isNotEmpty && approvedNames.contains(name))) {
          numerator += 1;
        }
      }
      denominator = totalModules;
    } else {
      final distinctCount = distinctIds.isNotEmpty
          ? distinctIds.length
          : (distinctNames.isNotEmpty ? distinctNames.length : grades.length);
      final approvedCount = approvedIds.isNotEmpty
          ? approvedIds.length
          : (approvedNames.isNotEmpty
              ? approvedNames.length
              : grades.where((g) =>
                  ((g['status'] ?? '').toString().toLowerCase().contains('aprob'))).length);
      numerator = approvedCount;
      denominator = distinctCount;
    }

    final computedAverage = denominator == 0
        ? double.nan
        : (numerator * 100.0) / denominator;

    final attendanceRaw = info['asistencia'] ?? info['attendance'] ?? 0;
    final attendance = _toDouble(attendanceRaw);

    String _extractTeacher(dynamic raw) {
      if (raw == null) return '';
      if (raw is String) return raw.trim();
      if (raw is Map) {
        final nombres = raw['nombres']?.toString() ?? '';
        final apellidos = raw['apellidos']?.toString() ?? '';
        final combinado = '$nombres $apellidos'.trim();
        if (combinado.isNotEmpty) return combinado;
        final name = (raw['nombre'] ?? raw['name'] ?? raw['label'])?.toString() ?? '';
        return name.trim();
      }
      return raw.toString().trim();
    }

    final Map<String, String> _teacherByModuleId = {};
    final Map<String, String> _teacherByModuleName = {};
    for (final m in modules) {
      final id = (m['id'] ?? m['idModulo'] ?? m['id_modulo'])?.toString() ?? '';
      final name = (m['title'] ?? m['nombre'] ?? m['nombreModulo'] ?? m['nombre_modulo'])?.toString() ?? '';
      final direct = _extractTeacher(m['teacher'] ?? m['docente']);
      if (direct.isNotEmpty && direct.toLowerCase() != 'null') {
        if (id.isNotEmpty && id.toLowerCase() != 'null') _teacherByModuleId[id] = direct;
        if (name.isNotEmpty && name.toLowerCase() != 'null') _teacherByModuleName[name.toLowerCase().trim()] = direct;
      }
    }

    for (final g in grades) {
      final moduleId = (g['moduleId'] ?? g['idModulo'] ?? g['id_modulo'])?.toString() ?? '';
      String moduleName = '';
      final rawM = g['module'] ?? g['modulo'] ?? g['nombre'];
      if (rawM is Map) {
        moduleName = (rawM['nombre'] ?? rawM['title'] ?? rawM['nombreModulo'] ?? rawM['nombre_modulo'] ?? rawM['titulo'] ?? '').toString();
      } else if (rawM is String) {
        moduleName = rawM;
      } else if (rawM != null) {
        moduleName = rawM.toString();
      }
      final teacher = _extractTeacher(g['teacher'] ?? g['docente']);
      if (teacher.isNotEmpty && teacher.toLowerCase() != 'null') {
        if (moduleId.isNotEmpty && moduleId.toLowerCase() != 'null') _teacherByModuleId[moduleId] = teacher;
        if (moduleName.isNotEmpty) _teacherByModuleName[moduleName.toLowerCase().trim()] = teacher;
      }
    }

    // Integrar datos de docentes desde HomeScreen si fueron provistos
    final dynamic moduleTeachersData = info['moduleTeachersData'];
    if (moduleTeachersData is Map) {
      final dynamic byIdRaw = moduleTeachersData['byId'];
      if (byIdRaw is Map) {
        for (final entry in byIdRaw.entries) {
          final k = entry.key?.toString() ?? '';
          final v = _extractTeacher(entry.value);
          if (k.isNotEmpty && v.isNotEmpty) {
            _teacherByModuleId[k] = v;
          }
        }
      }
      final dynamic byNameRaw = moduleTeachersData['byName'];
      if (byNameRaw is Map) {
        for (final entry in byNameRaw.entries) {
          final k = entry.key?.toString().toLowerCase().trim() ?? '';
          final v = _extractTeacher(entry.value);
          if (k.isNotEmpty && v.isNotEmpty) {
            _teacherByModuleName[k] = v;
          }
        }
      }
    }

    String _resolveTeacher(Map<String, dynamic> m) {
      final direct = _extractTeacher(m['teacher'] ?? m['docente']);
      if (direct.isNotEmpty && direct.toLowerCase() != 'null') return direct;
      final id = (m['id'] ?? m['idModulo'] ?? m['id_modulo'])?.toString() ?? '';
      final byId = _teacherByModuleId[id];
      if (byId != null && byId.isNotEmpty) return byId;
      final name = (m['title'] ?? m['nombre'] ?? m['nombreModulo'] ?? m['nombre_modulo'])?.toString() ?? '';
      final key = name.toLowerCase().trim();
      final byName = _teacherByModuleName[key];
      if (byName != null && byName.isNotEmpty) return byName;
      return 'Asignado';
    }

    Future<void> _openResourceUrl(String url) async {
      if (url.isEmpty) return;
      final uri = Uri.tryParse(url);
      if (uri == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enlace inválido')),
        );
        return;
      }
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el enlace')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al abrir el enlace')),
        );
      }
    }

    Future<void> _downloadResource(String url, {String? suggestedName}) async {
      if (url.isEmpty) return;
      final uri = Uri.tryParse(url);
      if (uri == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enlace inválido')),
        );
        return;
      }
      // Web: abrir en navegador (el navegador maneja la descarga)
      if (kIsWeb) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Descarga iniciada en el navegador')),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo iniciar la descarga')),
          );
        }
        return;
      }

      try {
        final resp = await http.get(uri);
        if (resp.statusCode != 200) {
          // Fallback: abrir enlace
          await _openResourceUrl(url);
          return;
        }

        final nameFromUrl = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : 'recurso_${DateTime.now().millisecondsSinceEpoch}';
        final sanitized = (suggestedName ?? nameFromUrl)
            .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

        Directory baseDir;
        // Preferir documentos de la app (sin permisos adicionales)
        baseDir = await getApplicationDocumentsDirectory();

        final filePath = '${baseDir.path}/$sanitized';
        final file = File(filePath);
        await file.writeAsBytes(resp.bodyBytes, flush: true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Descargado: $filePath')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al descargar el recurso')),
        );
      }
    }

    Widget metricCard(String t, String v) {
      return Expanded(
        child: Card(
          elevation: 0,
          color: brand.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(v,
                    style: theme.textTheme.titleLarge?.copyWith(
                        color: brand, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }

    Widget supportContentList(List<Map<String, dynamic>> items) {
      if (items.isEmpty) {
        return Center(
          child: Text('Sin recursos disponibles',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        );
      }
      return ListView.builder(
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final it = items[index];
          final t = (it['title'] ?? it['nombre'] ?? 'Recurso').toString();
          final desc = (it['description'] ?? '').toString();
          final url = (it['url'] ?? it['link'] ?? it['downloadUrl'] ?? it['archivo_url'] ?? it['fileUrl'] ?? it['resourceUrl'] ?? '').toString();
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(t),
              subtitle: desc.isNotEmpty ? Text(desc) : null,
              leading: const Icon(Icons.insert_drive_file),
              trailing: TextButton.icon(
                onPressed: url.isNotEmpty ? () => _downloadResource(url, suggestedName: t) : null,
                icon: const Icon(Icons.download),
                label: const Text('Descargar'),
              ),
              onTap: url.isNotEmpty ? () => _openResourceUrl(url) : null,
            ),
          );
        },
      );
    }

    Widget buildGradesTab() {
      Color _statusAura(String statusRaw) {
        final s = statusRaw.trim().toLowerCase();
        // Verde para estados aprobados o completados
        if (s.contains('aprob') || s.contains('complet') || s.contains('finaliz')) {
          return const Color(0xFF00E676);
        }
        // Gris para pendientes/en progreso
        if (s.contains('pend')) {
          return Colors.grey;
        }
        // Rojo para desaprobados/reprobados/no aprobados
        if (s.contains('desaprob') || s.contains('reprob') || s.contains('no aprob')) {
          return const Color(0xFFFF1744);
        }
        return scheme.onSurfaceVariant;
      }

      bool _looksLikeId(String s) {
        final t = s.trim();
        return RegExp(r'^\d+$').hasMatch(t);
      }

      final Map<String, String> moduleNameById = {
        for (final m in modules)
          (m['id'] ?? m['idModulo'] ?? '').toString():
              (m['title'] ?? m['nombre'] ?? 'Módulo').toString(),
      };

      Widget gradesList(List<Map<String, dynamic>> items) {
        if (items.isEmpty) {
          return Center(
            child: Text('Sin calificaciones disponibles',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          );
        }
        return ListView.builder(
          itemCount: items.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final it = items[index];
            String mName = '';
            final rawMod = it['module'] ?? it['modulo'] ?? it['nombre'];
            if (rawMod is Map) {
              mName = (rawMod['nombre'] ??
                      rawMod['title'] ??
                      rawMod['nombreModulo'] ??
                      rawMod['nombre_modulo'] ??
                      rawMod['titulo'] ??
                      '')
                  .toString();
            } else if (rawMod is String) {
              mName = rawMod;
            } else if (rawMod != null) {
              mName = rawMod.toString();
            }

            final moduleId = (it['moduleId'] ?? it['idModulo'] ?? '').toString();
            if (mName.isEmpty || _looksLikeId(mName) || mName.startsWith('{')) {
              final resolved = moduleNameById[moduleId];
              mName =
                  (resolved != null && resolved.isNotEmpty) ? resolved : 'Módulo';
            }

            String statusText = '';
            final rawSt = it['status'] ?? it['estado'];
            if (rawSt is Map) {
              statusText = (rawSt['estado'] ??
                      rawSt['status'] ??
                      rawSt['name'] ??
                      rawSt['label'] ??
                      rawSt['texto'] ??
                      '')
                  .toString();
            } else if (rawSt is String) {
              statusText = rawSt;
            } else if (rawSt != null) {
              statusText = rawSt.toString();
            }
            final aura = _statusAura(statusText);

            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: aura.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: aura.withOpacity(0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(mName, style: theme.textTheme.titleMedium),
                ),
              ),
            );
          },
        );
      }

      return gradesList(grades);
    }

    Widget buildAttendanceTab() {
      Color _attendanceAura(String statusRaw) {
        final s = statusRaw.trim().toLowerCase();
        // Presentes
        const presentValues = {
          'presente', 'asistió', 'asistio', 'si', 'sí', 'true', '1', 'p', 'present', 'yes', 'y'
        };
        // Ausentes
        const absentValues = {'ausente', 'falta', 'no', 'false', '0', 'a', 'absent', 'n'};
        // Tarde
        const lateValues = {'tarde', 'retardo', 'late', 't'};

        if (presentValues.contains(s)) return const Color(0xFF00E676);
        if (absentValues.contains(s)) return const Color(0xFFFF1744);
        if (lateValues.contains(s)) return const Color(0xFFFF9100);
        if (s == 'justificado') return Colors.grey;
        return scheme.onSurfaceVariant;
      }

      IconData _attendanceIcon(String statusRaw) {
        final s = statusRaw.trim().toLowerCase();
        const presentValues = {
          'presente', 'asistió', 'asistio', 'si', 'sí', 'true', '1', 'p', 'present', 'yes', 'y'
        };
        const lateValues = {'tarde', 'retardo', 'late', 't'};
        if (presentValues.contains(s)) return Icons.check_circle;
        // Ícono de chulo también para tardanza, según solicitud
        if (lateValues.contains(s)) return Icons.check_circle;
        return Icons.alarm;
      }

      String _formatShortDate(String raw) {
        String s = raw.trim();
        if (s.isEmpty) return 'Fecha';
        if (s.contains('T')) s = s.split('T').first;
        final months = [
          'Ene',
          'Feb',
          'Mar',
          'Abr',
          'May',
          'Jun',
          'Jul',
          'Ago',
          'Sep',
          'Oct',
          'Nov',
          'Dic'
        ];
        final m1 = RegExp(r'^(\d{4})[-/](\d{2})[-/](\d{2})').firstMatch(s);
        if (m1 != null) {
          final d = int.tryParse(m1.group(3) ?? '') ?? 0;
          final m = int.tryParse(m1.group(2) ?? '') ?? 1;
          final mon = (m >= 1 && m <= 12) ? months[m - 1] : '';
          return '${d.toString().padLeft(2, '0')} $mon';
        }
        final m2 = RegExp(r'^(\d{2})[-/](\d{2})[-/](\d{4})').firstMatch(s);
        if (m2 != null) {
          final d = int.tryParse(m2.group(1) ?? '') ?? 0;
          final m = int.tryParse(m2.group(2) ?? '') ?? 1;
          final mon = (m >= 1 && m <= 12) ? months[m - 1] : '';
          return '${d.toString().padLeft(2, '0')} $mon';
        }
        final parts = s.split('-');
        if (parts.length >= 3) {
          final d = int.tryParse(parts[2]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 1;
          final mon = (m >= 1 && m <= 12) ? months[m - 1] : '';
          return '${d.toString().padLeft(2, '0')} $mon';
        }
        return s;
      }

      final List<Map<String, dynamic>> attendanceItems =
          (info['attendanceData'] as List?)?.cast<Map<String, dynamic>>() ??
              const [];
      if (attendanceItems.isEmpty) {
        return Center(
          child: Text('Sin registros de asistencia',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        );
      }

      int crossAxisCount = 2;
      final width = MediaQuery.of(context).size.width;
      if (width >= 1200) {
        crossAxisCount = 4;
      } else if (width >= 800) {
        crossAxisCount = 3;
      }
      // Ajustar la relación de aspecto para evitar overflow en pantallas pequeñas.
      // En móviles, hacemos las tarjetas más altas (ratio más bajo).
      double childAspectRatio = 1.6; // ancho/alto
      if (width < 800) {
        childAspectRatio = 0.95; // más alto en móviles
      } else if (width < 1200) {
        childAspectRatio = 1.3; // tablets medianas
      } else {
        childAspectRatio = 1.6; // escritorio
      }

      // Helper para inferir estado a partir de múltiples campos
      String _inferStatus(Map<String, dynamic> it, String statusText) {
        String s = statusText.trim().toLowerCase();
        if (s.isEmpty || s == '{}' || s == 'null') {
          final raw = it['status'] ?? it['estado'] ?? it['asistio'] ?? it['presente'];
          if (raw is bool) return raw ? 'presente' : 'ausente';
          if (raw is num) return raw == 1 ? 'presente' : 'ausente';
          if (raw != null) s = raw.toString().trim().toLowerCase();
        }
        const presentValues = {
          'presente','asistió','asistio','si','sí','true','1','p','present','yes','y'
        };
        const absentValues = {
          'ausente','falta','no','false','0','a','absent','n'
        };
        const lateValues = {'tarde','retardo','late','t'};
        if (presentValues.contains(s)) return 'presente';
        if (absentValues.contains(s)) return 'ausente';
        if (lateValues.contains(s)) return 'tarde';
        if (s == 'justificado' || s == 'excused') return 'justificado';
        return s.isEmpty ? 'desconocido' : s;
      }

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.fact_check, color: brand, size: 20),
                ),
                const SizedBox(width: 8),
                Text('Registro de Asistencia',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: attendanceItems.length,
                itemBuilder: (context, index) {
                  final it = attendanceItems[index];
                  final dateRaw = (it['date'] ?? '').toString();
                  String statusText = (it['status'] ?? '').toString();
                  if (statusText.startsWith('{')) statusText = '';
                  final inferred = _inferStatus(it, statusText);
                  final aura = _attendanceAura(inferred);
                  final icon = _attendanceIcon(inferred);
                  final dateLabel = _formatShortDate(dateRaw);
                  final isPresent = inferred == 'presente';

                  return Container(
                    decoration: BoxDecoration(
                      // Si es presente, usamos un fondo más verde para destacar
                      color: isPresent ? aura.withOpacity(0.25) : aura.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: aura.withOpacity(0.20),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(color: aura.withOpacity(0.18)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            // Más intensidad de color para presentes
                            color: isPresent ? aura.withOpacity(0.35) : aura.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: aura, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dateLabel,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        if (statusText.isNotEmpty)
                          Text(
                            statusText[0].toUpperCase() +
                                statusText.substring(1),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: aura),
                          )
                        else
                          Text(
                            inferred[0].toUpperCase() + inferred.substring(1),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: aura),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: brand,
          iconTheme: IconThemeData(color: brand),
          title: Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: brand, fontWeight: FontWeight.w600)),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700, color: brand)),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(description,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        metricCard(
                            'Promedio',
                            computedAverage.isNaN
                                ? '—'
                                : '${computedAverage.toStringAsFixed(0)}%'),
                        const SizedBox(width: 8),
                        metricCard(
                            'Asistencia',
                            attendance.isNaN
                                ? '—'
                                : '${attendance.toStringAsFixed(0)}%'),
                        const SizedBox(width: 8),
                        metricCard(
                            'Módulos',
                            totalModules == 0
                                ? '0/0'
                                : '$completedModules/$totalModules'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Progreso General',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.isNaN ? 0 : progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: brand.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(brand),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      totalModules == 0
                          ? 'Sin módulos'
                          : '${completedModules == 1 ? '1' : completedModules} de $totalModules módulos completados',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  labelColor: brand,
                  unselectedLabelColor: scheme.onSurfaceVariant,
                  indicatorColor: brand,
                  tabs: const [
                    Tab(text: 'Módulos'),
                    Tab(text: 'Calificaciones'),
                    Tab(text: 'Asistencia'),
                    Tab(text: 'Recursos'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBarView(
                    children: [
                      // Módulos
                      ListView(
                        children: [
                          for (final m in modules)
                            Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        (m['title'] ??
                                                m['nombre'] ??
                                                'Módulo')
                                            .toString(),
                                        style:
                                            theme.textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Docente: ${_resolveTeacher(m)}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: scheme
                                                  .onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (modules.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'No hay módulos disponibles',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant),
                              ),
                            ),
                        ],
                      ),
                      // Calificaciones
                      buildGradesTab(),
                      // Asistencia
                      buildAttendanceTab(),
                      // Recursos
                      supportContentList(
                        (info['supportContentData'] as List?)
                                ?.cast<Map<String, dynamic>>() ??
                            const [],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
