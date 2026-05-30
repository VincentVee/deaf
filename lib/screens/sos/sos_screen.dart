import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<EmergencyContact> _contacts = [];
  bool _isSendingSOS = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _loadContacts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contactsJson = prefs.getString('emergency_contacts');

    if (contactsJson != null) {
      List<dynamic> contactsList = json.decode(contactsJson);
      setState(() {
        _contacts = contactsList.map((contact) => EmergencyContact.fromJson(contact)).toList();
      });
    } else {
      setState(() {
        _contacts = [
          EmergencyContact(name: 'Emergency Services', phone: '911', relation: 'Emergency'),
          EmergencyContact(name: 'Family Member', phone: '555-0101', relation: 'Family'),
          EmergencyContact(name: 'Close Friend', phone: '555-0102', relation: 'Friend'),
        ];
      });
      await _saveContacts();
    }
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> contactsMap = _contacts.map((contact) => contact.toJson()).toList();
    await prefs.setString('emergency_contacts', json.encode(contactsMap));
  }

  Future<void> _addContact(String name, String phone, String relation) async {
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least name and phone number')),
      );
      return;
    }

    setState(() {
      _contacts.add(EmergencyContact(
        name: name,
        phone: phone,
        relation: relation.isEmpty ? 'Custom' : relation,
      ));
    });
    await _saveContacts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact added successfully!')),
    );
  }

  Future<void> _deleteContact(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${_contacts[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _contacts.removeAt(index);
              });
              await _saveContacts();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSOS() async {
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add emergency contacts first!')),
      );
      return;
    }

    setState(() {
      _isSendingSOS = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position? position;
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      }

      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      const androidChannelDetails = AndroidNotificationDetails(
        'sos_channel',
        'SOS Alerts',
        channelDescription: 'Emergency SOS notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );
      const iosDetails = DarwinNotificationDetails();
      const notificationDetails = NotificationDetails(android: androidChannelDetails, iOS: iosDetails);

      for (var contact in _contacts) {
        await flutterLocalNotificationsPlugin.show(
          DateTime.now().millisecondsSinceEpoch.remainder(100000),
          'SOS Alert from DeafSmart!',
          'Emergency assistance needed for ${contact.name}. Location: ${position != null ? '${position.latitude}, ${position.longitude}' : 'Location unavailable'}',
          notificationDetails,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SOS alert sent to ${_contacts.length} contact(s)!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending SOS: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isSendingSOS = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Emergency')),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SOS Button
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 180 + (40 * _animationController.value),
                  height: 180 + (40 * _animationController.value),
                  child: FloatingActionButton(
                    onPressed: _isSendingSOS ? null : _sendSOS,
                    backgroundColor: Colors.red,
                    child: _isSendingSOS
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.sos, size: 60),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'EMERGENCY SOS',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap the button above to send an emergency alert',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Emergency Contacts Card - Now showing ALL contacts
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Emergency Contacts',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_contacts.length} contacts',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'These contacts will be notified when you trigger SOS',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    if (_contacts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No emergency contacts added yet.\nTap "Add Contact" to add one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      )
                    else
                    // ✅ Show ALL contacts - removed the limit of 3
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _contacts.length,  // ✅ Show all contacts
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.red.withOpacity(0.1),
                              child: Icon(Icons.person, size: 16, color: Colors.red),
                            ),
                            title: Text(contact.name, style: const TextStyle(fontSize: 13)),
                            subtitle: Text('${contact.relation} • ${contact.phone}', style: const TextStyle(fontSize: 11)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.call, size: 18, color: Colors.green),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Calling ${contact.name}...')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 18, color: Colors.grey),
                                  onPressed: () => _deleteContact(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _showAddContactDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Contact', style: TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tips Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Emergency Tips',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildTip('1. Stay calm and assess the situation'),
                    _buildTip('2. Use the SOS button above'),
                    _buildTip('3. Find a safe location if possible'),
                    _buildTip('4. Share your location with responders'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),  // Extra bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 14, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    _nameController.clear();
    _phoneController.clear();
    _relationController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '+260977774423',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _relationController,
                decoration: const InputDecoration(
                  labelText: 'Relation',
                  hintText: 'Family, Friend, Doctor, etc.',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              minimumSize: const Size(60, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addContact(
                _nameController.text.trim(),
                _phoneController.text.trim(),
                _relationController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Add Contact', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relation;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'relation': relation,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      phone: json['phone'],
      relation: json['relation'],
    );
  }
}