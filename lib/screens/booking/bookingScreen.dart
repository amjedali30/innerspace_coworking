import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innerspace_coworking/models/branchModel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constatnt/colors.dart';
import '../../models/bookingModel.dart';
import '../../providers/bookingProvider.dart';
import '../../services/firebase_messaging_service.dart';
import '../../services/notificationSerivice.dart';

class BookingScreen extends StatefulWidget {
  final BranchModel branch;

  const BookingScreen({super.key, required this.branch});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Book ${widget.branch.name}'),
        backgroundColor: ColorsData.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branch Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.branch.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            widget.branch.city,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${widget.branch.pricePerHour}/hr',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorsData.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information
              Text(
                'Your Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Booking Details
              Text(
                'Booking Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildDatePickerTile(context),
              const SizedBox(height: 16),
              _buildTimePickerTile(context, 'Start Time', _startTime, (time) {
                setState(() => _startTime = time);
              }),
              const SizedBox(height: 16),
              _buildTimePickerTile(context, 'End Time', _endTime, (time) {
                setState(() => _endTime = time);
              }),
              const SizedBox(height: 32),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: bookingProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedDate == null ||
                                _startTime == null ||
                                _endTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select date and time'),
                                ),
                              );
                              return;
                            }
                            final user = FirebaseAuth.instance.currentUser;
                            final deviceToken = await getDeviceToken();
                            final booking = BookingModel(
                              userId: user!.uid,
                              username: _usernameController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              branchId: widget.branch.id,
                              branchName: widget.branch.name,
                              date: _selectedDate!,
                              startTime: _startTime!,
                              endTime: _endTime!,
                              pricePerHour: widget.branch.pricePerHour,
                              deviceToken: deviceToken,
                            );

                            try {
                              await bookingProvider.createBooking(booking);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Booking confirmed successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsData.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: bookingProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerTile(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorsData.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.calendar_today, color: ColorsData.primaryColor),
      ),
      title: const Text('Select Date'),
      subtitle: Text(
        _selectedDate == null
            ? 'Not selected'
            : DateFormat('MMM dd, yyyy').format(_selectedDate!),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorsData.primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
    );
  }

  Widget _buildTimePickerTile(
    BuildContext context,
    String title,
    TimeOfDay? time,
    Function(TimeOfDay) onTimeSelected,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorsData.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.access_time, color: ColorsData.primaryColor),
      ),
      title: Text(title),
      subtitle: Text(
        time == null ? 'Not selected' : time.format(context),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorsData.primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (selectedTime != null) {
          onTimeSelected(selectedTime);
        }
      },
    );
  }
}
