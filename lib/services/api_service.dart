import 'dart:convert';
import 'package:flutter_drud/models/user.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://jsonplaceholder.typicode.com/users';

  // Lista local para simular CRUD real
  static final List<User> _localUsers = [];
  static final List<User> _deletedUsers = []; // Papelera de reciclaje
  static int _nextId = 100; // IDs locales empiezan en 100

  // CREATE - Crear usuario (simulado localmente)
  Future<User> createUser(User user) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Crear usuario con ID local
    final newUser = User(
      id: _nextId++,
      name: user.name,
      username: user.username,
      email: user.email,
      phone: user.phone,
      website: user.website,
      address: user.address,
      company: user.company,
    );

    _localUsers.add(newUser);
    return newUser;
  }

  // READ - Obtener todos los usuarios (API + locales)
  Future<List<User>> fetchUsers() async {
    try {
      // Obtener usuarios de la API
      final response = await http.get(Uri.parse(baseUrl));
      List<User> apiUsers = [];

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        apiUsers = data.map((e) => User.fromJson(e)).toList();
      }

      // Filtrar usuarios eliminados de la API
      final deletedIds = _localUsers
          .where((u) => u.id < 0)
          .map((u) => -u.id)
          .toSet();

      apiUsers = apiUsers.where((u) => !deletedIds.contains(u.id)).toList();

      // Filtrar usuarios locales válidos (no eliminados)
      final validLocalUsers = _localUsers.where((u) => u.id > 0).toList();

      // Combinar usuarios de API con usuarios locales válidos
      final allUsers = [...apiUsers, ...validLocalUsers];
      return allUsers;
    } catch (e) {
      // Si falla la API, devolver solo usuarios locales válidos
      return _localUsers.where((u) => u.id > 0).toList();
    }
  }

  // READ - Obtener usuario por ID
  Future<User> fetchUserById(int id) async {
    // Buscar primero en usuarios locales
    final localUser = _localUsers.where((u) => u.id == id).firstOrNull;
    if (localUser != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return localUser;
    }

    // Si no está en locales, buscar en API
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error ${response.statusCode}: Usuario no encontrado');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // UPDATE - Actualizar usuario (solo si hay cambios reales)
  Future<User> updateUser(int id, User user) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Buscar y actualizar en usuarios locales
    final index = _localUsers.indexWhere((u) => u.id == id);
    if (index != -1) {
      final updatedUser = User(
        id: id,
        name: user.name,
        username: user.username,
        email: user.email,
        phone: user.phone,
        website: user.website,
        address: user.address,
        company: user.company,
      );
      _localUsers[index] = updatedUser;
      return updatedUser;
    }

    // Si es un usuario de la API (ID < 100), verificar si hay cambios reales
    if (id < 100) {
      // Obtener el usuario original de la API
      final originalUser = await _getOriginalApiUser(id);

      // Comparar si hay cambios reales
      if (originalUser != null && _hasRealChanges(originalUser, user)) {
        // Solo crear copia local si hay cambios reales
        final updatedUser = User(
          id: id,
          name: user.name,
          username: user.username,
          email: user.email,
          phone: user.phone,
          website: user.website,
          address: user.address,
          company: user.company,
        );
        _localUsers.add(updatedUser);
        return updatedUser;
      } else if (originalUser != null) {
        // No hay cambios, devolver el usuario original
        return originalUser;
      }
    }

    throw Exception('Usuario no encontrado');
  }

  // Método auxiliar para obtener usuario original de la API
  Future<User?> _getOriginalApiUser(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      // Ignorar errores de red
    }
    return null;
  }

  // Método auxiliar para comparar si hay cambios reales
  bool _hasRealChanges(User original, User updated) {
    return original.name.trim() != updated.name.trim() ||
        original.username.trim() != updated.username.trim() ||
        original.email.trim() != updated.email.trim() ||
        original.phone.trim() != updated.phone.trim() ||
        original.website.trim() != updated.website.trim() ||
        original.address.street.trim() != updated.address.street.trim() ||
        original.address.suite.trim() != updated.address.suite.trim() ||
        original.address.city.trim() != updated.address.city.trim() ||
        original.address.zipcode.trim() != updated.address.zipcode.trim() ||
        original.company.name.trim() != updated.company.name.trim() ||
        original.company.catchPhrase.trim() !=
            updated.company.catchPhrase.trim() ||
        original.company.bs.trim() != updated.company.bs.trim();
  }

  // Método para verificar si un usuario ha sido modificado localmente
  bool isUserModified(int id) {
    return _localUsers.any((u) => u.id == id && id < 100);
  }

  // DELETE - Eliminar usuario (mejorado)
  Future<void> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Eliminar todas las copias locales del usuario (tanto originales como modificadas)
    _localUsers.removeWhere((u) => u.id == id);

    // Si es un usuario de la API, marcarlo como eliminado
    if (id < 100) {
      // Verificar si ya está marcado como eliminado
      final alreadyDeleted = _localUsers.any((u) => u.id == -id);

      if (!alreadyDeleted) {
        // Marcar como eliminado agregándolo con ID negativo
        _localUsers.add(
          User(
            id: -id, // ID negativo para marcar como eliminado
            name: 'DELETED',
            username: 'DELETED',
            email: 'DELETED',
            phone: '',
            website: '',
            address: Address(street: '', suite: '', city: '', zipcode: ''),
            company: Company(name: '', catchPhrase: '', bs: ''),
          ),
        );
      }
    }
  }

  // PAPELERA - Obtener usuarios eliminados
  Future<List<User>> getDeletedUsers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_deletedUsers);
  }

  // RESTAURAR - Restaurar usuario de la papelera
  Future<void> restoreUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final deletedIndex = _deletedUsers.indexWhere((u) => u.id == id);
    if (deletedIndex != -1) {
      final userToRestore = _deletedUsers.removeAt(deletedIndex);

      // Si era un usuario local, restaurarlo a la lista local
      if (id >= 100) {
        _localUsers.add(userToRestore);
      } else {
        // Si era de la API, quitar el marcador de eliminado
        _localUsers.removeWhere((u) => u.id == -id);
      }
    }
  }

  // PAPELERA - Eliminar permanentemente
  Future<void> deletePermanently(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _deletedUsers.removeWhere((u) => u.id == id);
  }

  // PAPELERA - Vaciar papelera
  Future<void> emptyTrash() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _deletedUsers.clear();
  }

  // UTILIDAD - Crear usuarios fake para testing
  Future<List<User>> createFakeUsers() async {
    final fakeUsers = [
      User(
        id: 0,
        name: 'Ana García López',
        username: 'ana.garcia',
        email: 'ana.garcia@email.com',
        phone: '+1-555-123-4567',
        website: 'https://anagarcia.dev',
        address: Address(
          street: 'Av. Libertador 1234',
          suite: 'Apt 5B',
          city: 'Buenos Aires',
          zipcode: 'C1425',
        ),
        company: Company(
          name: 'Tech Solutions SA',
          catchPhrase: 'Innovación que transforma',
          bs: 'Desarrollo de software',
        ),
      ),
      User(
        id: 0,
        name: 'Carlos Mendoza',
        username: 'cmendoza',
        email: 'carlos@company.com',
        phone: '555-987-6543',
        website: 'www.carlosmendoza.com',
        address: Address(
          street: 'Calle Real 567',
          suite: 'Oficina 12',
          city: 'Madrid',
          zipcode: '28001',
        ),
        company: Company(
          name: 'Digital Marketing Pro',
          catchPhrase: 'Marketing del futuro',
          bs: 'Publicidad digital',
        ),
      ),
      User(
        id: 0,
        name: 'María Rodríguez',
        username: 'maria.r',
        email: 'maria.rodriguez@gmail.com',
        phone: '+34-600-123-456',
        website: 'mariadesign.com',
        address: Address(
          street: 'Plaza Mayor 12',
          suite: 'Local 3',
          city: 'Barcelona',
          zipcode: '08001',
        ),
        company: Company(
          name: 'Creative Studio',
          catchPhrase: 'Creatividad sin límites',
          bs: 'Diseño gráfico',
        ),
      ),
      User(
        id: 0,
        name: 'Diego Fernández',
        username: 'diego.dev',
        email: 'diego.fernandez@tech.com',
        phone: '+52-555-789-0123',
        website: 'diegodev.mx',
        address: Address(
          street: 'Insurgentes Sur 2000',
          suite: 'Torre A, Piso 15',
          city: 'Ciudad de México',
          zipcode: '03100',
        ),
        company: Company(
          name: 'DevMexico',
          catchPhrase: 'Código que inspira',
          bs: 'Desarrollo web y móvil',
        ),
      ),
      User(
        id: 0,
        name: 'Laura Sánchez',
        username: 'laura.data',
        email: 'laura.sanchez@analytics.com',
        phone: '+1-415-555-0199',
        website: 'lauradata.io',
        address: Address(
          street: 'Silicon Valley Blvd 500',
          suite: 'Building C',
          city: 'San Francisco',
          zipcode: '94105',
        ),
        company: Company(
          name: 'Data Analytics Inc',
          catchPhrase: 'Datos que hablan',
          bs: 'Análisis de datos',
        ),
      ),
    ];

    List<User> createdUsers = [];
    for (User user in fakeUsers) {
      try {
        final createdUser = await createUser(user);
        createdUsers.add(createdUser);
        // Pequeña pausa para no saturar la API
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print('Error creando usuario ${user.name}: $e');
      }
    }
    return createdUsers;
  }
}
