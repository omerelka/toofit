import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';

class TrainerDashboardScreen
    extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen>
  createState() =>
      _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState
    extends State<TrainerDashboardScreen> {
  int _selectedIndex = 0;
  bool _workoutsLoadAttempted = false;

  // צבעים
  static const Color primaryPurple = Color(
    0xFF714bf2,
  );
  static const Color primaryNeon = Color(
    0xFFf3ff00,
  );
  static const Color lightGray = Color(
    0xFFF5F5F5,
  );
  static const Color darkGray = Color(
    0xFF333333,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildClientsTab(),
            _buildWorkoutsTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.1,
            ),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryPurple,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'בית',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'מתאמנים',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.fitness_center_outlined,
            ),
            activeIcon: Icon(
              Icons.fitness_center,
            ),
            label: 'אימונים',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'פרופיל',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user =
            userProvider.currentUser;
        final trainerData =
            userProvider.trainerData;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(
                user?.firstName ?? 'מאמן',
              ),
              const SizedBox(height: 24),
              _buildStatsCards(trainerData),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
              const SizedBox(height: 24),
              _buildUpcomingWorkouts(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(String firstName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            primaryPurple,
            primaryPurple.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'שלום $firstName! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'בוא נעזור למתאמנים שלך להגשים את החלומות שלהם',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.fitness_center,
              color: primaryPurple,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
    Map<String, dynamic>? trainerData,
  ) {
    final totalClients =
        trainerData?['totalClients'] ?? 0;
    final rating =
        trainerData?['rating']?.toDouble() ??
        5.0;
    final workoutsCreated =
        trainerData?['workouts']?.length ??
        0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'מתאמנים',
            value: totalClients.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'דירוג',
            value: rating.toStringAsFixed(1),
            icon: Icons.star,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'אימונים',
            value: workoutsCreated
                .toString(),
            icon: Icons.fitness_center,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'פעולות מהירות',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'צור אימון חדש',
                subtitle: 'בנה אימון מותאם',
                icon: Icons.add_circle,
                color: primaryPurple,
                onTap: () {
                  // Navigate to workout builder
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'בניית אימון חדש - בקרוב',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'הוסף מתאמן',
                subtitle: 'הזמן מתאמן חדש',
                icon: Icons.person_add,
                color: Colors.green,
                onTap: () {
                  // Navigate to add client
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'הוספת מתאמן - בקרוב',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'פעילות אחרונה',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius:
                BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.timeline,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'אין פעילות אחרונה',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'פעילות המתאמנים שלך תופיע כאן',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingWorkouts() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'אימונים מתוכננים',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius:
                BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.calendar_today,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'אין אימונים מתוכננים',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'צור אימונים חדשים עבור המתאמנים שלך',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientsTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final trainerData = userProvider.trainerData;
        final clientIds = trainerData?['clientIds'] as List<dynamic>? ?? _getMockClientIds();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'המתאמנים שלי',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkGray,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddClientDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('הוסף מתאמן'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (clientIds.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'אין מתאמנים עדיין',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'הוסף מתאמנים חדשים כדי להתחיל',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _showAddClientDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('הוסף מתאמן ראשון'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...clientIds.map((clientId) => _buildClientCard(clientId.toString())),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutsTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final trainerData = userProvider.trainerData;
        final workouts = trainerData?['workouts'] as List<dynamic>? ?? [];
        
        // Auto-load workouts if list is empty and we haven't tried loading yet
        if (workouts.isEmpty && !_workoutsLoadAttempted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadSharedWorkouts();
          });
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'תוכניות האימון שלי',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkGray,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateWorkoutDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('צור אימון'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (workouts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.fitness_center_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'אין תוכניות אימון עדיין',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'טען אימונים מוכנים או צור תוכניות אימון חדשות',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _loadSharedWorkouts(),
                            icon: const Icon(Icons.download),
                            label: const Text('טען אימונים'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateWorkoutDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('צור אימון'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                ...workouts.map((workout) => _buildWorkoutCard(workout as Map<String, dynamic>)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user =
            userProvider.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor:
                    primaryPurple
                        .withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: primaryPurple,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user?.fullName ?? 'משתמש',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              _buildProfileOption(
                icon: Icons.settings,
                title: 'הגדרות',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'עזרה ותמיכה',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.info_outline,
                title: 'אודות',
                onTap: () {},
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Provider.of<
                          AuthProvider
                        >(
                          context,
                          listen: false,
                        )
                        .signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                    ),
                  ),
                  child: const Text(
                    'התנתק',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: primaryPurple,
      ),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
    );
  }

  Widget _buildClientCard(String clientId) {
    final clientData = _getPlaceholderClientData(clientId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: primaryPurple.withValues(alpha: 0.1),
            child: Text(
              clientData['initials'],
              style: const TextStyle(
                color: primaryPurple,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientData['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      clientData['isActive'] ? Icons.circle : Icons.circle_outlined,
                      size: 8,
                      color: clientData['isActive'] ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      clientData['status'],
                      style: TextStyle(
                        fontSize: 12,
                        color: clientData['isActive'] ? Colors.green[600] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${clientData['completedWorkouts']} אימונים השלים',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showClientDetails(context, clientId),
                    icon: const Icon(
                      Icons.visibility,
                      color: primaryPurple,
                      size: 20,
                    ),
                    tooltip: 'צפה בפרטים',
                  ),
                  IconButton(
                    onPressed: () => _showEditClientDialog(context, clientId),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.orange,
                      size: 20,
                    ),
                    tooltip: 'ערוך פרטים',
                  ),
                  IconButton(
                    onPressed: () => _showAssignWorkoutDialog(context, clientId),
                    icon: const Icon(
                      Icons.fitness_center,
                      color: Colors.green,
                      size: 20,
                    ),
                    tooltip: 'הקצה אימון',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _getMockClientIds() {
    return [
      'client_001_elia',
      'client_002_yossi',
      'client_003_michal',
      'client_004_danny',
      'client_005_sarah',
    ];
  }

  Map<String, dynamic> _getPlaceholderClientData(String clientId) {
    final names = ['אליה כהן', 'יוסי לוי', 'מיכל אברהם', 'דני בן דוד', 'שרה מלכה'];
    final random = clientId.hashCode % names.length;
    final name = names[random];
    final initials = name.split(' ').map((word) => word[0]).join('');
    final isActive = clientId.hashCode % 3 != 0;
    final completedWorkouts = 3 + (clientId.hashCode % 15);
    
    return {
      'name': name,
      'initials': initials,
      'isActive': isActive,
      'status': isActive ? 'פעיל השבוע' : 'לא פעיל',
      'completedWorkouts': completedWorkouts,
    };
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout['name'] ?? 'אימון חדש',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout['duration'] ?? '30'} דקות • ${workout['exercises']?.length ?? 0} תרגילים',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('ערוך'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('מחק', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('עריכת אימון - בקרוב')),
                    );
                  } else if (value == 'delete') {
                    _deleteWorkout(workout);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (workout['description'] != null && workout['description'].isNotEmpty)
            Text(
              workout['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController heightController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    String selectedFitnessLevel = 'beginner';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('הוספת מתאמן חדש'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'אימייל המתאמן',
                        hintText: 'example@email.com',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'שם מלא',
                        hintText: 'דוגמה: אליה כהן',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            decoration: const InputDecoration(
                              labelText: 'גיל',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            decoration: const InputDecoration(
                              labelText: 'גובה (cm)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            decoration: const InputDecoration(
                              labelText: 'משקל (kg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedFitnessLevel,
                      decoration: const InputDecoration(
                        labelText: 'רמת כושר',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'beginner', child: Text('מתחיל')),
                        DropdownMenuItem(value: 'intermediate', child: Text('בינוני')),
                        DropdownMenuItem(value: 'advanced', child: Text('מתקדם')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFitnessLevel = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'המתאמן יקבל הזמנה לאפליקציה',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ביטול'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (emailController.text.isNotEmpty && nameController.text.isNotEmpty) {
                      _addClientWithDetails({
                        'email': emailController.text,
                        'name': nameController.text,
                        'age': ageController.text,
                        'height': heightController.text,
                        'weight': weightController.text,
                        'fitnessLevel': selectedFitnessLevel,
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('הוסף'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateWorkoutDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('יצירת אימון חדש'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'שם האימון',
                    hintText: 'לדוגמה: אימון כוח עליון',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'תיאור (אופציונלי)',
                    hintText: 'תיאור קצר של האימון',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'משך זמן (דקות)',
                    hintText: '30',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _createWorkout(
                    nameController.text,
                    descriptionController.text,
                    int.tryParse(durationController.text) ?? 30,
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('צור'),
            ),
          ],
        );
      },
    );
  }

  void _addClient(String email) {
    print('🔧 Adding client with email: $email');
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('הזמנה נשלחה ל-$email'),
        backgroundColor: Colors.green,
      ),
    );
    
    // TODO: Implement actual client invitation logic
    // This would typically involve:
    // 1. Sending an invitation email
    // 2. Creating a pending invitation record
    // 3. Updating the trainer's client list when accepted
  }

  void _createWorkout(String name, String description, int duration) {
    print('🔧 Creating workout: $name, duration: $duration minutes');
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('אימון "$name" נוצר בהצלחה'),
        backgroundColor: Colors.green,
      ),
    );
    
    // TODO: Implement actual workout creation logic
    // This would typically involve:
    // 1. Creating a workout document in Firestore
    // 2. Adding it to the trainer's workout list
    // 3. Updating the UI to show the new workout
  }

  void _deleteWorkout(Map<String, dynamic> workout) {
    print('🔧 Deleting workout: ${workout['name']}');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('מחיקת אימון'),
          content: Text('האם אתה בטוח שברצונך למחוק את האימון "${workout['name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('האימון נמחק בהצלחה'),
                    backgroundColor: Colors.red,
                  ),
                );
                // TODO: Implement actual workout deletion logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('מחק'),
            ),
          ],
        );
      },
    );
  }

  void _showClientDetails(BuildContext context, String clientId) {
    final clientData = _getPlaceholderClientData(clientId);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('פרטי ${clientData['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('מזהה:', clientId.substring(0, 8)),
                _buildDetailRow('מספר אימונים שהושלמו:', '${clientData['completedWorkouts']}'),
                _buildDetailRow('סטטוס:', clientData['status']),
                _buildDetailRow('גיל:', '${25 + (clientId.hashCode % 20)}'),
                _buildDetailRow('גובה:', '${165 + (clientId.hashCode % 25)} ס"מ'),
                _buildDetailRow('משקל:', '${60 + (clientId.hashCode % 40)} ק"ג'),
                _buildDetailRow('רמת כושר:', clientId.hashCode % 3 == 0 ? 'מתחיל' : clientId.hashCode % 3 == 1 ? 'בינוני' : 'מתקדם'),
                const SizedBox(height: 16),
                const Text('אימונים שהוקצו:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildAssignedWorkoutsList(clientId),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('סגור'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditClientDialog(context, clientId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('עריכה'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedWorkoutsList(String clientId) {
    final workouts = ['אימון כוח עליון', 'קרדיו בסיסי', 'אימון פונקציונלי'];
    return Column(
      children: workouts.map((workout) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.fitness_center, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(workout, style: const TextStyle(fontSize: 14))),
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
      )).toList(),
    );
  }

  void _showEditClientDialog(BuildContext context, String clientId) {
    final clientData = _getPlaceholderClientData(clientId);
    final TextEditingController nameController = TextEditingController(text: clientData['name']);
    final TextEditingController ageController = TextEditingController(text: '${25 + (clientId.hashCode % 20)}');
    final TextEditingController heightController = TextEditingController(text: '${165 + (clientId.hashCode % 25)}');
    final TextEditingController weightController = TextEditingController(text: '${60 + (clientId.hashCode % 40)}');
    String selectedFitnessLevel = clientId.hashCode % 3 == 0 ? 'beginner' : clientId.hashCode % 3 == 1 ? 'intermediate' : 'advanced';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('עריכת פרטי ${clientData['name']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'שם מלא',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            decoration: const InputDecoration(
                              labelText: 'גיל',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            decoration: const InputDecoration(
                              labelText: 'גובה (cm)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            decoration: const InputDecoration(
                              labelText: 'משקל (kg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedFitnessLevel,
                      decoration: const InputDecoration(
                        labelText: 'רמת כושר',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'beginner', child: Text('מתחיל')),
                        DropdownMenuItem(value: 'intermediate', child: Text('בינוני')),
                        DropdownMenuItem(value: 'advanced', child: Text('מתקדם')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFitnessLevel = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ביטול'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('פרטי המתאמן עודכנו בהצלחה'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // TODO: Implement actual client update logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('שמור'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAssignWorkoutDialog(BuildContext context, String clientId) {
    final clientData = _getPlaceholderClientData(clientId);
    final availableWorkouts = [
      {'name': 'אימון כוח עליון', 'duration': '45 דקות', 'difficulty': 'בינוני'},
      {'name': 'קרדיו בסיסי', 'duration': '30 דקות', 'difficulty': 'קל'},
      {'name': 'אימון פונקציונלי', 'duration': '60 דקות', 'difficulty': 'מתקדם'},
      {'name': 'אימון רגליים', 'duration': '50 דקות', 'difficulty': 'קשה'},
      {'name': 'יוגה למתחילים', 'duration': '40 דקות', 'difficulty': 'קל'},
    ];
    String? selectedWorkout;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('הקצאת אימון ל${clientData['name']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('בחר אימון להקצאה:'),
                    const SizedBox(height: 16),
                    ...availableWorkouts.map((workout) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedWorkout == workout['name'] ? primaryPurple : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Radio<String>(
                          value: workout['name']!,
                          groupValue: selectedWorkout,
                          onChanged: (value) {
                            setState(() {
                              selectedWorkout = value;
                            });
                          },
                        ),
                        title: Text(workout['name']!),
                        subtitle: Text('${workout['duration']} • ${workout['difficulty']}'),
                        onTap: () {
                          setState(() {
                            selectedWorkout = workout['name'];
                          });
                        },
                      ),
                    )).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ביטול'),
                ),
                ElevatedButton(
                  onPressed: selectedWorkout != null ? () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('האימון "$selectedWorkout" הוקצה ל${clientData['name']}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // TODO: Implement actual workout assignment logic
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('הקצה'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addClientWithDetails(Map<String, dynamic> clientData) {
    print('🔧 Adding client: ${clientData['name']}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('מתאמן ${clientData['name']} נוסף בהצלחה'),
        backgroundColor: Colors.green,
      ),
    );
    
    // TODO: Implement actual client addition logic
    // This would typically involve:
    // 1. Creating a client document in Firestore
    // 2. Sending an invitation email
    // 3. Adding the client ID to the trainer's client list
    // 4. Updating the UI to show the new client
  }

  void _loadSharedWorkouts() async {
    try {
      print('🔧 Loading shared workouts...');
      
      // Mark that we've attempted to load workouts to prevent infinite loops
      setState(() {
        _workoutsLoadAttempted = true;
      });
      
      // Check if widget is still mounted before showing snackbar
      if (!mounted) return;
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('טוען אימונים מוכנים...'),
          backgroundColor: Colors.blue,
        ),
      );
      
      // Initialize shared workouts database
      await UserService.initializeSharedWorkoutsForAllTrainers();
      
      // Check if widget is still mounted before proceeding
      if (!mounted) return;
      
      // Refresh user data to show the new workouts
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUserData();
      
      // Check if widget is still mounted before showing success message
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 5 אימונים בעברית נטענו בהצלחה!'),
          backgroundColor: Colors.green,
        ),
      );
      
      print('✅ Shared workouts loaded successfully');
    } catch (e) {
      print('❌ Error loading shared workouts: $e');
      
      // Check if widget is still mounted before showing error message
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ שגיאה בטעינת האימונים'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
