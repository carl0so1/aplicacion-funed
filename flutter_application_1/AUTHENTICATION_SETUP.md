# Configuración de Autenticación Real

## 📧 Configuración de Envío de Correos

### Opción 1: EmailJS (Gratuito)

1. **Registrarse en EmailJS:**
   - Ve a [emailjs.com](https://www.emailjs.com/)
   - Crea una cuenta gratuita

2. **Configurar el servicio de correo:**
   - Ve a "Email Services"
   - Agrega tu proveedor de correo (Gmail, Outlook, etc.)
   - Guarda el `service_id`

3. **Crear template de verificación:**
   - Ve a "Email Templates"
   - Crea un template con variables: `{{to_email}}`, `{{user_type}}`, `{{verification_link}}`
   - Guarda el `template_id`

4. **Obtener User ID:**
   - Ve a "Account" → "API Keys"
   - Copia tu `user_id`

5. **Actualizar el código:**
   ```dart
   // En lib/services/auth_service.dart
   static const String emailServiceUrl = 'https://api.emailjs.com/api/v1.0/email/send';
   
   // Reemplaza con tus credenciales:
   'service_id': 'tu_service_id',
   'template_id': 'tu_template_id', 
   'user_id': 'tu_user_id',
   ```

### Opción 2: Firebase Authentication

1. **Configurar Firebase:**
   ```bash
   flutter pub add firebase_core firebase_auth
   ```

2. **Configurar proyecto Firebase:**
   - Ve a [console.firebase.google.com](https://console.firebase.google.com/)
   - Crea un proyecto
   - Habilita Authentication → Email/Password
   - Habilita Email verification

3. **Actualizar el código:**
   ```dart
   // En lib/services/auth_service.dart
   import 'package:firebase_auth/firebase_auth.dart';
   
   static Future<bool> registerUser({
     required String email,
     required String password,
     required String userType,
   }) async {
     try {
       final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
         email: email,
         password: password,
       );
       
       await userCredential.user?.sendEmailVerification();
       
       // Guardar tipo de usuario
       final prefs = await SharedPreferences.getInstance();
       await prefs.setString('user_type', userType);
       
       return true;
     } catch (e) {
       print('Error: $e');
       return false;
     }
   }
   ```

### Opción 3: Backend Propio

1. **Crear servidor backend:**
   ```javascript
   // Node.js con Express y Nodemailer
   const express = require('express');
   const nodemailer = require('nodemailer');
   
   app.post('/api/register', async (req, res) => {
     const { email, password, userType } = req.body;
     
     // Guardar usuario en base de datos
     // Enviar correo de verificación
     
     const transporter = nodemailer.createTransporter({
       service: 'gmail',
       auth: {
         user: 'tu-email@gmail.com',
         pass: 'tu-password-app'
       }
     });
     
     await transporter.sendMail({
       from: 'tu-email@gmail.com',
       to: email,
       subject: 'Verifica tu cuenta',
       html: `<a href="https://tu-app.com/verify?token=${token}">Verificar</a>`
     });
   });
   ```

2. **Actualizar URL en el código:**
   ```dart
   static const String baseUrl = 'https://tu-backend.com/api';
   ```

## 🔧 Instalación de Dependencias

```bash
flutter pub get
```

## 📱 Configuración para Android

En `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 🍎 Configuración para iOS

En `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🚀 Pasos para Implementar

1. **Elegir opción de autenticación** (EmailJS, Firebase, o Backend propio)
2. **Configurar credenciales** en `lib/services/auth_service.dart`
3. **Probar registro** con un correo real
4. **Verificar envío** de correos de verificación
5. **Probar login** después de verificación

## 🔒 Seguridad

- **Tokens seguros:** Usa JWT o tokens únicos
- **HTTPS:** Siempre usa conexiones seguras
- **Validación:** Verifica correos en el servidor
- **Rate limiting:** Limita intentos de registro/login
- **Logs:** Registra intentos de autenticación

## 📧 Template de Correo Sugerido

```html
<!DOCTYPE html>
<html>
<head>
    <title>Verifica tu cuenta - FUNED Academia de Belleza</title>
</head>
<body>
    <h2>¡Bienvenido a FUNED Academia de Belleza!</h2>
    <p>Hola, has registrado una cuenta como {{user_type}}.</p>
    <p>Para completar tu registro, haz clic en el siguiente enlace:</p>
    <a href="{{verification_link}}" style="background: #2B1A7F; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
        Verificar mi cuenta
    </a>
    <p>Si no solicitaste esta cuenta, puedes ignorar este correo.</p>
    <p>Saludos,<br>Equipo FUNED</p>
</body>
</html>
```

## 🐛 Solución de Problemas

### Error de red:
- Verifica conexión a internet
- Revisa permisos de red en Android/iOS

### Error de correo:
- Verifica credenciales de EmailJS/Firebase
- Revisa configuración SMTP
- Verifica límites de envío

### Error de verificación:
- Verifica tokens únicos
- Revisa URLs de verificación
- Comprueba logs del servidor 