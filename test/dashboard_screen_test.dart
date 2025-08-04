import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transit/services/admin_user_service.dart';
import 'package:transit/screens/dashboard_screen.dart';
import 'package:transit/models/user.dart';
import 'package:transit/screens/admin_user_management_screen.dart';

class MockAdminUserService implements AdminUserService {
  @override
  Future<List<User>> fetchUsers() async {
    return <User>[];
  }

  @override
  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    return {'success': true, 'message': 'User updated successfully'};
  }
}

void main() {
  late AdminUserService mockAdminUserService;
  final adminUser = User(
    id: 1,
    fullName: 'Admin User',
    username: 'admin',
    email: 'admin@example.com',
    role: 'admin',
  );

  setUp(() {
    mockAdminUserService = MockAdminUserService();
    AdminUserService.instance = mockAdminUserService;
  });

  testWidgets('Admin user navigates to AdminUserManagementScreen', (WidgetTester tester) async {
    // Pump the app with mock service
    await tester.pumpWidget(MaterialApp(
      home: DashboardScreen(user: adminUser),
      navigatorObservers: [MockNavigatorObserver()],
    ));
    await tester.pumpAndSettle();

    // Scroll to bring "Manage Users" button into view
    final scrollableFinder = find.byType(SingleChildScrollView);
    await tester.dragFrom(tester.getCenter(scrollableFinder), Offset(0, -200));
    await tester.pumpAndSettle();

    // Find and tap the "Manage Users" button
    final manageUsersButtonFinder = find.byIcon(Icons.person_search);
    await tester.tap(manageUsersButtonFinder);
    await tester.pumpAndSettle();

    // Verify navigation
    expect(find.byType(AdminUserManagementScreen), findsOneWidget);
  });
}

class MockNavigatorObserver extends NavigatorObserver {
  final List<Route> pushedRoutes = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    pushedRoutes.add(route);
  }
}
