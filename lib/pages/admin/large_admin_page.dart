import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/entities/admin_entity.dart';
import 'package:icmc_dorm/entities/record_entity.dart';
import 'package:icmc_dorm/states/user_state.dart';
import 'package:icmc_dorm/widgets/loading_widget_large.dart';
import 'package:icmc_dorm/widgets/ui_color.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LargeAdminPage extends StatefulWidget {
  const LargeAdminPage({super.key});

  @override
  State<LargeAdminPage> createState() => _LargeAdminPageState();
}

class _LargeAdminPageState extends State<LargeAdminPage> {
  String _filterType = 'Day';
  DateTime _selectedDate = DateTime.now();
  final List<RecordEntity> _fetchedRecords = [];

  final List<String> _filterOptions = ['Day', 'Month', 'Year'];

  Query<Map<String, dynamic>> _buildQuery() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions'); // Changed collection name

    if (_filterType == 'Day') {
      query = query
          .where('year', isEqualTo: _selectedDate.year)
          .where('month', isEqualTo: _selectedDate.month)
          .where('day', isEqualTo: _selectedDate.day);
    } else if (_filterType == 'Month') {
      query = query
          .where('year', isEqualTo: _selectedDate.year)
          .where('month', isEqualTo: _selectedDate.month);
    } else if (_filterType == 'Year') {
      query = query.where('year', isEqualTo: _selectedDate.year);
    }
    return query;
  }

  Future<void> _selectDate(BuildContext context) async {
    ThemeData theme = Theme.of(context);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: theme.cardTheme.color,
              headerForegroundColor: theme.primaryColor,
              dayForegroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.cardTheme.color,
                ~WidgetState.disabled: theme.primaryColor,
              }),
              dayBackgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.primaryColor,
              }),
              dayOverlayColor: WidgetStatePropertyAll(theme.primaryColor),
              todayBackgroundColor: WidgetStatePropertyAll(theme.cardTheme.color),
              todayForegroundColor: WidgetStatePropertyAll(theme.primaryColor),
              surfaceTintColor: theme.primaryColor,
              yearForegroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.cardTheme.color,
                ~WidgetState.disabled: theme.primaryColor,
              }),
              yearBackgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                WidgetState.selected: theme.primaryColor,
              }),
              yearOverlayColor: WidgetStatePropertyAll(theme.primaryColor),
              yearStyle: TextStyle(color: theme.primaryColor),
              weekdayStyle: TextStyle(color: theme.primaryColor),
              dayStyle: TextStyle(color: theme.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              cancelButtonStyle: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(UIColor().primaryRed),
              ),
              inputDecorationTheme: theme.inputDecorationTheme,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildDatePickerButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: ElevatedButton(
          style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(12))),
          onPressed: () => _selectDate(context),
          child: Text(
            DateFormat(
              _filterType == 'Day'
                  ? 'yyyy-MM-dd'
                  : _filterType == 'Month'
                  ? 'yyyy-MM'
                  : 'yyyy',
            ).format(_selectedDate),
            style: TextStyle(color: UIColor().darkGray, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Future<AdminEntity> getAdminList() async {
    QuerySnapshot<Map<String, dynamic>> docs =
        await FirebaseFirestore.instance.collection("admin").get();

    return AdminEntity.fromMap(docs.docs.first.data());
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getAdminList(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
              return LoadingWidgetLarge();
            }

            if (snapshot.data!.admins.contains(userState.userEntity.id)) {
              return StreamBuilder(
                stream: _buildQuery().snapshots(),
                builder: (context, snapshot) {
                  return Consumer2(
                    builder: (context, value, value2, child) {
                      return const Placeholder();
                    },
                  );
                },
              );
            }

            return Center(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height/2.1,
                  ),
                  Text("This account doesn't have admin access 👾")
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
