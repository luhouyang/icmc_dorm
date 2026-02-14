import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/entities/record_entity.dart';
import 'package:icmc_dorm/entities/room_entity.dart';
import 'package:icmc_dorm/entities/user_entity.dart';
import 'package:icmc_dorm/services/firestore_service/firestore_service.dart';
import 'package:icmc_dorm/states/app_state.dart';
import 'package:icmc_dorm/states/user_state.dart';
import 'package:icmc_dorm/widgets/h1_text.dart';
import 'package:icmc_dorm/widgets/h2_text.dart';
import 'package:icmc_dorm/widgets/loading_widget.dart';
import 'package:icmc_dorm/widgets/loading_widget_large.dart';
import 'package:icmc_dorm/widgets/record_card.dart';
import 'package:icmc_dorm/widgets/snack_bar_text.dart';
import 'package:icmc_dorm/widgets/ui_color.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SmallHomePage extends StatefulWidget {
  const SmallHomePage({super.key});

  @override
  State<SmallHomePage> createState() => _SmallHomePageState();
}

class _SmallHomePageState extends State<SmallHomePage> {
  SnackBarText snackBarText = SnackBarText();

  final GlobalKey<FormState> _recordForm = GlobalKey<FormState>();

  // Form State Variables
  DateTime _selectedEntryDate = DateTime.now();
  DateTime _selectedExitDate = DateTime.now();
  RoomEntity? _selectedRoom;
  String? _editingRecordId;

  // New State Variables for Friend Selection
  bool _isSharedRecord = false;
  UserEntity? _selectedFriend;
  List<UserEntity> _availableFriends = [];

  late Future<QuerySnapshot<Map<String, dynamic>>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = FirebaseFirestore.instance.collection("rooms").get();
    _fetchFriends();
  }

  // Fetch users and filter those with incomplete profiles
  Future<void> _fetchFriends() async {
    final currentUid = Provider.of<UserState>(context, listen: false).userEntity.id;
    final querySnapshot = await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      _availableFriends =
          querySnapshot.docs
              .map((doc) => UserEntity.fromMap(doc.data()))
              .where(
                (user) =>
                    user.id != currentUid &&
                    user.name != 'username' && // Filter out default name
                    user.contact != 'NA',
              ) // Filter out incomplete contact
              .toList();
    });
  }

  void _loadRecordForEdit(RecordEntity record, List<RoomEntity> roomsList) {
    setState(() {
      final currentUid = Provider.of<UserState>(context, listen: false).userEntity.id;
      _editingRecordId = record.id;
      _selectedEntryDate = record.checkinTime.toDate();
      _selectedExitDate = record.checkoutTime.toDate();
      _selectedRoom = roomsList.firstWhere((r) => r.id == record.roomId);

      // Determine if shared and find the friend in the uid list
      final friendId = record.uid.firstWhere((id) => id != currentUid, orElse: () => null);
      if (friendId != null) {
        _isSharedRecord = true;
        _selectedFriend = _availableFriends.firstWhere(
          (u) => u.id == friendId,
          orElse: () => UserEntity(id: 'NO_ID', name: 'NO_NAME', gender: '男生', contact: 'NA'),
        );
      } else {
        _isSharedRecord = false;
        _selectedFriend = null;
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Record loaded into form for editing")));
  }

  void _resetForm() {
    setState(() {
      _editingRecordId = null;
      _selectedEntryDate = DateTime.now();
      _selectedExitDate = DateTime.now();
      _isSharedRecord = false;
      _selectedFriend = null;
    });
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    ThemeData theme = Theme.of(context);
    
    // 1. Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: theme.cardTheme.color,
              headerForegroundColor: theme.primaryColor,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return theme.cardTheme.color;
                return theme.primaryColor;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return theme.primaryColor;
                return null;
              }),
              todayForegroundColor: WidgetStatePropertyAll(theme.primaryColor),
              todayBackgroundColor: WidgetStatePropertyAll(UIColor().transparentPrimaryOrange),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(UIColor().white),
              ),
              confirmButtonStyle: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(UIColor().primaryBlue),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate == null || !context.mounted) return;

    // 2. Pick Time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: UIColor().lightGray,
              hourMinuteColor: UIColor().transparentPrimaryOrange,
              hourMinuteTextColor: UIColor().primaryDarkRed,
              dayPeriodColor: UIColor().transparentPrimaryBlue,
              dayPeriodTextColor: UIColor().primaryBlue,
              dialHandColor: UIColor().primaryBlue,
              dialBackgroundColor: UIColor().white,
              entryModeIconColor: UIColor().primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(UIColor().primaryBlue),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // 3. Combine
    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() => onDateSelected(finalDateTime));
  }

  Widget _buildDatePickerButton({required DateTime date, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: Colors.grey.shade400),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(date),
              style: TextStyle(color: UIColor().darkGray, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.calendar_today, size: 18, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: false);
    AppState appState = Provider.of<AppState>(context, listen: false);

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _roomsFuture,
      builder: (context, roomSnapshot) {
        if (roomSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidgetLarge();
        }

        List<RoomEntity> roomsList =
            roomSnapshot.data!.docs.map((e) => RoomEntity.fromMap(e.data())).toList();

        if (_selectedRoom == null && roomsList.isNotEmpty) {
          _selectedRoom = roomsList.first;
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userState.userEntity.name == "username" ||
                      userState.userEntity.gender == "NA" ||
                      userState.userEntity.contact == "NA")
                    Container(
                      decoration: BoxDecoration(
                        color: UIColor().transparentPrimaryOrange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 375,
                      height: 105,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome to the family", style: TextStyle(fontSize: 20)),
                          SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Introduce yourself", style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              ElevatedButton(
                                onPressed: () => appState.setBottomNavIndex(1),
                                child: Text("here", style: TextStyle(fontSize: 14)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Center(child: H1Text(text: "New Record")),
                  const SizedBox(height: 16),
                  (userState.userEntity.name == "username" ||
                          userState.userEntity.gender == "NA" ||
                          userState.userEntity.contact == "NA")
                      ? Text("Please complete profile")
                      : Form(
                        key: _recordForm,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const H2Text(text: "Room"),
                            const SizedBox(height: 8),
                            DropdownButtonFormField2<RoomEntity>(
                              value: _selectedRoom,
                              items:
                                  roomsList
                                      .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                                      .toList(),
                              onChanged: (val) => setState(() => _selectedRoom = val),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const H2Text(text: "Record Mode"),
                            Column(
                              children: [
                                RadioListTile<bool>(
                                  title: const Text("Personal"),
                                  value: false,
                                  activeColor: UIColor().primaryDarkRed,
                                  groupValue: _isSharedRecord,
                                  onChanged:
                                      (val) => setState(() {
                                        _isSharedRecord = val!;
                                        _selectedFriend = null;
                                      }),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                                RadioListTile<bool>(
                                  title: const Text("Add for Friend"),
                                  value: true,
                                  activeColor: UIColor().primaryDarkRed,
                                  groupValue: _isSharedRecord,
                                  onChanged: (val) => setState(() => _isSharedRecord = val!),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ],
                            ),
                            if (_isSharedRecord) ...[
                              const SizedBox(height: 8),
                              const H2Text(text: "Select Friend"),
                              const SizedBox(height: 8),
                              DropdownButtonFormField2<UserEntity>(
                                value: _selectedFriend,
                                isExpanded: true,
                                hint: const Text("Choose a completed profile"),
                                items:
                                    _availableFriends
                                        .map(
                                          (user) => DropdownMenuItem(
                                            value: user,
                                            child: Text(
                                              "${user.name}",
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) => setState(() => _selectedFriend = val),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        _isSharedRecord && value == null
                                            ? "Please select a friend"
                                            : null,
                              ),
                            ],
                            const SizedBox(height: 16),
                            const H2Text(text: "Entry Date"),
                            const SizedBox(height: 8),
                            _buildDatePickerButton(
                              date: _selectedEntryDate,
                              onTap:
                                  () => _selectDate(
                                    context,
                                    _selectedEntryDate,
                                    (d) => _selectedEntryDate = d,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            const H2Text(text: "Exit Date"),
                            const SizedBox(height: 8),
                            _buildDatePickerButton(
                              date: _selectedExitDate,
                              onTap:
                                  () => _selectDate(
                                    context,
                                    _selectedExitDate,
                                    (d) => _selectedExitDate = d,
                                  ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: UIColor().primaryBlue,
                                  padding: const EdgeInsets.all(16),
                                ),
                                onPressed: () async {
                                  if (_recordForm.currentState!.validate()) {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) =>
                                              LoadingWidget().circularLoadingWidget(context),
                                    );

                                    // Logic to separate own and friend records based on UID order
                                    List<String> uids = [];
                                    if (_isSharedRecord && _selectedFriend != null) {
                                      // Friend's UID is first to indicate they are the primary subject
                                      uids.add(_selectedFriend!.id);
                                      uids.add(userState.userEntity.id);
                                    } else {
                                      // Personal record: only current user UID
                                      uids.add(userState.userEntity.id);
                                    }

                                    String docId =
                                        _editingRecordId ??
                                        FirebaseFirestore.instance.collection("records").doc().id;

                                    final newRecordEntity = RecordEntity(
                                      id: docId,
                                      roomId: _selectedRoom!.id,
                                      uid: uids,
                                      checkinTime: Timestamp.fromDate(_selectedEntryDate),
                                      checkoutTime: Timestamp.fromDate(_selectedExitDate),
                                    );

                                    await FirestoreService().addRecord(context, newRecordEntity);

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      snackBarText.showBanner(
                                        msg:
                                            _editingRecordId == null
                                                ? "Added record"
                                                : "Updated record",
                                        context: context,
                                      );
                                      _resetForm();
                                    }
                                  }
                                },
                                child: Text(
                                  _editingRecordId == null ? "SAVE RECORD" : "UPDATE RECORD",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (_editingRecordId != null) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _resetForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  padding: const EdgeInsets.all(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    "CANCEL EDIT",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  const SizedBox(height: 32),
                  _buildRecordsStream(userState, roomsList),
                  const SizedBox(height: 32), // Bottom padding for scrolling
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordsStream(UserState userState, List<RoomEntity> roomsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: H1Text(text: "My Records")),
        const SizedBox(height: 16),
        _buildFilteredRecords(userState, roomsList, isOwn: true),
        const SizedBox(height: 32),
        const Center(child: H1Text(text: "Friend's Records")),
        const SizedBox(height: 16),
        _buildFilteredRecords(userState, roomsList, isOwn: false),
      ],
    );
  }

  Widget _buildFilteredRecords(
    UserState userState,
    List<RoomEntity> roomsList, {
    required bool isOwn,
  }) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('records')
              .where("uid", arrayContains: userState.userEntity.id)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: LoadingWidgetLarge());

        final currentUid = userState.userEntity.id;
        final docs =
            snapshot.data!.docs.where((doc) {
              final uids = doc.data()['uid'] as List<dynamic>;
              return isOwn ? uids.first == currentUid : uids.first != currentUid;
            }).toList();

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("No records found"),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final record = RecordEntity.fromMap(docs[index].data());

            // Identify the display name based on the first UID in the record
            String displayName = "Unknown";
            if (record.uid.first == currentUid) {
              displayName = userState.userEntity.name;
            } else {
              // Find the friend in the pre-loaded _availableFriends list
              final friend = _availableFriends.firstWhere(
                (u) => u.id == record.uid.first,
                orElse: () => UserEntity(id: 'NA', name: 'Friend', gender: '_', contact: 'NA'),
              );
              displayName = friend.name;
            }

            return RecordCard(
              parentContext: context,
              recordEntity: record,
              rooms: roomsList,
              displayName: displayName, // Pass the pre-loaded name here
              onEdit: (rec) => _loadRecordForEdit(rec, roomsList),
            );
          },
        );
      },
    );
  }
}
