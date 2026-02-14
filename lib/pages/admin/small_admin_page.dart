import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/entities/admin_entity.dart';
import 'package:icmc_dorm/entities/record_entity.dart';
import 'package:icmc_dorm/entities/room_entity.dart';
import 'package:icmc_dorm/entities/user_entity.dart';
import 'package:icmc_dorm/services/excel_service/excel_service.dart';
import 'package:icmc_dorm/states/user_state.dart';
import 'package:icmc_dorm/widgets/h1_text.dart';
import 'package:icmc_dorm/widgets/loading_widget_large.dart';
import 'package:icmc_dorm/widgets/snack_bar_text.dart';
import 'package:icmc_dorm/widgets/ui_color.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SmallAdminPage extends StatefulWidget {
  const SmallAdminPage({super.key});

  @override
  State<SmallAdminPage> createState() => _SmallAdminPageState();
}

class _SmallAdminPageState extends State<SmallAdminPage> {
  String _filterType = 'Day';
  final List<String> _filterOptions = ['Day', 'Week', 'Month', 'Year', 'All'];
  DateTime _selectedDate = DateTime.now();

  // Cached Metadata
  List<RoomEntity> _allRooms = [];
  List<UserEntity> _allUsers = [];
  bool _isLoadingMetadata = true;

  @override
  void initState() {
    super.initState();
    _fetchMetadata();
  }

  Future<void> _fetchMetadata() async {
    try {
      final roomSnap = await FirebaseFirestore.instance.collection('rooms').get();
      final userSnap = await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        _allRooms = roomSnap.docs.map((d) => RoomEntity.fromMap(d.data())).toList();
        _allUsers = userSnap.docs.map((d) => UserEntity.fromMap(d.data())).toList();
        _isLoadingMetadata = false;
      });
    } catch (e) {
      debugPrint("Error fetching metadata: $e");
      setState(() => _isLoadingMetadata = false);
    }
  }

  Future<AdminEntity> getAdminList() async {
    QuerySnapshot<Map<String, dynamic>> docs =
        await FirebaseFirestore.instance.collection("admin").get();
    if (docs.docs.isEmpty) return AdminEntity(admins: []);
    return AdminEntity.fromMap(docs.docs.first.data());
  }

  // Filtering Logic

  DateTimeRange _getDateRange() {
    DateTime start;
    DateTime end;
    DateTime now = _selectedDate;

    switch (_filterType) {
      case 'Day':
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Week':
        // Assuming Week starts on Monday
        int dayOfWeek = now.weekday; // 1 (Mon) - 7 (Sun)
        start = DateTime(now.year, now.month, now.day).subtract(Duration(days: dayOfWeek - 1));
        end = start
            .add(const Duration(days: 6))
            .add(const Duration(hours: 23, minutes: 59, seconds: 59));
        break;
      case 'Month':
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59); // last day of month
        break;
      case 'Year':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      default: // All
        start = DateTime(2000);
        end = DateTime(3000);
    }
    return DateTimeRange(start: start, end: end);
  }

  Stream<List<RecordEntity>> _getRecordsStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('records');

    if (_filterType != 'All') {
      DateTimeRange range = _getDateRange();
      // Requires Firestore Index on checkinTime
      query = query
          .where('checkinTime', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
          .where('checkinTime', isLessThanOrEqualTo: Timestamp.fromDate(range.end));
    }

    return query.snapshots().map((s) => s.docs.map((d) => RecordEntity.fromMap(d.data())).toList());
  }

  // Export Logic

  Future<void> _exportToExcel(List<RecordEntity> records) async {
    if (records.isEmpty) {
      SnackBarText().showBanner(msg: "No records to export", context: context);
      return;
    }

    List<int>? fileBytes = await ExcelService().generateExcel(
      records: records,
      rooms: _allRooms,
      users: _allUsers,
    );

    if (fileBytes != null) {
      String fileName = "Dorm_Records_${DateFormat('yyyyMMdd_HHmmSS').format(DateTime.now())}";

      // Save file using file_saver (works on Web & Mobile/Desktop)
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(fileBytes),
        fileExtension: "xlsx",
        mimeType: MimeType.microsoftExcel,
      );

      if (mounted) {
        SnackBarText().showBanner(msg: "Excel exported successfully", context: context);
      }
    }
  }

  // UI Components

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: UIColor().primaryDarkRed,
              onPrimary: UIColor().white,
              onSurface: UIColor().darkGray,
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

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: false);

    return Scaffold(
      body: FutureBuilder<AdminEntity>(
        future: getAdminList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting ||
              _isLoadingMetadata) {
            return const LoadingWidgetLarge();
          }

          if (snapshot.data!.admins.contains(userState.userEntity.id)) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Center(child: H1Text(text: "Admin Dashboard")),
                  const SizedBox(height: 24),

                  // Filter Section (Responsive)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: UIColor().white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: UIColor().orangeBlack.withAlpha(128), blurRadius: 5),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter Type Dropdown
                        DropdownButtonFormField2<String>(
                          value: _filterType,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                          items:
                              _filterOptions
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: UIColor().primaryDarkRed,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() {
                                _filterType = val!;
                              }),
                        ),

                        // Date Picker (Hidden if 'All')
                        if (_filterType != 'All') ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: UIColor().darkGray,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _selectDate(context),
                                icon: const Icon(Icons.calendar_today),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Records Table
                  Expanded(
                    child: StreamBuilder<List<RecordEntity>>(
                      stream: _getRecordsStream(),
                      builder: (context, recordSnap) {
                        if (recordSnap.connectionState == ConnectionState.waiting) {
                          return const LoadingWidgetLarge();
                        }

                        if (recordSnap.hasError) {
                          return Center(child: Text("Error: ${recordSnap.error}"));
                        }

                        final records = recordSnap.data ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Export Button (Visible when data loads)
                            ElevatedButton.icon(
                              onPressed: () => _exportToExcel(records),
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text("EXPORT EXCEL"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UIColor().primaryBlue,
                                foregroundColor: UIColor().white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Table with Horizontal Scroll
                            Expanded(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      headingRowColor: WidgetStatePropertyAll(
                                        UIColor().transparentPrimaryBlue,
                                      ),
                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'Room',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            '名字（中）',
                                            softWrap: true,
                                            maxLines: 1,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            '联络号码',
                                            softWrap: true,
                                            maxLines: 1,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            '入住日期',
                                            softWrap: true,
                                            maxLines: 1,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            '离开日期',
                                            softWrap: true,
                                            maxLines: 1,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                      rows:
                                          records.map((record) {
                                            final room = _allRooms.firstWhere(
                                              (r) => r.id == record.roomId,
                                              orElse: () => RoomEntity(id: '', name: 'Unknown'),
                                            );

                                            String guestName = "Unknown";
                                            String guestContact = "Unknown";
                                            if (record.uid.isNotEmpty) {
                                              final guest = _allUsers.firstWhere(
                                                (u) => u.id == record.uid.first,
                                                orElse:
                                                    () => UserEntity(
                                                      id: '',
                                                      name: 'Unknown',
                                                      gender: '',
                                                      contact: '',
                                                    ),
                                              );
                                              guestName = guest.name;
                                              guestContact = guest.contact;
                                            }

                                            return DataRow(
                                              cells: [
                                                DataCell(Text(room.name)),
                                                DataCell(Text(guestName)),
                                                DataCell(Text(guestContact)),
                                                DataCell(
                                                  Text(
                                                    DateFormat(
                                                      'yyyy-MM-dd HH:mm',
                                                    ).format(record.checkinTime.toDate()),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    DateFormat(
                                                      'yyyy-MM-dd HH:mm',
                                                    ).format(record.checkoutTime.toDate()),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Access Denied",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text("This account doesn't have admin access 👾"),
                const SizedBox(height: 16),
                Text("Your ID: ${userState.userEntity.id}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
