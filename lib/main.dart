import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hethongquanglyphongtro/firebase_options.dart';
import 'CreateRoomScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hệ thống quản lý phòng trọ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, 
      home: const RoomInfoScreen(),
    );
  }
}

class RoomInfoScreen extends StatefulWidget {
  const RoomInfoScreen({super.key});

  @override
  State<RoomInfoScreen> createState() => _RoomInfoScreenState();
}

class _RoomInfoScreenState extends State<RoomInfoScreen> {
  String searchQuery = ''; 
  final Set<String> selectedRooms = {}; 

  void _confirmDeleteSelected(BuildContext context) {
    if (selectedRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một phòng để xóa')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa các phòng đã chọn không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); 
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                for (final roomId in selectedRooms) {
                  await FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(roomId)
                      .delete();
                }
                setState(() {
                  selectedRooms.clear(); 
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xóa thành công')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi xóa: $e')),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Phòng Trọ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteSelected(context),
          ),
        ],
      ),
      body: Column(
        children: [
       
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim(); 
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Đã xảy ra lỗi khi tải dữ liệu'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Chưa có phòng trọ nào.'),
                  );
                }

                final rooms = snapshot.data!.docs.where((room) {
                  final data = room.data() as Map<String, dynamic>;
                  final maPhong = data['maPhong']?.toString().toLowerCase() ?? '';
                  final tenNguoiThue =
                      data['tenNguoiThue']?.toString().toLowerCase() ?? '';
                  return maPhong.contains(searchQuery.toLowerCase()) ||
                      tenNguoiThue.contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final data = room.data() as Map<String, dynamic>;
                    final roomId = room.id;

                    final dynamic ngayBatDau = data['ngayBatDau'];
                    String formattedNgayBatDau = '';

                    if (ngayBatDau is Timestamp) {
                      formattedNgayBatDau =
                          ngayBatDau.toDate().toLocal().toString().split(' ')[0];
                    } else if (ngayBatDau is String) {
                      formattedNgayBatDau = ngayBatDau;
                    }

                    final isSelected = selectedRooms.contains(roomId);

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedRooms.remove(roomId);
                            } else {
                              selectedRooms.add(roomId);
                            }
                          });
                        },
                        selected: isSelected,
                        selectedTileColor: Colors.grey[300],
                        title: Text('Mã Phòng: ${data['maPhong']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tên Người Thuê: ${data['tenNguoiThue']}'),
                            Text('Số Điện Thoại: ${data['soDienThoai']}'),
                            Text('Ngày Bắt Đầu: $formattedNgayBatDau'),
                            Text(
                                'Hình Thức Thanh Toán: ${data['hinhThucThanhToan']}'),
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_box, color: Colors.blue)
                            : const Icon(Icons.check_box_outline_blank),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateRoomScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}