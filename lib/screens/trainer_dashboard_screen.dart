import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';
import '../services/email_service.dart';

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
            _buildPendingRequestsTab(),
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
            icon: Icon(Icons.pending_actions_outlined),
            activeIcon: Icon(Icons.pending_actions),
            label: 'בקשות',
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
        final user = userProvider.currentUser;
        
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: user != null ? UserService.getTrainerClients(user.uid) : Future.value([]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final clients = snapshot.data ?? [];
            
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
                  if (clients.isEmpty)
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
                    ...clients.map((client) => _buildRealClientCard(client)),
                ],
              ),
            );
          },
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

  Widget _buildPendingRequestsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: UserService.getPendingTrainerRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final pendingRequests = snapshot.data ?? [];
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.pending_actions, color: primaryPurple),
                  const SizedBox(width: 12),
                  const Text(
                    'בקשות להצטרפות כמאמנים',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkGray,
                    ),
                  ),
                  const Spacer(),
                  if (pendingRequests.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${pendingRequests.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              
              if (pendingRequests.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'אין בקשות ממתינות',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'כל בקשות ההצטרפות כמאמנים אושרו',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...pendingRequests.map((request) => _buildPendingRequestCard(request)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingRequestCard(Map<String, dynamic> request) {
    final trainerData = request['trainerData'] as Map<String, dynamic>? ?? {};
    final requestedAt = trainerData['requestedAt'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                child: Text(
                  '${request['firstName']?[0] ?? ''}${request['lastName']?[0] ?? ''}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
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
                      '${request['firstName'] ?? ''} ${request['lastName'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request['email'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'בקשה ממתינה',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Trainer details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'פרטי המאמן:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text('ניסיון: ${trainerData['experience'] ?? 3} שנים'),
                Text('התמחויות: ${(trainerData['specializations'] as List?)?.join(', ') ?? 'כוח, קרדיו, יוגה'}'),
                if (requestedAt != null)
                  Text('תאריך בקשה: ${_formatDate(requestedAt)}'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectTrainerRequest(request['uid']),
                  icon: const Icon(Icons.close),
                  label: const Text('דחה'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveTrainerRequest(request['uid']),
                  icon: const Icon(Icons.check),
                  label: const Text('אשר'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp == null) return 'לא ידוע';
      // Handle Firestore Timestamp
      DateTime date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'לא ידוע';
    }
  }

  Future<void> _approveTrainerRequest(String trainerUid) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    
    if (currentUser == null) return;
    
    bool success = await UserService.approveTrainer(trainerUid, currentUser.uid);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('המאמן אושר בהצלחה'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {}); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שגיאה באישור המאמן'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectTrainerRequest(String trainerUid) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    
    if (currentUser == null) return;
    
    // Show rejection reason dialog
    String? rejectionReason = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String reason = '';
        return AlertDialog(
          title: const Text('דחיית בקשה'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('אנא ציין את הסיבה לדחיית הבקשה:'),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => reason = value,
                decoration: const InputDecoration(
                  hintText: 'סיבת הדחייה...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(reason.isNotEmpty ? reason : 'לא צוינה סיבה'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('דחה'),
            ),
          ],
        );
      },
    );
    
    if (rejectionReason != null) {
      bool success = await UserService.rejectTrainer(trainerUid, currentUser.uid, rejectionReason);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('הבקשה נדחתה בהצלחה'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {}); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('שגיאה בדחיית הבקשה'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Widget _buildRealClientCard(Map<String, dynamic> client) {
    final clientData = client['clientData'] as Map<String, dynamic>? ?? {};
    final completedWorkouts = clientData['completedWorkouts'] ?? 0;
    final currentStreak = clientData['currentStreak'] ?? 0;
    final firstName = client['firstName'] ?? '';
    final lastName = client['lastName'] ?? '';
    final email = client['email'] ?? '';

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
              '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}',
              style: const TextStyle(
                color: primaryPurple,
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
                  '$firstName $lastName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$completedWorkouts אימונים',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '$currentStreak רצף',
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'remove') {
                _removeClient(client['uid']);
              } else if (value == 'invite') {
                _sendClientInvitation(client);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'invite',
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('שלח הזמנה'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.red),
                    SizedBox(width: 8),
                    Text('הסר מתאמן', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _removeClient(String clientUid) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user != null) {
      bool success = await UserService.removeClientFromTrainer(clientUid, user.uid);
      if (success) {
        userProvider.refreshUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('המתאמן הוסר בהצלחה'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('שגיאה בהסרת המתאמן'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendClientInvitation(Map<String, dynamic> client) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    
    if (user != null) {
      await _sendInvitationEmailToClient(client, user);
    }
  }

  Future<void> _sendInvitationEmailToClient(Map<String, dynamic> clientData, dynamic trainer) async {
    final clientEmail = clientData['email'] ?? '';
    final clientName = '${clientData['firstName'] ?? ''} ${clientData['lastName'] ?? ''}';
    final trainerName = '${trainer.firstName ?? ''} ${trainer.lastName ?? ''}';
    
    if (clientEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אין כתובת אימייל למתאמן זה'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create email content in Hebrew
    final subject = Uri.encodeComponent('הזמנה לאפליקציית TooFit - מהמאמן שלך $trainerName');
    final body = Uri.encodeComponent('''שלום $clientName,

מאמן הכושר שלך, $trainerName, הוסיף אותך לאפליקציית TooFit!

🏋️‍♂️ באפליקציה תוכל:
• לקבל תוכניות אימון מותאמות אישית
• לעקוב אחר ההתקדמות שלך
• לתאם עם המאמן שלך
• לקבל חיזוק ותמיכה

📱 להורדת האפליקציה:
• iOS: חפש "TooFit" ב-App Store
• Android: חפש "TooFit" ב-Google Play

💪 בוא נתחיל את מסע הכושר שלך היום!

בברכה,
צוות TooFit
''');

    final emailUrl = 'mailto:$clientEmail?subject=$subject&body=$body';
    
    try {
      final uri = Uri.parse(emailUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('הזמנה נשלחה ל$clientName'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Fallback: show email address
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('נא לשלוח הזמנה ידנית ל: $clientEmail'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שגיאה בשליחת הזמנה'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    showDialog(
      context: context,
      builder: (context) => AddClientDialog(
        onClientAdded: () {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.refreshUserData();
        },
      ),
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

class AddClientDialog extends StatefulWidget {
  final VoidCallback onClientAdded;

  const AddClientDialog({super.key, required this.onClientAdded});

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _unassignedClients = [];
  bool _isSearching = false;
  bool _isLoadingUnassigned = false;
  bool _isCreatingNewClient = false;
  
  // Form controllers for creating new client
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedFitnessLevel = 'beginner';
  bool _isCreatingClient = false;

  @override
  void initState() {
    super.initState();
    _loadUnassignedClients();
  }

  Future<void> _loadUnassignedClients() async {
    setState(() {
      _isLoadingUnassigned = true;
    });

    try {
      List<Map<String, dynamic>> clients = await UserService.getUnassignedClients();
      setState(() {
        _unassignedClients = clients;
      });
    } catch (e) {
      // Handle error
    }

    setState(() {
      _isLoadingUnassigned = false;
    });
  }

  Future<void> _searchClients(String email) async {
    if (email.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Map<String, dynamic>> results = await UserService.searchClientsByEmail(email);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      // Handle error
    }

    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'הוסף מתאמן',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Tab selector
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCreatingNewClient = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isCreatingNewClient ? Colors.purple : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'הוסף מתאמן קיים',
                          style: TextStyle(
                            color: !_isCreatingNewClient ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCreatingNewClient = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isCreatingNewClient ? Colors.purple : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'צור מתאמן חדש',
                          style: TextStyle(
                            color: _isCreatingNewClient ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: _isCreatingNewClient 
                  ? _buildCreateClientForm()
                  : Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'חפש מתאמן לפי אימייל',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: _searchClients,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _searchController.text.isNotEmpty
                              ? _buildSearchResults()
                              : _buildUnassignedClients(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('לא נמצאו מתאמנים'),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildClientListItem(_searchResults[index]);
      },
    );
  }

  Widget _buildUnassignedClients() {
    if (_isLoadingUnassigned) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_unassignedClients.isEmpty) {
      return const Center(
        child: Text('אין מתאמנים לא משויכים'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'מתאמנים ללא מאמן:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _unassignedClients.length,
            itemBuilder: (context, index) {
              return _buildClientListItem(_unassignedClients[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClientListItem(Map<String, dynamic> client) {
    final clientData = client['clientData'] as Map<String, dynamic>? ?? {};
    final hasTrainer = (clientData['trainerId'] ?? '').isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withValues(alpha: 0.1),
          child: Text(
            '${client['firstName']?[0] ?? ''}${client['lastName']?[0] ?? ''}',
            style: const TextStyle(color: Colors.purple),
          ),
        ),
        title: Text('${client['firstName'] ?? ''} ${client['lastName'] ?? ''}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client['email'] ?? ''),
            if (hasTrainer)
              const Text(
                'כבר משויך למאמן',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
          ],
        ),
        trailing: hasTrainer
            ? const Icon(Icons.check, color: Colors.orange)
            : ElevatedButton(
                onPressed: () => _addClient(client['uid']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('הוסף'),
              ),
      ),
    );
  }

  Future<void> _addClient(String clientUid) async {
    print('🔧 DEBUG: Starting _addClient for clientUid: $clientUid');
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    
    print('🔧 DEBUG: Current user: ${user?.uid}');

    if (user != null) {
      try {
        print('🔧 DEBUG: Calling UserService.assignClientToTrainer...');
        bool success = await UserService.assignClientToTrainer(clientUid, user.uid);
        print('🔧 DEBUG: assignClientToTrainer result: $success');
        
        if (success) {
          // Find the client data to get email
          final clientData = _searchResults.firstWhere(
            (client) => client['uid'] == clientUid,
            orElse: () => _unassignedClients.firstWhere(
              (client) => client['uid'] == clientUid,
              orElse: () => {},
            ),
          );
          
          print('🔧 DEBUG: Found client data: ${clientData['email']}');
          
          widget.onClientAdded();
          Navigator.of(context).pop();
          
          // Show success message with email option
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('המתאמן נוסף בהצלחה'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'שלח הזמנה',
                textColor: Colors.white,
                onPressed: () => _sendInvitationEmail(clientData, user),
              ),
            ),
          );
          
          // Auto-send invitation email with confirmation
          print('🔧 DEBUG: Sending invitation email...');
          _showEmailSendingDialog(clientData, user);
        } else {
          print('🔧 DEBUG: assignClientToTrainer failed');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('שגיאה בהוספת המתאמן'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('🔧 DEBUG: Exception in _addClient: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('🔧 DEBUG: No current user found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שגיאה: לא נמצא משתמש מחובר'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendInvitationEmail(Map<String, dynamic> clientData, dynamic trainer) async {
    final clientEmail = clientData['email'] ?? '';
    final clientName = '${clientData['firstName'] ?? ''} ${clientData['lastName'] ?? ''}';
    final trainerName = '${trainer.firstName ?? ''} ${trainer.lastName ?? ''}';
    
    if (clientEmail.isEmpty) {
      print('📧 DEBUG: No email address provided');
      return;
    }

    print('📧 DEBUG: Attempting to send email to: $clientEmail');
    
    // Check if email service is configured
    if (!EmailService.isConfigured()) {
      print('📧 DEBUG: Email service not configured, showing setup instructions');
      _showEmailSetupDialog();
      await _sendEmailViaMailto(clientEmail, clientName, trainerName);
      return;
    }
    
    // Try to send via API
    bool emailSent = await EmailService.sendInvitationEmail(
      toEmail: clientEmail,
      clientName: clientName,
      trainerName: trainerName,
    );
    
    if (emailSent) {
      print('📧 DEBUG: Email sent successfully via API');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('הזמנה נשלחה בהצלחה ל-$clientEmail'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print('📧 DEBUG: API email failed, falling back to mailto');
      await _sendEmailViaMailto(clientEmail, clientName, trainerName);
    }
  }
  
  Future<void> _sendEmailViaMailto(String clientEmail, String clientName, String trainerName) async {
    // Create email content in Hebrew
    final subject = Uri.encodeComponent('הזמנה לאפליקציית TooFit - מהמאמן שלך $trainerName');
    final body = Uri.encodeComponent('''שלום $clientName,

מאמן הכושר שלך, $trainerName, הוסיף אותך לאפליקציית TooFit!

🏋️‍♂️ באפליקציה תוכל:
• לקבל תוכניות אימון מותאמות אישית
• לעקוב אחר ההתקדמות שלך
• לתאם עם המאמן שלך
• לקבל חיזוק ותמיכה

📱 להורדת האפליקציה:
• iOS: חפש "TooFit" ב-App Store
• Android: חפש "TooFit" ב-Google Play

💪 בוא נתחיל את מסע הכושר שלך היום!

בברכה,
צוות TooFit
''');

    final emailUrl = 'mailto:$clientEmail?subject=$subject&body=$body';
    
    try {
      final uri = Uri.parse(emailUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('נפתח אפליקציית המייל עבור $clientEmail'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // Fallback: show email content
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('נא לשלוח הזמנה ידנית ל: $clientEmail'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשליחת הזמנה: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showEmailSetupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('הגדרת שליחת מיילים'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'שליחת המיילים אינה מוגדרת כעת.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('להפעלת שליחת מיילים אוטומטית:'),
                const SizedBox(height: 8),
                Text(
                  EmailService.getSetupInstructions(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('הבנתי'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                print('📧 SETUP INSTRUCTIONS:\n${EmailService.getSetupInstructions()}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('הוראות ההגדרה הודפסו ביומן הדיבאג'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('הצג הוראות'),
            ),
          ],
        );
      },
    );
  }

  void _showEmailSendingDialog(Map<String, dynamic> clientData, dynamic trainer) {
    final clientEmail = clientData['email'] ?? '';
    final clientName = '${clientData['firstName'] ?? ''} ${clientData['lastName'] ?? ''}';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.email, color: Colors.blue),
              SizedBox(width: 8),
              Text('שליחת הזמנה'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('שולח הזמנה ל-$clientName'),
              Text('כתובת: $clientEmail'),
              const SizedBox(height: 16),
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('שולח מייל...'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📧 המייל יכלול:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• פרטי הזמנה לאפליקציה'),
                    Text('• קישורי הורדה'),
                    Text('• הוראות התחברות'),
                    Text('• פרטי המאמן'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'ממתין לאישור מהמתאמן...',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );

    // Send email and close dialog
    _sendInvitationEmailWithCallback(clientData, trainer).then((success) {
      Navigator.of(context).pop(); // Close sending dialog
      
      if (success) {
        _showEmailSentSuccessDialog(clientName, clientEmail);
      } else {
        _showEmailFailedDialog(clientName, clientEmail, trainer);
      }
    });
  }

  void _showEmailSentSuccessDialog(String clientName, String clientEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('הזמנה נשלחה בהצלחה!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('המייל נשלח ל-$clientName'),
              Text('כתובת: $clientEmail'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ מה הלאה?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. המתאמן יקבל מייל עם הוראות'),
                    Text('2. יוריד את האפליקציה'),
                    Text('3. יתחבר עם הפרטים שיצרת'),
                    Text('4. יופיע ברשימת המתאמנים שלך'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('מעולה!'),
            ),
          ],
        );
      },
    );
  }

  void _showEmailFailedDialog(String clientName, String clientEmail, dynamic trainer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('שגיאה בשליחת מייל'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('לא הצלחנו לשלוח מייל ל-$clientName'),
              Text('כתובת: $clientEmail'),
              const SizedBox(height: 16),
              const Text('אבל אל תדאג! המתאמן נוצר בהצלחה.'),
              const SizedBox(height: 8),
              const Text('תוכל לשלוח לו ידנית את פרטי ההתחברות:'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('סגור'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendEmailViaMailto(clientEmail, clientName, '${trainer.firstName} ${trainer.lastName}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('פתח מייל'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _sendInvitationEmailWithCallback(Map<String, dynamic> clientData, dynamic trainer) async {
    final clientEmail = clientData['email'] ?? '';
    final clientName = '${clientData['firstName'] ?? ''} ${clientData['lastName'] ?? ''}';
    final trainerName = '${trainer.firstName ?? ''} ${trainer.lastName ?? ''}';
    
    if (clientEmail.isEmpty) {
      return false;
    }

    // Check if email service is configured
    if (!EmailService.isConfigured()) {
      return false;
    }
    
    // Try to send via API
    return await EmailService.sendInvitationEmail(
      toEmail: clientEmail,
      clientName: clientName,
      trainerName: trainerName,
    );
  }

  Widget _buildCreateClientForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'פרטי המתאמן החדש:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Name fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'שם פרטי',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'נא להזין שם פרטי';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'שם משפחה',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'נא להזין שם משפחה';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'אימייל',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'נא להזין אימייל';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'נא להזין אימייל תקין';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'סיסמה',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'נא להזין סיסמה';
                }
                if (value.length < 6) {
                  return 'הסיסמה חייבת להכיל לפחות 6 תווים';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Physical details
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'גיל',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final age = int.tryParse(value);
                        if (age == null || age < 13 || age > 100) {
                          return 'גיל לא תקין';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'גובה (ס"מ)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final height = int.tryParse(value);
                        if (height == null || height < 100 || height > 250) {
                          return 'גובה לא תקין';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'משקל (ק"ג)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final weight = int.tryParse(value);
                        if (weight == null || weight < 30 || weight > 300) {
                          return 'משקל לא תקין';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Fitness level dropdown
            DropdownButtonFormField<String>(
              value: _selectedFitnessLevel,
              decoration: InputDecoration(
                labelText: 'רמת כושר',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'beginner', child: Text('מתחיל')),
                DropdownMenuItem(value: 'intermediate', child: Text('בינוני')),
                DropdownMenuItem(value: 'advanced', child: Text('מתקדם')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFitnessLevel = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreatingClient ? null : _createNewClient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreatingClient
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'צור מתאמן והוסף לרשימה שלי',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _createNewClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isCreatingClient = true;
    });
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final trainer = userProvider.currentUser;
      
      if (trainer == null) {
        throw Exception('לא נמצא משתמש מחובר');
      }
      
      print('🔧 DEBUG: Creating new client with email: ${_emailController.text}');
      
      // Create the new client
      Map<String, dynamic> newClientData = await UserService.createNewClient(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 0,
        height: int.tryParse(_heightController.text) ?? 0,
        weight: int.tryParse(_weightController.text) ?? 0,
        fitnessLevel: _selectedFitnessLevel,
        trainerUid: trainer.uid,
      );
      
      print('🔧 DEBUG: Client created successfully: ${newClientData['uid']}');
      
      // Clear form
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _ageController.clear();
      _heightController.clear();
      _weightController.clear();
      _selectedFitnessLevel = 'beginner';
      
      widget.onClientAdded();
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('המתאמן ${newClientData['firstName']} ${newClientData['lastName']} נוצר בהצלחה'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'שלח הזמנה',
            textColor: Colors.white,
            onPressed: () => _sendInvitationEmail(newClientData, trainer),
          ),
        ),
      );
      
      // Auto-send invitation email with confirmation
      _showEmailSendingDialog(newClientData, trainer);
      
    } catch (e) {
      print('🔧 DEBUG: Error creating client: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה ביצירת המתאמן: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() {
      _isCreatingClient = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
