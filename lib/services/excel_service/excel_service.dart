import 'package:excel/excel.dart';
import 'package:icmc_dorm/entities/record_entity.dart';
import 'package:icmc_dorm/entities/room_entity.dart';
import 'package:icmc_dorm/entities/user_entity.dart';
import 'package:intl/intl.dart';

class ExcelService {
  Future<List<int>?> generateExcel({
    required List<RecordEntity> records,
    required List<RoomEntity> rooms,
    required List<UserEntity> users,
  }) async {
    var excel = Excel.createExcel();

    // Create a map for quick lookups
    Map<String, String> roomMap = {for (var r in rooms) r.id: r.name};
    Map<String, String> userMap = {for (var u in users) u.id: u.name};
    Map<String, String> userContact = {for (var u in users) u.id: u.contact};

    // Group records by roomId
    Map<String, List<RecordEntity>> recordsByRoom = {};
    for (var record in records) {
      if (!recordsByRoom.containsKey(record.roomId)) {
        recordsByRoom[record.roomId] = [];
      }
      recordsByRoom[record.roomId]!.add(record);
    }

    // Create sheets for each room
    for (var roomId in recordsByRoom.keys) {
      String roomName = roomMap[roomId] ?? "Unknown Room";
      // Sanitize sheet name (Excel limit ~31 chars)
      String sheetName = roomName.replaceAll(RegExp(r'[\\/?*\[\]]'), '_');
      if (sheetName.length > 30) sheetName = sheetName.substring(0, 30);

      Sheet sheet = excel[sheetName];

      // Add Header
      sheet.appendRow([
        TextCellValue("Room"),
        TextCellValue("名字（中）"),
        TextCellValue("联络号码（有注册WhatsApp）"),
        TextCellValue("入住日期与时间"),
        TextCellValue("离开日期与时间"),
      ]);

      // Add Data
      for (var record in recordsByRoom[roomId]!) {
        String guestName = "Unknown";
        String guestContact = "Unknown";
        // Match the first UID as the person who stayed
        if (record.uid.isNotEmpty) {
          guestName = userMap[record.uid.first] ?? "Unknown User";
          guestContact = userContact[record.uid.first] ?? "No Contact";
        }

        String checkin = DateFormat('yyyy-MM-dd').format(record.checkinTime.toDate());
        String checkout = DateFormat('yyyy-MM-dd').format(record.checkoutTime.toDate());

        sheet.appendRow([
          TextCellValue(roomName),
          TextCellValue(guestName),
          TextCellValue(guestContact),
          TextCellValue(checkin),
          TextCellValue(checkout),
        ]);
      }
    }

    // Remove the default 'Sheet1' if we created other sheets
    if (excel.sheets.length > 1 && excel.sheets.keys.contains('Sheet1')) {
      excel.delete('Sheet1');
    }

    return excel.encode();
  }
}
