import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/call_log_entity.dart';
import '../../domain/usecases/call_usecases.dart';
import '../cubit/call_cubit.dart';
import '../cubit/call_state.dart';
import 'active_call_screen.dart';
import 'incoming_call_screen.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear History',
            onPressed: () => _confirmClearHistory(context),
          ),
        ],
      ),
      body: BlocBuilder<CallHistoryCubit, CallHistoryState>(
        builder: (context, state) {
          if (state is CallHistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (state is CallHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppTheme.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, style: AppTheme.bodyLarge),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CallHistoryCubit>().loadHistory(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CallHistoryLoaded) {
            if (state.logs.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () => context.read<CallHistoryCubit>().loadHistory(),
              color: AppTheme.primary,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: state.logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final log = state.logs[index];
                  return _CallLogTile(
                    log: log,
                    onVoiceCall: () => _startOutgoingCall(
                      context,
                      callerName: log.callerName,
                      callerAvatar: log.callerAvatar,
                      isVideo: false,
                    ),
                    onVideoCall: () => _startOutgoingCall(
                      context,
                      callerName: log.callerName,
                      callerAvatar: log.callerAvatar,
                      isVideo: true,
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _buildCallFab(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceCard,
              border: Border.all(color: AppTheme.divider),
            ),
            child: const Icon(
              Icons.phone_missed_rounded,
              color: AppTheme.textSecondary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text('No Call History', style: AppTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Start a voice or video call to see history here',
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCallFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showCallOptionsSheet(context),
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.add_call, color: Colors.white),
      label: const Text(
        'New Call',
        style: TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showCallOptionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Start a Call',
                style: AppTheme.titleLarge.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Text(
                'Connect in real-time with Agora RTC',
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: 24),

              // Voice Call Outgoing
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.callGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_in_talk_rounded,
                      color: AppTheme.callGreen),
                ),
                title: const Text('Voice Call (Outgoing)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Start high-definition voice call',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _startOutgoingCall(context,
                      callerName: 'Rajan Sharma', isVideo: false);
                },
              ),

              // Video Call Outgoing
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.videocam_rounded,
                      color: AppTheme.primary),
                ),
                title: const Text('Video Call (Outgoing)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Start 1-on-1 HD video call',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _startOutgoingCall(context,
                      callerName: 'Rajan Sharma', isVideo: true);
                },
              ),

              const Divider(color: AppTheme.divider, height: 24),

              // Simulate Incoming Voice Call
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.ring_volume_rounded,
                      color: AppTheme.warning),
                ),
                title: const Text('Simulate Incoming Voice Call',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Test answering incoming voice call',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _simulateIncomingCall(context, isVideo: false);
                },
              ),

              // Simulate Incoming Video Call
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.video_call_rounded,
                      color: AppTheme.accent),
                ),
                title: const Text('Simulate Incoming Video Call',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Test answering incoming video call',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _simulateIncomingCall(context, isVideo: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startOutgoingCall(
    BuildContext context, {
    required String callerName,
    String? callerAvatar,
    required bool isVideo,
  }) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<ActiveCallCubit>(
          create: (_) => sl<ActiveCallCubit>()
            ..startCall(
              callerName: callerName,
              isVideo: isVideo,
            ),
          child: ActiveCallScreen(
            callerName: callerName,
            callerAvatar: callerAvatar,
            isVideo: isVideo,
          ),
        ),
      ),
    )
        .then((_) {
      if (context.mounted) {
        context.read<CallHistoryCubit>().loadHistory();
      }
    });
  }

  void _simulateIncomingCall(BuildContext context, {required bool isVideo}) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(
          callerName: 'Rajan Sharma',
          isVideo: isVideo,
        ),
      ),
    )
        .then((_) {
      if (context.mounted) {
        context.read<CallHistoryCubit>().loadHistory();
      }
    });
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear History', style: AppTheme.titleMedium),
        content: Text(
          'This will permanently delete all call logs.',
          style: AppTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await sl<ClearCallHistoryUseCase>()();
              if (context.mounted) {
                context.read<CallHistoryCubit>().loadHistory();
              }
            },
            child:
                const Text('Clear', style: TextStyle(color: AppTheme.callRed)),
          ),
        ],
      ),
    );
  }
}

// ─── Call Log Tile ───────────────────────────────────────────────────────────

class _CallLogTile extends StatelessWidget {
  final CallLogEntity log;
  final VoidCallback onVoiceCall;
  final VoidCallback onVideoCall;

  const _CallLogTile({
    required this.log,
    required this.onVoiceCall,
    required this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _statusColor.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                log.callerName.isNotEmpty
                    ? log.callerName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.callerName, style: AppTheme.titleMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(_callTypeIcon, size: 14, color: _statusColor),
                    const SizedBox(width: 5),
                    Text(
                      _statusLabel,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (log.durationSeconds > 0) ...[
                      const Text(
                        ' · ',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      Text(
                        DateFormatter.formatDuration(log.durationSeconds),
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Call back actions (Voice & Video)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.call_rounded, size: 20),
                color: AppTheme.callGreen,
                tooltip: 'Voice Call',
                onPressed: onVoiceCall,
              ),
              IconButton(
                icon: const Icon(Icons.videocam_rounded, size: 22),
                color: AppTheme.primary,
                tooltip: 'Video Call',
                onPressed: onVideoCall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _statusColor {
    switch (log.callStatus) {
      case CallStatus.missed:
        return AppTheme.callRed;
      case CallStatus.accepted:
        return AppTheme.callGreen;
      case CallStatus.rejected:
        return AppTheme.warning;
    }
  }

  String get _statusLabel {
    switch (log.callStatus) {
      case CallStatus.missed:
        return 'Missed';
      case CallStatus.accepted:
        return log.callType == CallType.video ? 'Video Call' : 'Voice Call';
      case CallStatus.rejected:
        return 'Declined';
    }
  }

  IconData get _callTypeIcon {
    return log.callType == CallType.video
        ? Icons.videocam_rounded
        : Icons.call_rounded;
  }
}
