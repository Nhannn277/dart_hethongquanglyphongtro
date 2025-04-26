import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController maPhongController = TextEditingController();
  final TextEditingController tenNguoiThueController = TextEditingController();
  final TextEditingController soDienThoaiController = TextEditingController();
  final TextEditingController ngayBatDauController = TextEditingController();
  final TextEditingController hinhThucThanhToanController =
      TextEditingController();

  DateTime? selectedDate;

  void _chonNgay(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        ngayBatDauController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveRoom() async {
    final maPhong = maPhongController.text.trim();
    final tenNguoiThue = tenNguoiThueController.text.trim();
    final soDienThoai = soDienThoaiController.text.trim();
    final hinhThucThanhToan = hinhThucThanhToanController.text.trim();

    if (maPhong.isEmpty ||
        tenNguoiThue.isEmpty ||
        soDienThoai.isEmpty ||
        selectedDate == null ||
        hinhThucThanhToan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('rooms').add({
        'maPhong': maPhong,
        'tenNguoiThue': tenNguoiThue,
        'soDienThoai': soDienThoai,
        'ngayBatDau': Timestamp.fromDate(selectedDate!),
        'hinhThucThanhToan': hinhThucThanhToan,
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu dữ liệu: $e')),
      );
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Phòng Mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: maPhongController,
                decoration: const InputDecoration(labelText: 'Mã Phòng'),
              ),
              TextField(
                controller: tenNguoiThueController,
                decoration: const InputDecoration(labelText: 'Tên Người Thuê'),
              ),
              TextField(
                controller: soDienThoaiController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Số Điện Thoại'),
              ),
              TextField(
                controller: ngayBatDauController,
                readOnly: true,
                onTap: () => _chonNgay(context),
                decoration: const InputDecoration(labelText: 'Ngày Bắt Đầu'),
              ),
              TextField(
                controller: hinhThucThanhToanController,
                decoration:
                    const InputDecoration(labelText: 'Hình Thức Thanh Toán'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveRoom,
                    child: const Text('Lưu'),
                  ),
                  ElevatedButton(
                    onPressed: _cancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Hủy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}