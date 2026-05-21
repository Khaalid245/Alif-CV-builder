import 'package:flutter/material.dart';

class TransitionHistoryWidget extends StatelessWidget {
  final List<TransitionHistoryItem> history;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const TransitionHistoryWidget({
    Key? key,
    required this.history,
    this.isLoading = false,
    this.onLoadMore,
    this.hasMore = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading && history.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (history.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: history.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == history.length) {
                return _buildLoadMoreButton(context);
              }
              return _buildHistoryItem(context, history[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transition history',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Workflow transitions will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: onLoadMore,
        child: const Text('Load More'),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, TransitionHistoryItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.transitionName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _buildStatusChip(context, item.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  item.userName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(item.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            if (item.comment != null && item.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  item.comment!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        break;
      case 'rejected':
      case 'failed':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        break;
      case 'pending':
      case 'in_progress':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        break;
      default:
        backgroundColor = Theme.of(context).colorScheme.surface;
        textColor = Theme.of(context).colorScheme.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class TransitionHistoryItem {
  final String id;
  final String transitionName;
  final String status;
  final String userName;
  final DateTime timestamp;
  final String? comment;

  const TransitionHistoryItem({
    required this.id,
    required this.transitionName,
    required this.status,
    required this.userName,
    required this.timestamp,
    this.comment,
  });

  factory TransitionHistoryItem.fromJson(Map<String, dynamic> json) {
    return TransitionHistoryItem(
      id: json['id'] as String,
      transitionName: json['transition_name'] as String,
      status: json['status'] as String,
      userName: json['user_name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transition_name': transitionName,
      'status': status,
      'user_name': userName,
      'timestamp': timestamp.toIso8601String(),
      'comment': comment,
    };
  }
}