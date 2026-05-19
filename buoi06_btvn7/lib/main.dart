import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const SmsAnalyzerApp());
}

/// =======================
/// APP ROOT
/// =======================
class SmsAnalyzerApp extends StatelessWidget {
  const SmsAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const SmsAnalyzerScreen(),
    );
  }
}

/// =======================
/// ENUM TYPE
/// =======================
enum SmsType {
  normal,
  advertisement,
  otp,
}

/// =======================
/// MODEL PHÂN TÍCH SMS
/// =======================
class SmsItem {
  final SmsMessage message;
  final SmsType type;
  final String? otpCode;

  SmsItem({
    required this.message,
    required this.type,
    this.otpCode,
  });

  /// Phân tích nội dung SMS
  factory SmsItem.fromMessage(SmsMessage sms) {
    final body = sms.body ?? '';

    // [QC] ... => quảng cáo
    if (body.startsWith('[QC]')) {
      return SmsItem(
        message: sms,
        type: SmsType.advertisement,
      );
    }

    // [OTP]123456 hoặc [OTP] 123456
    final otpRegex = RegExp(r'^\[OTP\]\s*(\d{6})');
    final match = otpRegex.firstMatch(body);

    if (match != null) {
      return SmsItem(
        message: sms,
        type: SmsType.otp,
        otpCode: match.group(1),
      );
    }

    return SmsItem(
      message: sms,
      type: SmsType.normal,
    );
  }

  String get sender => message.address ?? 'Unknown';
  String get body => message.body ?? '';
  DateTime get date =>
      message.date ?? DateTime.fromMillisecondsSinceEpoch(0);
}
/// =======================
/// MAIN SCREEN
/// =======================
class SmsAnalyzerScreen extends StatefulWidget {
  const SmsAnalyzerScreen({super.key});

  @override
  State<SmsAnalyzerScreen> createState() =>
      _SmsAnalyzerScreenState();
}

class _SmsAnalyzerScreenState
    extends State<SmsAnalyzerScreen> {
  final SmsQuery _query = SmsQuery();

  List<SmsItem> _allMessages = [];
  List<SmsItem> _filteredMessages = [];

  bool _isLoading = false;

  final TextEditingController _phoneController =
      TextEditingController();

  String _selectedFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// =======================
  /// XIN QUYỀN + ĐỌC SMS
  /// =======================
  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    final status = await Permission.sms.request();

    if (!status.isGranted) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn chưa cấp quyền đọc SMS'),
          ),
        );
      }
      return;
    }

    try {
      final messages = await _query.getAllSms;

      _allMessages = messages
          .map((sms) => SmsItem.fromMessage(sms))
          .toList();

      _applyFilter();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Lỗi đọc tin nhắn: $e'),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// =======================
  /// LỌC DỮ LIỆU
  /// =======================
  void _applyFilter() {
    List<SmsItem> temp = List.from(_allMessages);

    // Lọc theo số điện thoại
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty) {
      temp = temp
          .where(
            (item) =>
                item.sender.contains(phone),
          )
          .toList();
    }

    // Lọc theo nhóm
    switch (_selectedFilter) {
      case 'Quảng cáo':
        temp = temp
            .where(
              (item) =>
                  item.type ==
                  SmsType.advertisement,
            )
            .toList();
        break;

      case 'OTP':
        temp = temp
            .where(
              (item) =>
                  item.type == SmsType.otp,
            )
            .toList();
        break;

      default:
        break;
    }

    setState(() {
      _filteredMessages = temp;
    });
  }

  /// =======================
  /// THỐNG KÊ THEO NGÀY
  /// =======================
  Map<String, int> _statisticsByDay() {
    final Map<String, int> stats = {};

    for (final item in _allMessages) {
      final key =
          DateFormat('dd/MM/yyyy')
              .format(item.date);
      stats[key] = (stats[key] ?? 0) + 1;
    }

    return stats;
  }

  /// =======================
  /// THỐNG KÊ THEO THÁNG
  /// =======================
  Map<String, int> _statisticsByMonth() {
    final Map<String, int> stats = {};

    for (final item in _allMessages) {
      final key =
          DateFormat('MM/yyyy')
              .format(item.date);
      stats[key] = (stats[key] ?? 0) + 1;
    }

    return stats;
  }

  /// =======================
  /// HIỂN THỊ OTP
  /// =======================
  void _showOtpDialog(String otp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mã OTP'),
        content: SelectableText(
          otp,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  /// =======================
  /// BUILD UI
  /// =======================
  @override
  Widget build(BuildContext context) {
    final dayStats = _statisticsByDay();
    final monthStats = _statisticsByMonth();

    final otpCount = _allMessages
        .where((item) => item.type == SmsType.otp)
        .length;

    final adCount = _allMessages
        .where(
          (item) => item.type == SmsType.advertisement,
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Analyzer'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Column(
              children: [
                // =======================
                // THỐNG KÊ TỔNG QUAN
                // =======================
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  color: Colors.indigo
                      .withOpacity(0.05),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng số tin nhắn: ${_allMessages.length}',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Tin nhắn quảng cáo: $adCount',
                      ),
                      Text(
                        'Tin nhắn OTP: $otpCount',
                      ),
                    ],
                  ),
                ),

                // =======================
                // LỌC THEO SỐ ĐIỆN THOẠI
                // =======================
                Padding(
                  padding:
                      const EdgeInsets.all(12),
                  child: TextField(
                    controller:
                        _phoneController,
                    decoration:
                        InputDecoration(
                      labelText:
                          'Lọc theo số điện thoại',
                      prefixIcon:
                          const Icon(
                        Icons.phone,
                      ),
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          _phoneController
                              .clear();
                          _applyFilter();
                        },
                        icon: const Icon(
                          Icons.clear,
                        ),
                      ),
                      border:
                          const OutlineInputBorder(),
                    ),
                    onChanged: (_) =>
                        _applyFilter(),
                  ),
                ),

                // =======================
                // COMBO FILTER
                // =======================
                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child:
                      DropdownButtonFormField<
                          String>(
                    value: _selectedFilter,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Nhóm tin nhắn',
                      border:
                          OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Tất cả',
                        child: Text(
                            'Tất cả'),
                      ),
                      DropdownMenuItem(
                        value: 'Quảng cáo',
                        child: Text(
                            'Quảng cáo'),
                      ),
                      DropdownMenuItem(
                        value: 'OTP',
                        child: Text('OTP'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _selectedFilter =
                            value;
                        _applyFilter();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // =======================
                // THỐNG KÊ THEO NGÀY/THÁNG
                // =======================
                ExpansionTile(
                  title: const Text(
                    'Thống kê theo ngày',
                  ),
                  children: dayStats.entries
                      .take(10)
                      .map(
                        (e) => ListTile(
                          dense: true,
                          title:
                              Text(e.key),
                          trailing: Text(
                            '${e.value}',
                          ),
                        ),
                      )
                      .toList(),
                ),

                ExpansionTile(
                  title: const Text(
                    'Thống kê theo tháng',
                  ),
                  children:
                      monthStats.entries
                          .map(
                            (e) => ListTile(
                              dense: true,
                              title: Text(
                                  e.key),
                              trailing:
                                  Text(
                                '${e.value}',
                              ),
                            ),
                          )
                          .toList(),
                ),

                const Divider(),

                // =======================
                // DANH SÁCH SMS
                // =======================
                Expanded(
                  child:
                      _filteredMessages
                              .isEmpty
                          ? const Center(
                              child: Text(
                                'Không có dữ liệu',
                              ),
                            )
                          : ListView.builder(
                              itemCount:
                                  _filteredMessages
                                      .length,
                              itemBuilder:
                                  (
                                    context,
                                    index,
                                  ) {
                                final item =
                                    _filteredMessages[
                                        index];

                                IconData icon;
                                Color color;

                                switch (item
                                    .type) {
                                  case SmsType
                                      .advertisement:
                                    icon =
                                        Icons
                                            .campaign;
                                    color =
                                        Colors
                                            .orange;
                                    break;

                                  case SmsType
                                      .otp:
                                    icon =
                                        Icons
                                            .security;
                                    color =
                                        Colors
                                            .green;
                                    break;

                                  default:
                                    icon =
                                        Icons
                                            .message;
                                    color =
                                        Colors
                                            .blue;
                                }

                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(
                                    horizontal:
                                        8,
                                    vertical:
                                        4,
                                  ),
                                  child:
                                      ListTile(
                                    leading:
                                        Icon(
                                      icon,
                                      color:
                                          color,
                                    ),
                                    title: Text(
                                      item
                                          .sender,
                                    ),
                                    subtitle:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          item
                                              .body,
                                          maxLines:
                                              2,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                        ),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy HH:mm',
                                          ).format(
                                            item
                                                .date,
                                          ),
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                12,
                                            color:
                                                Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing:
                                        item.type ==
                                                SmsType
                                                    .otp
                                            ? Chip(
                                                label:
                                                    Text(
                                                  item.otpCode ??
                                                      '',
                                                ),
                                              )
                                            : null,
                                    onTap: () {
                                      if (item
                                              .type ==
                                          SmsType
                                              .otp) {
                                        _showOtpDialog(
                                          item.otpCode ??
                                              '',
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}