import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constatnt/colors.dart';
import '../../models/bookingModel.dart';
import '../../providers/bookingProvider.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Replace with logged-in userId from FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;

    final userId = user!.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false)
          .fetchBookings(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ColorsData.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title:
              const Text('My Bookings', style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            BookingList(status: BookingStatus.upcoming),
            BookingList(status: BookingStatus.completed),
            BookingList(status: BookingStatus.cancelled),
          ],
        ),
      ),
    );
  }
}

class BookingList extends StatelessWidget {
  final BookingStatus status;
  const BookingList({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);
    final bookings =
        provider.bookings.where((b) => b.status == status).toList();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'No ${status.toString().split('.').last} bookings',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingCard(booking: bookings[index]);
      },
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.read<BookingProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.branchName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.formattedDateTime,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            booking.statusIcon,
                            color: booking.statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.status
                                .toString()
                                .split('.')
                                .last
                                .toUpperCase(),
                            style: TextStyle(
                              color: booking.statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Price',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  '₹${booking.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (booking.status == BookingStatus.upcoming) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // bookingProvider.cancelBooking(booking.id);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // bookingProvider.rescheduleBooking(
                        //   booking.id,
                        //   DateTime.now().add(const Duration(days: 7)),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsData.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reschedule'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
