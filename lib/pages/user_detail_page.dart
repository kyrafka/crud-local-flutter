import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserDetailPage extends StatelessWidget {
  final int userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ApiService api = ApiService();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Detalle de Usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: FutureBuilder<User>(
        future: api.fetchUserById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Hero
                Center(
                  child: Hero(
                    tag: 'user_avatar_${user.id}',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: user.id >= 100
                              ? [Colors.green.shade400, Colors.teal.shade400]
                              : [Colors.blue.shade400, Colors.purple.shade400],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (user.id >= 100 ? Colors.green : Colors.blue)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Información personal
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Información Personal',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.person, 'Nombre', user.name),
                        _buildInfoRow(
                          Icons.alternate_email,
                          'Usuario',
                          user.username,
                        ),
                        _buildInfoRow(Icons.email, 'Email', user.email),
                        _buildInfoRow(Icons.phone, 'Teléfono', user.phone),
                        _buildInfoRow(Icons.web, 'Sitio web', user.website),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dirección
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.orange.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Dirección',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.home, 'Calle', user.address.street),
                        _buildInfoRow(
                          Icons.apartment,
                          'Suite',
                          user.address.suite,
                        ),
                        _buildInfoRow(
                          Icons.location_city,
                          'Ciudad',
                          user.address.city,
                        ),
                        _buildInfoRow(
                          Icons.local_post_office,
                          'Código postal',
                          user.address.zipcode,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Empresa
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.business, color: Colors.green.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Empresa',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.business,
                          'Nombre',
                          user.company.name,
                        ),
                        _buildInfoRow(
                          Icons.campaign,
                          'Eslogan',
                          user.company.catchPhrase,
                        ),
                        _buildInfoRow(Icons.work, 'Negocio', user.company.bs),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'No especificado' : value,
                  style: TextStyle(
                    fontSize: 14,
                    color: value.isEmpty ? Colors.grey : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
