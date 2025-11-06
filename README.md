# CRUD Usuarios - Flutter

## Descripción General
Aplicación Flutter que implementa un sistema CRUD (Create, Read, Update, Delete) completo para la gestión de usuarios, consumiendo la API REST de JSONPlaceholder.

## Características Principales
- ✅ **CREATE**: Crear nuevos usuarios con formulario completo
- ✅ **READ**: Listar todos los usuarios y ver detalles individuales
- ✅ **UPDATE**: Editar información de usuarios existentes
- ✅ **DELETE**: Eliminar usuarios con confirmación

## Tecnologías Utilizadas
- **Framework**: Flutter 3.x
- **Lenguaje**: Dart
- **HTTP Client**: http ^1.2.0
- **API**: JSONPlaceholder (https://jsonplaceholder.typicode.com/users)
- **Arquitectura**: MVC (Model-View-Controller)

## Estructura del Proyecto
```
lib/
├── main.dart                 # Punto de entrada
├── models/
│   └── user.dart            # Modelo de datos (User, Address, Company)
├── services/
│   └── api_service.dart     # Servicio HTTP para API REST
└── pages/
    ├── home_page.dart       # Lista de usuarios
    ├── user_detail_page.dart # Detalle de usuario
    └── user_form_page.dart   # Formulario crear/editar
```

## Funcionalidades

### 1. Lista de Usuarios (HomePage)
- Muestra todos los usuarios en cards con información básica
- Pull-to-refresh para actualizar datos
- Menú contextual con opciones: Ver, Editar, Eliminar
- Botón flotante para agregar nuevo usuario

### 2. Detalle de Usuario (UserDetailPage)
- Información completa organizada en secciones:
  - Información Personal (nombre, email, teléfono, etc.)
  - Dirección completa
  - Información de la empresa

### 3. Formulario de Usuario (UserFormPage)
- Formulario completo con validaciones
- Modo crear y editar
- Campos organizados en secciones con cards
- Validación de campos requeridos

### 4. Servicio API (ApiService)
- `fetchUsers()`: Obtiene lista de usuarios
- `fetchUserById(id)`: Obtiene usuario específico
- `createUser(user)`: Crea nuevo usuario
- `updateUser(id, user)`: Actualiza usuario existente
- `deleteUser(id)`: Elimina usuario

## Instalación y Ejecución

### Prerrequisitos
- Flutter SDK 3.x o superior
- Dart SDK
- Editor (VS Code, Android Studio)
- Emulador o dispositivo físico

### Pasos
1. Clonar el repositorio
2. Instalar dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecutar la aplicación:
   ```bash
   flutter run
   ```

## API Endpoints Utilizados
- `GET /users` - Obtener todos los usuarios
- `GET /users/{id}` - Obtener usuario por ID
- `POST /users` - Crear nuevo usuario
- `PUT /users/{id}` - Actualizar usuario
- `DELETE /users/{id}` - Eliminar usuario

## Modelo de Datos

### Usuario
```dart
class User {
  int id;
  String name;
  String username;
  String email;
  String phone;
  String website;
  Address address;
  Company company;
}
```

### Dirección
```dart
class Address {
  String street;
  String suite;
  String city;
  String zipcode;
}
```

### Empresa
```dart
class Company {
  String name;
  String catchPhrase;
  String bs;
}
```

## Capturas de Pantalla
*(Agregar capturas de la aplicación funcionando)*

## Reflexión Final

### ¿Qué aprendí del consumo de API REST?

1. **Manejo de Estados Asíncronos**: Implementar `FutureBuilder` para manejar los diferentes estados de las peticiones HTTP (loading, success, error).

2. **Gestión de Errores**: Importancia de manejar excepciones y mostrar mensajes informativos al usuario.

3. **Serialización de Datos**: Crear métodos `fromJson()` y `toJson()` para convertir entre objetos Dart y JSON.

4. **Arquitectura Limpia**: Separar responsabilidades entre modelos, servicios y vistas para un código mantenible.

5. **UX/UI**: Implementar indicadores de carga, mensajes de confirmación y validaciones para mejorar la experiencia del usuario.

6. **HTTP Methods**: Comprender el uso correcto de GET, POST, PUT y DELETE según la operación CRUD.

7. **Estado de la Aplicación**: Manejar la actualización de la UI cuando los datos cambian después de operaciones CRUD.

## Autor
Diego - Clase Final DAM

## Licencia
Este proyecto es para fines educativos.