class WorkflowTransitionModel {
  final String id;
  final String name;
  final String fromState;
  final String toState;
  final String? description;
  final bool requiresComment;
  final Map<String, dynamic> metadata;

  const WorkflowTransitionModel({
    required this.id,
    required this.name,
    required this.fromState,
    required this.toState,
    this.description,
    this.requiresComment = false,
    this.metadata = const {},
  });

  factory WorkflowTransitionModel.fromJson(Map<String, dynamic> json) {
    return WorkflowTransitionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fromState: json['from_state']?.toString() ?? '',
      toState: json['to_state']?.toString() ?? '',
      description: json['description']?.toString(),
      requiresComment: json['requires_comment'] == true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'from_state': fromState,
      'to_state': toState,
      'description': description,
      'requires_comment': requiresComment,
      'metadata': metadata,
    };
  }
}

class WorkflowTransitionLogModel {
  final String id;
  final String transitionId;
  final String fromState;
  final String toState;
  final String? comment;
  final String performedBy;
  final DateTime performedAt;
  final Map<String, dynamic> metadata;

  const WorkflowTransitionLogModel({
    required this.id,
    required this.transitionId,
    required this.fromState,
    required this.toState,
    this.comment,
    required this.performedBy,
    required this.performedAt,
    this.metadata = const {},
  });

  factory WorkflowTransitionLogModel.fromJson(Map<String, dynamic> json) {
    return WorkflowTransitionLogModel(
      id: json['id']?.toString() ?? '',
      transitionId: json['transition_id']?.toString() ?? '',
      fromState: json['from_state']?.toString() ?? '',
      toState: json['to_state']?.toString() ?? '',
      comment: json['comment']?.toString(),
      performedBy: json['performed_by']?.toString() ?? '',
      performedAt: DateTime.parse(json['performed_at'] ?? DateTime.now().toIso8601String()),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transition_id': transitionId,
      'from_state': fromState,
      'to_state': toState,
      'comment': comment,
      'performed_by': performedBy,
      'performed_at': performedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}