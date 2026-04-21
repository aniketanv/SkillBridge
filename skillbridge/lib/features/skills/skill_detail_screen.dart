import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillbridge/models/skill_model.dart';
import 'package:skillbridge/features/auth/auth_repository.dart';
import 'package:skillbridge/features/bookings/booking_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class SkillDetailScreen extends ConsumerStatefulWidget {
  final SkillModel skill;

  const SkillDetailScreen({super.key, required this.skill});

  @override
  ConsumerState<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends ConsumerState<SkillDetailScreen> {
  bool _isBooking = false;

  Future<void> _handleBooking(BuildContext context) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    if (user.id == widget.skill.userId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You cannot book your own skill!")));
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (date == null) return;

    setState(() => _isBooking = true);

    try {
      await ref.read(bookingRepositoryProvider).requestSession(
        skillId: widget.skill.id,
        teacherId: widget.skill.userId,
        learnerId: user.id,
        dateTime: date,
        creditCost: widget.skill.creditCost,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Requested Successfully!')));
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _isBooking = false);
    }
  }

  Future<void> _requestDiscount(BuildContext context) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    if (user.id == widget.skill.userId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This is your own skill.")));
      return;
    }

    String requestCost = (widget.skill.creditCost - 1).toString();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        String proposedCost = requestCost;
        return AlertDialog(
          title: const Text('Request Lower Cost'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Cost: ${widget.skill.creditCost} Credits'),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: proposedCost,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Proposed Cost (Credits)'),
                onChanged: (val) => proposedCost = val,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (int.tryParse(proposedCost) != null) {
                  context.pop(proposedCost);
                }
              }, 
              child: const Text('Send Request')
            )
          ],
        );
      }
    );

    if (result != null && context.mounted && widget.skill.user != null) {
      // Navigate to chat with the instructor, and maybe we can pass an initial text.
      // But since chat_detail requires user, we can send them to chat, and let them type it themselves
      // or we can just copy it to clipboard. For simplicity, we just push to chat.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tell the instructor your proposed price!')));
      context.push('/chat-detail', extra: widget.skill.user!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.skill.mediaUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.skill.mediaUrl,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(widget.skill.category),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      if (!widget.skill.isApproved)
                        const Chip(
                          label: Text('Pending Approval'),
                          backgroundColor: Colors.orangeAccent,
                        )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.skill.level),
                        backgroundColor: Colors.blueGrey.withOpacity(0.2),
                        labelStyle: const TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('${widget.skill.creditCost} Credits'),
                        backgroundColor: Colors.green.withOpacity(0.2),
                        labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        avatar: const Icon(Icons.monetization_on, color: Colors.green, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.skill.title,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posted on ${widget.skill.createdAt.toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(height: 48),
                  
                  // Instructor Info
                  Text('Instructor', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: widget.skill.user?.profilePhotoUrl != null && widget.skill.user!.profilePhotoUrl.isNotEmpty 
                        ? CachedNetworkImageProvider(widget.skill.user!.profilePhotoUrl) 
                        : null,
                      child: widget.skill.user?.profilePhotoUrl == null || widget.skill.user!.profilePhotoUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                    ),
                    title: Row(
                      children: [
                        Text(widget.skill.user?.name ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        if (widget.skill.user != null && widget.skill.user!.averageRating > 0)
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(widget.skill.user!.averageRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(' (${widget.skill.user!.totalRatings})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          )
                      ],
                    ),
                    subtitle: Text(widget.skill.user?.bio ?? 'No bio available', maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),

                  const Divider(height: 48),

                  // Description
                  Text('About this skill', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text(
                    widget.skill.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),

                  if (widget.skill.videoUrl.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final Uri url = Uri.parse(widget.skill.videoUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open video link')));
                            }
                          }
                        },
                        icon: const Icon(Icons.play_circle_fill),
                        label: const Text('Watch Video Tutorial'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 48),
                  
                  // CTAs
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (widget.skill.user != null) {
                              context.push('/chat-detail', extra: widget.skill.user!);
                            }
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text('Chat'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isBooking ? null : () => _handleBooking(context),
                          icon: _isBooking ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.calendar_month),
                          label: Text(_isBooking ? 'Booking...' : 'Book Session'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _requestDiscount(context), 
                    icon: const Icon(Icons.arrow_downward, size: 16), 
                    label: const Text('Request Lower Cost')
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
